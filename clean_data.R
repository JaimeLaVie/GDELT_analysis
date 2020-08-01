# 本程序在已收集到的完整数据中筛选所需数据，并保存
gdelt <- read.csv('gdelt_data/gdelt_2018_01_05.csv')

length_gdelt <- length(gdelt$MonthYear)

print (length_gdelt)

# 创建空表
data <- gdelt[1,]
data <- data[-1,]

for (i in 1:length_gdelt) {
  if (gdelt[i,'Actor1CountryCode'] == 'CHN') {
    print (gdelt[i,'GLOBALEVENTID'])
    data <- rbind(data[1:nrow(data),], gdelt[i,])
  }
}

write.csv(data, file = "chn.csv", row.names = FALSE)


