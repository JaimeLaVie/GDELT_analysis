# 本程序在已爬虫到的新闻数据中筛选所需数据，并保存，是gdelt_get_web_content.R的后续程序。
rm(list = ls())

library(stringr)

setwd("G:\\")
news_address <- "G:\\bbc"
target_address <- "G:\\bbc_selected"
# 截止至20200914的亚洲、欧洲参与一带一路国家名单，来源：https://www.yidaiyilu.gov.cn/gbjg/gbgk/77073.htm
# countries <- c('CHN', 'KOR', 'MNG', 'SGP', 'TLS', 'MYS', 'MMR', 'KHM', 'VNM', 'LAO', 'BRN', 'PAK', 'LKA',
#                'BGD', 'NPL', 'MDV', 'ARE', 'KWT', 'TUR', 'QAT', 'OMN', 'LBN', 'SAU', 'BHR', 'IRN', 'IRQ',
#                'AFG', 'AZE', 'GEO', 'ARM', 'KAZ', 'KGZ', 'TJK', 'UZB', 'THA', 'IDN', 'PHL', 'YEM',
#                'CYP', 'RUS', 'AUT', 'GRC', 'POL', 'SRB', 'CZE', 'BGR', 'SVK', 'ALB', 'HRV', 'BIH', 'MNE',
#                'EST', 'LTU', 'SVN', 'HUN', 'MKD', 'ROU', 'LVA', 'UKR', 'BLR', 'MDA', 'MLT', 'PRT', 'ITA', 
#                'LUX')
countries <- c('China', 'South Korea', 'Republic of Korea', 'ROK', 'Mongolia', 'Singapore', 'Timor-Leste',
               'East Timor', 'Malaysia', 'Myanmar', 'Cambodia', 'Vietnam', 'Viet nam', 'Laos', 'Brunei', 
               'Pakistan', 'Sri Lanka', 'Bangladesh', 'Nepal', 'Maldives', 'the UAE', 'United Arab Emirates',
               'Kuwait', 'Turkey', 'Qatar', 'Oman', 'Lebanon', 'Saudi Arabia', 'Bahrain', 'Iran', 'Iraq',
               'Afghanistan', 'Azerbaijan', 'Georgia', 'Armenia', 'Kazakhstan', 'Kyrgyzstan', 'Tajikistan',
               'Uzbekistan', 'Thailand', 'Indonesia', 'Philippines', 'Yemen',
               'Cyprus', 'Russia', 'Austria', 'Greece', 'Poland', 'Serbia', 'Czech', 'Bulgaria', 'Slovakia',
               'Albania', 'Croatia', 'Bosnia', 'Herzegovina', 'Montenegro', 'Estonia', 'Lithuania', 'Slovenia',
               'Hungary', 'North Macedonia', 'Romania', 'Latvia', 'Ukraine', 'Belarus', 'Moldova', 'Malta', 
               'Portugal', 'Italy', 'Luxembourg')
rivers <- c(# 'water', 'stream', 'river', 'tributary', 'canal', 'lake', 'channel','reservoir',
            # 非洲
            'Akpa', 'Annole', 'Awash', 'Bahr at Tubat', 'Benito', 'Ntem', 'Bia', 'Oued Bou Namoussa',
            'Baraka', 'Buzi', 'Chiloango', 'Congo', 'Zaire', 'Cross', 'Cestos', 'Cavally', 'Daoura',
            'Dra', 'Cuvelai', 'Etosha', 'Gambia', 'Gash', 'Geba-Corubal', 'Galana', 'Great Scarcies',
            'Guir', 'Incomati', 'Juba-Shibeli', 'Komoe', 'Kunene', 'Lotagipi Swamp', 'Lake Chad',
            'Lake Chilwa', 'Lake Cayo', 'Lak Dera', 'Lake Natron', 'Lake Rukwa', 'Lake Turkana', 'Limpopo',
            'Loffa', 'Little Scarcies', 'Mana-Morro', 'Mbe', 'Medjerda', 'Moa', 'Mono', 'Maputo', 'Niger',
            'Nile', 'Nyanga', 'Oued Bon Naima', 'Ogooue', 'Okavango', 'Orange', 'Oueme', 'Pangani',
            'Pungwe', 'Ruvuma', 'Sabi', 'Sanaga', 'Sassandra', 'Senegal', 'St. John', 'St. Paul', 'Tafna',
            'Tano', 'Umbeluzi', 'Umba', 'Utamboni', 'Volta', 'Zambezi',
            # 亚洲
            'Alakol', 'Amur', 'An Nahr Al Kabir', 'Aral Sea', 'Asi', 'Orontes', 'Astara Chay', 'Atrak',
            'Beilun', 'Bangau', 'Ca', 'Song Lam', 'Coruh', 'Digul', 'Dasht', 'Fly', 'Fenney', 'Ganges-Brahmaputra-Meghna',
            'Golok', 'Han', 'Hari', 'Harirud', 'Hamun-i-Mashkel', 'Rakshan', 'Helmand', 'Har Us Nur',
            'Bei Jiang/Hsi', 'Ili', 'Kunes He', 'Indus', 'Irrawaddy', 'Jayapura', 'Jordan', 'Kaladan',
            'Karnaphuli', 'Kowl E Namaksar', 'Kura-Araks', 'Lake Sarygamesh', 'Lake Ubsa-Nur', 'Loes',
            'Maro', 'Ma', 'Mekong', 'Muhuri', 'Little Feni', 'Murgab', 'Naaf River', 'Nahr El Kebir',
            'Ob', 'Pakchan', 'Pandaruan', "Pu Lun T'o", 'Rann of Kutch', 'Red', 'Song Hong', 'Rach Giang Thanh',
            'Nha Be-Saigon-Song Vam Co Dong', 'Salween', 'Sebuku', 'Sepik', 'Song Tien Yen', 'Shu', 'Chu',
            'Sembakung', 'Sujfun', 'Talas', 'Tami', 'Tigris-Euphrates', 'Shatt al Arab', 'Tjeroaka-Wanggoe',
            'Tarim', 'Tumen', 'Vanimo-Green', 'Yalu', 'Jenisej', 'Yenisey',
            # 欧洲
            'Adige', 'Angerman', 'Bann','Bidasoa', 'Berbyelva', 'Barta', 'Castletown', 'Cetina', 'Danube',
            'Dnieper', 'Dniester', 'Don', 'Dragonja', 'Drin', 'Daugava', 'Douro', 'Duero', 'Ebro', 'Elbe',
            'Elancik', 'Erne', 'Fane', 'Flurry', 'Foyle', 'Glama', 'Garonne', 'Gruzskiy Yelanchik', 
            'Guadiana', 'Gauja', 'Indalsalven', 'Isonzo', 'Jacobs', 'Kemi', 'Kogilnik', 'Krka', 
            'Klaralven', 'Lava', 'Pregel', 'Lima', 'Lake Prespa', 'Lielupe', 'Lough Melvin', 'Mino',
            'Mius', 'Maritsa', 'Naatamo', 'Nidelva', 'Neman', 'Neretva', 'Narva', 'Nestos', 'Narynka', 
            'Oder', 'Odra', 'Olanga', 'Oral', 'Ural', 'Oulu', 'Peschanaya', 'Poldnevaya', 'Po', 'Prohladnaja',
            'Parnu', 'Psou', 'Pasvik', 'Rezvaya', 'Rhine-Meuse', 'Rhone', 'Roia', 'Salaca', 'Samur', 
            'Seine', 'Schelde', 'Sarata', 'Struma', 'Sulak', 'Tagus', 'Tejo', 'Tana', 'Terek', 'Torne', 
            'Tornealven', 'Tuloma', 'Vecht', 'Venta', 'Vefsna', 'Vijose', 'Velaka', 'Volga', 'Vardar', 
            'Vistula', 'Wista', 'Vuoksa', 'Wiedau', 'Yser',
            # 北美洲
            'Alsek', 'Artibonite', 'Belize', 'Caetani', 'Candelaria', 'Changuinola', 'Choluteca', 'Colorado',
            'Chilkat', 'Columbia', 'Connecticut', 'Coco', 'Segovia', 'Copper', 'Coatan Achute', 'Fraser',
            'Firth', 'Grijalva', 'Goascoran', 'Hondo', 'Lake Azuei', 'Lake Enriquillo', 'Lempa', 'Lucia',
            'Massacre', 'Mississippi', 'Moho', 'Motaqua', 'Negro', 'Nelson-Saskatchewan', 'Paz', 'Pedernales',
            'Rio Grande', 'Santa Clara', 'St. Croix', 'Sixaola', 'St. John', 'San Juan', 'Skagit',
            'St. Lawrence', 'Sarstun', 'Stikine', 'Suchiate', 'Taku', 'Temash', 'Tijuana', 'Unuk', 'Whiting',
            'Yaqui', 'Yukon',
            # 南美洲
            'Amacuro', 'Amazon', 'Aviles', 'Aysen', 'Baker', 'Barima', 'Carmen Silva', 'Chico', 'Chira',
            'Chuy', 'Cancoso', 'Lauca', 'Comau', 'Corantijn', 'Courantyne', 'Catatumbo', 'Cullen', 'Essequibo',
            'Gallegos', 'Chico', 'Jurado', 'Laguna Filaret', 'Lake Fagnano', 'Lake Titicaca-Poopo System',
            'Lagoon Dos Patos-Lagoon Mirim', 'La Plata', 'Mira', 'Maroni', 'Mataje', 'Orinoco', 'Oiapoque', 
            'Oyupock', 'Palena', 'Pascua', 'Patia', 'Puelo', 'Rio Grande', 'Seno Union', 'Serrano',
            'San Martin', 'Tumbes', 'Valdivia', 'Yelcho', 'Zapaleri', 'Zarumilla')
# 所有河流流域都加上去
# symbols <- c('-', '_', '%2', '%20')    # 词前后加上-或_以避免误收录
# plus <- c('pollut', 'contamin', 'toxic', 'waste', 'purification', 'sewage', 'effluence', 'scarc', 'shortage',
#           'lack', 'insufficiency', 'dike', 'dyke', 'irrigation', 'dam', 'diversion', 'flood', 'drought')
news_files <- list.files(news_address)
length_files <- length(news_files)
length_countries <- length(countries)
length_rivers <- length(rivers)
# length_symbols <- length(symbols)

for (num in 1:length_files) {
  # print (news_files[num])
  if(str_detect(news_files[num], "_0_") == TRUE) next
  possibleError <- tryCatch(
    text <- read.table(paste(news_address, news_files[num], sep = "\\")),
    error=function(e) e) #{
    # cat ('Error! Address: ', news_files[num], '\n')})
  if(inherits(possibleError, "error")){
    # cat ("Show you I can work")
    cat ('Error! Address: ', news_files[num], '\n')
    next
  }
  text <- unlist(text) %>% as.character()
  # print ('Here!')
  # for (i in 1:length_countries){
  #   if (str_detect(text, countries[i]) == TRUE){
  save_flag <- FALSE
  for (j in 1:length_rivers){
    if(length(text) == 0){
      cat ('Error! Argument is of length zero, no read outcome! Address: ', news_files[num], '\n')
      break
    }
    if (str_detect(text, paste(paste(" ", rivers[j], sep = ""), " ", sep = "")) == TRUE){
      save_flag <- TRUE
      # cat (rivers[j], '\n', news_files[num], '\n')
      length_text <- length(text)
      text[length_text + 1] <- rivers[j]
      #   }
      # }
    }
  }
  if (save_flag == TRUE){
    write.table(text, file = paste(target_address, news_files[num], sep = '\\'), row.names = FALSE, col.names = FALSE)
  }
}

