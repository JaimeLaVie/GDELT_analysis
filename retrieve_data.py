import os
import gdelt
import pandas as pd
from datetime import datetime

year = '2018'
target_file = os.getcwd() + '/gdelt_data'

def datelist(beginDate, endDate):
    # beginDate, endDate是形如‘20160601’的字符串或datetime格式
    dates = [datetime.strftime(x,'%Y-%m-%d') for x in list(pd.date_range(start=beginDate, end=endDate))]
    return dates

dates = datelist(year + '0101', year + '1231')

gd2 = gdelt.gdelt(version=2)

for date in dates:
    date_for_gd2 = date.replace('-', ' ')
    date_for_name = date.replace('-', '_')
    print (date_for_gd2)
    events = gd2.Search(date_for_gd2, table='events', coverage=True)
    events.to_csv(target_file + "/gdelt_{}.csv".format(date_for_name), index=False, sep=',')
# with open ("gdelt_data_1.jsonl", "w") as file:
#     file.write(json.dumps(results)+'\n')

# Full day pull, output to pandas dataframe, events table
# results = gd2.Search(['2016 11 01'], table='events', coverage=True, output='json')
# print(len(results))
# with open ("gdelt_data_2.jsonl", "w") as file:
#     file.write(json.dumps(results)+'\n')