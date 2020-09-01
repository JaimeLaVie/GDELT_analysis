# 本程序在进一步筛选所需数据，并保存
rm(list = ls())

library(stringr)

setwd("G:\\")
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
          'lack', 'insufficiency', 'dike', 'dyke', 'irrigation', 'dam', 'diversion', 'flood', 'drought', 
          'countr', 'state', 'nation', 'conflict', 'collid', 'collision')
# oil
# 2019
length_rivers <- length(rivers)
length_symbols <- length(symbols)
length_plus <- length(plus)

year <- 2013
csv_file <- read.csv(paste(paste("G:\\gdelt_data_selected\\", year, sep = ""), ".csv", sep = ""))
length_csv_file <- length(csv_file$MonthYear)
print (length_csv_file)
    
# 创建空表
data <- csv_file[1,]
data$support <- NA
data <- data[-1,]
    
for (i in 1:length_csv_file){
  print (csv_file[i, 'dateEvent'])
  flag <- 0
  web <- unlist(strsplit(as.character(csv_file[i, 'SOURCEURL']), split='/'))
  lengthweb <- length(web)
  for (h in 1:length_plus){
    for (k in 1:length_symbols){
      keyword <- paste(paste(symbols[k], plus[h], sep = ""), symbols[k], sep = "")
      if (str_detect(tolower(paste(web[lengthweb - 1], web[lengthweb], sep = "")), keyword) == TRUE){
        newline <- csv_file[i,]
        newline$support <- plus[h]
        flag <- 1
        break
      }
    }
  }
  if (flag == 0){
    for (j in 1:length_rivers){
      if (rivers[j] != as.character(csv_file[i, 'river'])){   # 若有与此前纪录不同的另一河流名称出现，则保留
        for (k in 1:length_symbols){
          river <- gsub('-', symbols[k], rivers[j])  # 某些河流由数个词组成，应考虑到网址中的各种隔断方式
          keyword <- paste(paste(symbols[k], river, sep = ""), symbols[k], sep = "")
          if (str_detect(tolower(paste(web[lengthweb - 1], web[lengthweb], sep = "")), keyword) == TRUE){
            newline <- csv_file[i,]
            newline$support <- rivers[j]
            flag <- 1
            break
          }
        }
      }
    }
  }
  if (flag == 1){
    data <- rbind(data[1:nrow(data),], newline)
  }
}

# data <- data[-1,]   # 删去全为NA的首行
print ('保存中...')
write.csv(data, file = paste(paste("G:\\gdelt_data_selected\\select__", year, sep = ""), ".csv", sep = ""), row.names = FALSE)
