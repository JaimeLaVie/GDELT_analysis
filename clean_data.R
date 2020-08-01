# 本程序在已收集到的完整数据中筛选所需数据，并保存
# library(scales)

# par(mfrow=c(1,3))
gdelt <- read.csv('gdelt_data/gdelt_2018_01_01.csv')

print (gdelt[:][1])

length_gdelt <- length(gdelt$MonthYear)

print (length_gdelt)

#for (i in 1:length_gdelt)
#{
#  if 
#}

# ggplot(num, aes(x = num$No, y = num$attitudes)) + 
  # geom_line( position = "identity", color = '#984ea3') +
  # labs(x = 'Time', y = 'Number of Attitudes', size = 18) +
  # guides(fill=FALSE)

