# 本程序在已收集到的完整数据中筛选所需数据，并保存
rm(list = ls())

library(stringr)

setwd("G:\\")
# 截止至20200814的亚洲、欧洲参与一带一路国家名单，来源：https://www.yidaiyilu.gov.cn/gbjg/gbgk/77073.htm
countries <- c('CHN', 'KOR', 'MNG', 'SGP', 'TLS', 'MYS', 'MMR', 'KHM', 'VNM', 'LAO', 'BRN', 'PAK', 'LKA',
               'BGD', 'NPL', 'MDV', 'ARE', 'KWT', 'TUR', 'QAT', 'OMN', 'LBN', 'SAU', 'BHR', 'IRN', 'IRQ',
               'AFG', 'AZE', 'GEO', 'ARM', 'KAZ', 'KGZ', 'TJK', 'UZB', 'THA', 'IDN', 'PHL', 'YEM',
               'CYP', 'RUS', 'AUT', 'GRC', 'POL', 'SRB', 'CZE', 'BGR', 'SVK', 'ALB', 'HRV', 'BIH', 'MNE',
               'EST', 'LTU', 'SVN', 'HUN', 'MKD', 'ROU', 'LVA', 'UKR', 'BLR', 'MDA', 'MLT', 'PRT', 'ITA', 
               'LUX')
rivers <- c('water', 'stream', 'river', 'tributary', 'canal', 'lake', 'channel','reservoir',
            'alakol', 'amur', 'an-nahr-al-kabir', 'annahralkabir', 'an-nahr', 'annahr',
            'al-kabir', 'alkabir', 'aral', 'asi', 'orontes', 'astara', 'chay', 'atrak', 
            'beilun', 'bangau', 'ca', 'song-lam', 'songlam', 'coruh', 'digul', 'dasht', 
            'fly', 'fenney', 'ganges-brahmaputra-meghna', 'gangesbrahmaputrameghna', 
            'golok', 'han', 'hari', 'harirud', 'hamun-i-mashkel', 'hamunimashkel', 
            'rakshan', 'helmand', 'har-us-nur', 'harusnur', 'bei-jiang', 'beijiang', 
            'hsi', 'ili', 'kunes-he', 'kuneshe', 'indus', 'irrawaddy', 
            'jayapura', 'jordan', 'kaladan', 'karnaphuli', 'kowl-e-namaksar', 'kowlenamaksar',
            'kura-araks', 'kuraaraks', 'sarygamesh', 'ubsa-nur', 'ubsanur','loes', 
            'maro', 'ma', 'mekong', 'muhuri', 'murgab', 'naaf', 'nahr-el-kebir', 
            'nahrelkebir', 'ob', 'pakchan', 'pandaruan', "pu-lun-t'o", 'pu-lun-to', 
            'pulunto', 'rann-of-kutch', 'rannofkutch', 'red', 
            'song-hong', 'songhong', 'rach-giang-thanh', 'rachgiangthanh', 
            'nha-be-saigon-song-vam-co-dong', 'nhabesaigonsongvamcodong',
            'salween', 'sebuku', 'sepik', 'song-tien-yen', 'songtienyen', 'shu', 
            'chu', 'sembakung', 'sujfun', 'talas', 'tami', 'tigris-euphrates', 
            'tigriseuphrates', 'shatt-al-arab', 'shattalarab', 'tjeroaka-wanggoe', 
            'tjeroakawanggoe', 'tarim', 'tumen', 'vanimo-green', 'vanimogreen', 'yalu', 
            'jenisej', 'yenisey',  # 以上亚洲，以下欧洲；
            'adige', 'angerman', 'bann','bidasoa', 'berbyelva', 'barta', 'castletown', 'cetina', 'danube',
            'dnieper', 'dniester', 'don', 'dragonja', 'drin', 'daugava', 'douro', 'duero', 'ebro', 
            'elbe', 'elancik', 'erne', 'fane', 'flurry', 'foyle', 'glama', 'garonne', 'gruzskiy', 
            'yelanchik', 'guadiana', 'gauja', 'indalsalven', 'isonzo', 'jacobs', 'kemi', 'kogilnik', 'krka', 
            'klaralven', 'lava', 'pregel', 'lima', 'lake', 'prespa', 'lielupe', 'lough', 'melvin', 
            'mino', 'mius', 'maritsa', 'naatamo', 'nidelva', 'neman', 'neretva', 'narva', 'nestos', 'narynka', 
            'oder', 'odra', 'olanga', 'oral', 'ural', 'oulu', 'peschanaya', 
            'poldnevaya', 'po', 'prohladnaja', 'parnu', 'psou', 'pasvik', 'rezvaya', 'rhine', 
            'meuse', 'rhone', 'roia', 'salaca', 'samur', 'seine', 'schelde', 'sarata', 'struma', 'sulak', 
            'tagus', 'tejo', 'tana', 'terek', 'torne', 'tornealven', 'tuloma', 'vecht', 'venta',
            'vefsna', 'vijose', 'velaka', 'volga', 'vardar', 'vistula', 'wista', 'vuoksa', 'wiedau', 'yser')
symbols <- c('-', '_', '%2', '%20')    # 词前后加上-或_以避免误收录
plus <- c('pollut', 'contamin', 'toxic', 'waste', 'purification', 'sewage', 'effluence', 'scarc', 'shortage',
          'lack', 'insufficiency', 'dike', 'dyke', 'irrigation', 'dam', 'diversion', 'flood', 'drought')
gdelt_files <- list.files("G:\\gdelt_data")
length_files <- length(gdelt_files)
length_rivers <- length(rivers)
length_symbols <- length(symbols)

for (num in 1:length_files) {
  year <- 2019
  if (str_sub(gdelt_files[num], 7, 10) == year && nchar(gdelt_files[num]) >= 18 && str_detect(gdelt_files[num], ".csv$") == TRUE){ # 指定年份为2013，使用20130401之后的数据
    print (gdelt_files[num])
    csv_file <- read.csv(paste("G:\\gdelt_data\\", gdelt_files[num], sep = "\\"))
    length_csv_file <- length(csv_file$MonthYear)
    print (length_csv_file)
    
    # 创建空表
    data <- csv_file[1,]
    data$river <- NA
    data <- data[-1,]
    
    for (i in 1:length_csv_file){
      if (((csv_file[i, 'Actor1CountryCode'] %in% countries && is.na(csv_file[i, 'Actor2CountryCode']) == FALSE) || (csv_file[i, 'Actor2CountryCode'] %in% countries && is.na(csv_file[i, 'Actor1CountryCode']) == FALSE) ) && csv_file[i, 'MonthYear'] == substring(gdelt_files[num],7,12)){
        for (j in 1:length_rivers){
          for (k in 1:length_symbols){
            river <- gsub('-', symbols[k], rivers[j])  # 某些河流由数个词组成，应考虑到网址中的各种隔断方式
            keyword <- paste(paste(symbols[k], river, sep = ""), symbols[k], sep = "")
            web <- unlist(strsplit(as.character(csv_file[i, 'SOURCEURL']), split='/'))
            lengthweb <- length(web)
            if (str_detect(tolower(paste(web[lengthweb - 1], web[lengthweb], sep = "")), keyword) == TRUE){
              newline <- csv_file[i,]
              newline$river <- rivers[j]
              data <- rbind(data[1:nrow(data),], newline)
              break
            }
          }
        }
      }
    }
    data <- data[-1,]   # 删去全为NA的首行
    print ('保存中...')
    write.csv(data, file = paste(paste("G:\\gdelt_data_selected\\", paste(year, "\\", sep = ""), sep = ""), paste(substring(gdelt_files[num],7,14), ".csv", sep = ""), sep = ""), row.names = FALSE)
  }
}


