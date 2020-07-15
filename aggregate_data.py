import pandas as pd
import re
import numpy as np

def reduce_category(word):
    '''
    Find just one category of the hate crime
    '''
    w = word.lower()
    w = re.sub('[^A-Za-z0-9]+', ' ', w)
    race = ['black', 'white', 'race', 'native', 'asian', 'latino', 'hispanic', 'arab']
    lgbt = ['gay', 'lesbian', 'bisexual', 'transgender', 'gender']
    gender = ['female', 'male']
    religious = ['jewish', 'protestant', 'religion','muslim', 'islam','catholic',
                'atheism', 'jenovah', 'mormon', 'buddhist', 'sikh', 'christian', 
                 'hindu', 'orthodox']
    for i in race:
        if i in w:
            return 'race_{}'.format(i)
    for i in lgbt:
        if i in w:
            return 'LGBT'
    for i in gender:
        if i in w:
            return 'Gender'
    for i in religious:
        if i in w:
            return 'r_{}'.format(i)
    
    return 'Other'

def aggregate_hategroups():
    #Download hate groups data from Southern Poverty Law Center
    hg = pd.read_csv('data/splc-hate-groups.csv')
    #Obtain population estimates
    pop = pd.read_csv('data/population.csv')
    
    groups = hg.groupby(['State', 'Year', 'Ideology']).size().unstack('Ideology').reset_index()
    groups.fillna(0, inplace=True)
    other_ideologies = ['Anti-LGBTQ', 'Black Separatist', 'Christian Identity', 'General Hate', 'Hate Music', 
                    'Holocaust Denial', 'Ku Klux Klan', 'Male Supremacy', 'Neo-Confederate','Neo-Volkisch', 
                    'Racist Skinhead','Radical Traditional Catholicism']
    groups['Other'] = groups[other_ideologies].sum(axis=1)
    groups.drop(columns=other_ideologies, inplace=True)
    groups=groups[groups.Year > 2009]
    groups = groups.merge(pop, on=['State', 'Year'], how='right')

    groups=groups[groups.State != 'District of Columbia']

    ideologies= ['Anti-Immigrant', 'Anti-Muslim', 'Neo-Nazi', 'White Nationalist', 'Other']
    groups[ideologies] = groups[ideologies].fillna(0)
    for col in ideologies:
        groups[col] = (groups[col]/groups['population']*1000000).apply(round, ndigits=2)
    groups.drop(columns=['population'], inplace=True)
    print('Storing hate groups data in data folder')
    groups.to_csv('data/agg_hg.csv', index=False)

def aggregate_hatecrimes():
    #Get FBI data on hate crimes, limit to Single bias crimes only
    hc = pd.read_csv('data/ucr_hatecrimes.csv', sep=',', dtype='unicode')
    hc = hc[hc.MULTIPLE_BIAS == 'S']
    hc['DATA_YEAR'] = hc['DATA_YEAR'].astype(int)

    hc['cat'] = hc.apply(lambda row: reduce_category(row['BIAS_DESC']), axis=1)
    hc['race'] = np.where(hc.cat.str.startswith('race_'),hc.cat.str.replace('race_',''), np.nan)
    hc['cat'] = np.where(hc.cat.str.startswith('race_'),'race',hc.cat)
    hc['religious'] = np.where(hc.cat.str.startswith('r_'),hc.cat.str.replace('r_',''), np.nan)
    hc['cat'] = np.where(hc.cat.str.startswith('r_'),'religious',hc.cat)

    #Obtain population estimates
    pop = pd.read_csv('data/population.csv')
    
    groups_hc = hc[hc.cat =='race'].groupby(['STATE_NAME', 'DATA_YEAR', 'race']).size().unstack().reset_index()
    race_categories = ['arab', 'asian', 'black', 'latino', 'native', 'race', 'white']
    groups_hc[race_categories] = groups_hc[race_categories].fillna(0)
    groups_hc['other'] = groups_hc[['white', 'race']].sum(axis=1)
    groups_hc.rename(columns={'STATE_NAME': 'State', 'DATA_YEAR': 'Year'}, inplace=True)
    groups_hc = groups_hc[groups_hc.Year > 2009].merge(pop, on=['State', 'Year'], how='right')
    groups_hc=groups_hc[groups_hc.State != 'District of Columbia']
    groups_hc[race_categories + ['other']] = groups_hc[race_categories + ['other']].fillna(0)
    groups_hc.drop(columns=['white', 'race'], inplace=True)
    for col in race_categories[:-2]+['other']:
        groups_hc[col]= (groups_hc[col]/groups_hc['population']*1000000).apply(round, ndigits=2)
    groups_hc.drop(columns='population', inplace=True)
    print('Storing aggregated hate crimes in data folder')
    groups_hc.to_csv('data/agg_hc.csv', index=False)


if __name__ == "__main__":
    aggregate_hategroups()
    aggregate_hatecrimes()