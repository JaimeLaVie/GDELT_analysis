rm(list = ls())

WD<-getwd()
if(!is.null(WD))setwd("E:\\GitHub\\GDELT_analysis")
getwd()

#install.packages("tidyverse")
#install.packages("readr")

library(readr) 
library(stringr)
library(dplyr)
library(magrittr)

#' Gets GDELT Event data, by year from 1979-2005, by year month 2006 - 2013, then by dat

get_urls_gdelt_event_log <- function(return_message = T) {
  
  url <-
    'http://data.gdeltproject.org/events/md5sums'
  
  urlData <-
    url %>%
    readr::read_tsv(col_names = F) %>%
    tidyr::separate(col = X1,
                    into = c('idHash', 'stemData'),
                    sep = '\\  ') %>%
    dplyr::mutate(
      urlData = 'http://data.gdeltproject.org/events/' %>%
        paste0(stemData),
      slugDatabaseGDELT = 'EVENTS',
      isZipFile = ifelse(stemData %>% stringr::str_detect(".zip"), T, F)
    ) %>%
    suppressWarnings() %>%
    suppressMessages()
  
  urlData <-
    urlData %>%
    tidyr::separate(
      col = stemData,
      into = c('periodData', 'nameFile', 'typeFile', 'zip_file'),
      sep = '\\.'
    ) %>%
    dplyr::select(-zip_file) %>%
    dplyr::mutate(
      periodData = ifelse(periodData == 'GDELT', typeFile, periodData),
      isDaysData = ifelse(periodData %>% nchar == 8, T, F)
    ) %>%
    dplyr::select(-c(nameFile, typeFile)) %>%
    suppressWarnings()
  
  urlData <-
    urlData %>%
    dplyr::filter(isDaysData == F) %>%
    dplyr::mutate(dateData = NA) %>%
    bind_rows(
      urlData %>%
        dplyr::filter(isDaysData == T) %>%
        dplyr::mutate(dateData = periodData %>% lubridate::ymd() %>% as.Date())
    ) %>%
    dplyr::select(idHash,
                  dateData,
                  isZipFile,
                  isDaysData,
                  urlData,
                  everything())
  
  if (return_message) {
    count.files <-
      urlData %>%
      nrow
    
    min.date <-
      urlData$dateData %>% min(na.rm = T)
    
    max.date <-
      urlData$dateData %>% max(na.rm = T)
    
    "You got " %>%
      paste0(count.files,
             ' GDELT Global Knowledge Graph URLS from ',
             min.date,
             ' to ',
             max.date) %>%
      cat(fill = T)
  }
  
  return(urlData)
}



#### get all data
urlData <-  get_urls_gdelt_event_log()

save(urlData, file = "E:\\GitHub\\GDELT_analysis\\data\\urlData.RData")
head(urlData)

## use loop for downloan 
periods <- urlData$periodData[-1] #remove 1979-2013


## Begin to download ##


### download the data: 1979-201303; starting from 20130401, new data
# 以下暂时注释掉，需要收集201303以前数据的时候再恢复。

# i<-1
# for (i in 1: 114) {
#   print (i)
#   
#   url <- urlData$urlData[i+1]
#   
#   #store in tempfile
#   tmp <- tempfile()
#   #download to temp
#   url %>% curl::curl_download(url = ., tmp)
#   #unzip
#   con <- unzip(tmp)
#   #get the number of colnames
#   gdelt_cols <- con %>%
#     read_tsv(col_names = F,
#              n_max = 1) %>% ncol() %>%
#     suppressMessages() %>%
#     suppressWarnings()
#   #if col = 57, use the variable names from event
#   if (gdelt_cols == 57) {
#     
#     assign(paste("gdelt_data", periods[i], sep = "_"), con %>%
#              readr::read_tsv(col_names = F) %>%
#              suppressWarnings() %>%
#              suppressMessages()
#     )
#     
#     df.tmp <- get(paste("gdelt_data", periods[i], sep = "_"))  
#     
#     names(df.tmp) <- 
#       c("GlobalEventID",
#         "dateEvent",
#         "MonthYear",
#         "Year",
#         "FractionDate",
#         "Actor1Code",
#         "Actor1Name",
#         "Actor1CountryCode",
#         "Actor1KnownGroupCode",
#         "Actor1EthnicCode",
#         "Actor1Religion1Code",
#         "Actor1Religion2Code",
#         "Actor1Type1Code",
#         "Actor1Type2Code",
#         "Actor1Type3Code",
#         "Actor2Code",
#         "Actor2Name",
#         "Actor2CountryCode",
#         "Actor2KnownGroupCode",
#         "Actor2EthnicCode",
#         "Actor2Religion1Code",
#         "Actor2Religion2Code",
#         "Actor2Type1Code",
#         "Actor2Type2Code",
#         "Actor2Type3Code",
#         "IsRootEvent",
#         "EventCode",
#         "EventBaseCode",
#         "EventRootCode",
#         "QuadClass",
#         "GoldsteinScale",
#         "NumMentions",
#         "NumSources",
#         "NumArticles",
#         "AvgTone",
#         "Actor1Geo_Type",
#         "Actor1Geo_Fullname",
#         "Actor1Geo_CountryCode",
#         "Actor1Geo_ADM1Code",  #注意此处应有一个Actor1Geo_ADM2Code
#         "Actor1Geo_Lat",
#         "Actor1Geo_Long",
#         "Actor1Geo_FeatureID",
#         "Actor2Geo_Type",
#         "Actor2Geo_Fullname",
#         "Actor2Geo_CountryCode",
#         "Actor2Geo_ADM1Code",  #注意此处应有一个Actor2Geo_ADM2Code
#         "Actor2Geo_Lat",
#         "Actor2Geo_Long",
#         "Actor2Geo_FeatureID",
#         "ActionGeo_Type",
#         "ActionGeo_Fullname",
#         "ActionGeo_CountryCode",
#         "ActionGeo_ADM1Code",  #注意此处应有一个ActionGeo_ADM2Code
#         "ActionGeo_Lat",
#         "ActionGeo_Long",
#         "ActionGeo_FeatureID",
#         "dateAdded"            #注意此处应有一个SOURCEURL
#       )
#     
#     ## format time and date
#     assign(paste("gdelt_data", periods[i], sep = "_"), df.tmp %>%
#              dplyr::rename(dateDocument = dateAdded) %>%
#              dplyr::mutate(
#                dateEvent = lubridate::ymd(dateEvent),
#                dateDocument = lubridate::ymd(dateDocument)
#              ) %>%
#              suppressWarnings()
#     )
#     
#   }
#   
#   df.tmp <- get(paste("gdelt_data", periods[i], sep = "_"))  
#   
#   save(df.tmp,
#        file = paste0(paste( "E:\\GitHub\\GDELT_analysis\\data\\gdelt", periods[i], sep = "_"), ".RData"))
#   write.csv(df.tmp,paste0(paste( "E:\\GitHub\\GDELT_analysis\\data\\gdelt", periods[i], sep = "_"), ".csv"),row.names = FALSE)
#   rm(list = c(paste("gdelt_data", periods[i], sep = "_"))); rm(df.tmp)
#   ##remove csv files
#    mydir <- getwd()
#    delfiles <- dir(path=mydir, pattern="*.csv")
#    file.remove(file.path(mydir, delfiles))
#   
# }


### 2013-04-01 onwards
for (i in 115: length(periods)) {   #115对应20130401，2798对应20200810
  print (i)
  
  url <- urlData$urlData[i+1]
  
  #store in tempfile
  tmp <- tempfile()
  #download to temp
  url %>% curl::curl_download(url = ., tmp)
  #unzip
  con <- unzip(tmp)
  #get the number of colnames
  gdelt_cols <- con %>%
    read_tsv(col_names = F,
             n_max = 1) %>% ncol() %>%
    suppressMessages() %>%
    suppressWarnings()
  #if col = 58, use the variable names from event
  if (gdelt_cols == 58) {
    
    assign(paste("gdelt_data", periods[i], sep = "_"), con %>%
             readr::read_tsv(col_names = F) %>%
             suppressWarnings() %>%
             suppressMessages()
    )
    
    df.tmp <- get(paste("gdelt_data", periods[i], sep = "_"))  
    
    names(df.tmp) <- 
      c("GlobalEventID",
        "dateEvent",
        "MonthYear",
        "Year",
        "FractionDate",
        "Actor1Code",
        "Actor1Name",
        "Actor1CountryCode",
        "Actor1KnownGroupCode",
        "Actor1EthnicCode",
        "Actor1Religion1Code",
        "Actor1Religion2Code",
        "Actor1Type1Code",
        "Actor1Type2Code",
        "Actor1Type3Code",
        "Actor2Code",
        "Actor2Name",
        "Actor2CountryCode",
        "Actor2KnownGroupCode",
        "Actor2EthnicCode",
        "Actor2Religion1Code",
        "Actor2Religion2Code",
        "Actor2Type1Code",
        "Actor2Type2Code",
        "Actor2Type3Code",
        "IsRootEvent",
        "EventCode",
        "EventBaseCode",
        "EventRootCode",
        "QuadClass",
        "GoldsteinScale",
        "NumMentions",
        "NumSources",
        "NumArticles",
        "AvgTone",
        "Actor1Geo_Type",
        "Actor1Geo_Fullname",
        "Actor1Geo_CountryCode",
        "Actor1Geo_ADM1Code",  #注意此处应有一个Actor1Geo_ADM2Code
        # "Actor1Geo_ADM2Code",
        "Actor1Geo_Lat",
        "Actor1Geo_Long",
        "Actor1Geo_FeatureID",
        "Actor2Geo_Type",
        "Actor2Geo_Fullname",
        "Actor2Geo_CountryCode",
        "Actor2Geo_ADM1Code",  #注意此处应有一个Actor2Geo_ADM2Code
        # "Actor2Geo_ADM2Code",
        "Actor2Geo_Lat",
        "Actor2Geo_Long",
        "Actor2Geo_FeatureID",
        "ActionGeo_Type",
        "ActionGeo_Fullname",
        "ActionGeo_CountryCode",
        "ActionGeo_ADM1Code",  #注意此处应有一个ActionGeo_ADM2Code
        # "ActionGeo_ADM2Code",
        "ActionGeo_Lat",
        "ActionGeo_Long",
        "ActionGeo_FeatureID",
        "dateAdded",           #注意此处应有一个SOURCEURL
        "SOURCEURL"
        # "idGlobalEvent",
        # "dateEvent",
        # "monthYearEvent",
        # "yearEvent",
        # "dateFraction",
        # "codeActor1",
        # "nameActor1",
        # "codeISOActor1",
        # "codeCAMEOGroupActor1",
        # "codeCAMEOEthnicityActor1",
        # "codeCAMEOReligionActor1",
        # "codeCAMEOReligion2Actor1",
        # "codeCAMEOTypeActor1",
        # "codeCAMEOType2Actor1",
        # "codeCAMEOType3Actor1",
        # "codeActor2",
        # "nameActor2",
        # "codeISOActor2",
        # "codeCAMEOGroupActor2",
        # "codeCAMEOEthnicityActor2",
        # "codeCAMEOReligionActor2",
        # "codeCAMEOReligion2Actor2",
        # "codeCAMEOTypeActor2",
        # "codeCAMEOType2Actor2",
        # "codeCAMEOType3Actor.3",
        # "isRootEvent",
        # "idCAMEOEvent",
        # "idCAMEOEventBase",
        # "idCAMEOEventRoot",
        # "classQuad",
        # "scoreGoldstein",
        # "countMentions",
        # "countSources",
        # "countArticles",
        # "avgTone",
        # "idTypeLocationActor1",
        # "locationActor1",
        # "idCountryActor1",
        # "idADM1CodeActor1",
        # "latitudeActor1",
        # "longitudeActor1",
        # "idFeatureActor1",
        # "idTypeLocationActor2",
        # "locationActor2",
        # "idCountryActor2",
        # "idADM1CodeActor2",
        # "latitudeActor2",
        # "longitudeActor2",
        # "idFeatureActor2",
        # "idTypeLocationAction",
        # "locationAction",
        # "idCountryAction",
        # "idADM1CodeAction",
        # "latitudeAction",
        # "longitudeAction",
        # "idFeatureAction",
        # "dateAdded",
        # "source"
      )
    
    ## format time and date
    assign(paste("gdelt_data", periods[i], sep = "_"), df.tmp %>%
             dplyr::rename(dateDocument = dateAdded) %>%
             dplyr::mutate(
               dateEvent = lubridate::ymd(dateEvent),
               dateDocument = lubridate::ymd(dateDocument)
             ) %>%
             suppressWarnings()
    )
    
  }
  
  df.tmp <- get(paste("gdelt_data", periods[i], sep = "_"))  
  
  save(df.tmp,
       file = paste0(paste( "E:\\GitHub\\GDELT_analysis\\data\\gdelt", periods[i], sep = "_"), ".RData"))
  write.csv(df.tmp,paste0(paste( "E:\\GitHub\\GDELT_analysis\\data\\gdelt", periods[i], sep = "_"), ".csv"),row.names = FALSE)
  ##remove csv files
  mydir <- getwd()
  delfiles <- dir(path=mydir, pattern="*.CSV")
  file.remove(file.path(mydir, delfiles))

}


# ### 2018-01-01 onwards for China and USA
# GDELT_US_CHINA<-NULL
# i<-1847
# 
# for (i in 1847: length(periods)) {
#   
#   
#   url <- urlData$urlData[i+1]
#   #store in tempfile
#   tmp <- tempfile()
#   #download to temp
#   url %>% curl::curl_download(url = ., tmp)
#   #unzip
#   con <- unzip(tmp)
#   #get the number of colnames
#   gdelt_cols <- con %>%
#     read_tsv(col_names = F,
#              n_max = 1) %>% ncol() %>%
#     suppressMessages() %>%
#     suppressWarnings()
#   #if col = 58, use the variable names from event
#   if (gdelt_cols == 58) {
#     
#     assign(paste("gdelt_data", periods[i], sep = "_"), con %>%
#              readr::read_tsv(col_names = F) %>%
#              suppressWarnings() %>%
#              suppressMessages()
#     )
#     
#     df.tmp <- get(paste("gdelt_data", periods[i], sep = "_"))  
#     
#     names(df.tmp) <- 
#       c("idGlobalEvent",
#         "dateEvent",
#         "monthYearEvent",
#         "yearEvent",
#         "dateFraction",
#         "codeActor1",
#         "nameActor1",
#         "codeISOActor1",
#         "codeCAMEOGroupActor1",
#         "codeCAMEOEthnicityActor1",
#         "codeCAMEOReligionActor1",
#         "codeCAMEOReligion2Actor1",
#         "codeCAMEOTypeActor1",
#         "codeCAMEOType2Actor1",
#         "codeCAMEOType3Actor1",
#         "codeActor2",
#         "nameActor2",
#         "codeISOActor2",
#         "codeCAMEOGroupActor2",
#         "codeCAMEOEthnicityActor2",
#         "codeCAMEOReligionActor2",
#         "codeCAMEOReligion2Actor2",
#         "codeCAMEOTypeActor2",
#         "codeCAMEOType2Actor2",
#         "codeCAMEOType3Actor.3",
#         "isRootEvent",
#         "idCAMEOEvent",
#         "idCAMEOEventBase",
#         "idCAMEOEventRoot",
#         "classQuad",
#         "scoreGoldstein",
#         "countMentions",
#         "countSources",
#         "countArticles",
#         "avgTone",
#         "idTypeLocationActor1",
#         "locationActor1",
#         "idCountryActor1",
#         "idADM1CodeActor1",
#         "latitudeActor1",
#         "longitudeActor1",
#         "idFeatureActor1",
#         "idTypeLocationActor2",
#         "locationActor2",
#         "idCountryActor2",
#         "idADM1CodeActor2",
#         "latitudeActor2",
#         "longitudeActor2",
#         "idFeatureActor2",
#         "idTypeLocationAction",
#         "locationAction",
#         "idCountryAction",
#         "idADM1CodeAction",
#         "latitudeAction",
#         "longitudeAction",
#         "idFeatureAction",
#         "dateAdded",
#         "source"
#       )
#     
#     ## format time and date
#     assign(paste("gdelt_data", periods[i], sep = "_"), df.tmp %>%
#              dplyr::rename(dateDocument = dateAdded) %>%
#              dplyr::mutate(
#                dateEvent = lubridate::ymd(dateEvent),
#                dateDocument = lubridate::ymd(dateDocument)
#              ) %>%
#              suppressWarnings()
#     )
#     
#   }
#   
#   df.tmp <- get(paste("gdelt_data", periods[i], sep = "_"))  
#   
#   #only select China and us
#   df.tmp<-df.tmp[which(df.tmp$codeISOActor1 %in% c("USA","CHN") & df.tmp$codeISOActor2 %in% c("USA","CHN")),]
#   
#   GDELT_US_CHINA<-rbind(GDELT_US_CHINA,df.tmp)
#   #save(df.tmp,
#   #     file = paste0(paste( "E:\\DATA\\GDELTDATA\\", periods[i], sep = "_"), ".RData"))
#   #rm(list = c(paste("gdelt_data", periods[i], sep = "_"))); rm(df.tmp)
#   
#   ##remove gdelt_data_*.CSV, if computer is 64-bite, no need this command
#   a<-ls()
#   rm(list=a[which(a==paste("gdelt_data", periods[i], sep = "_"))])
#   
#   ##remove cvs files, if computer has enough space, no need this command
#   mydir <- getwd()
#   delfiles <- dir(path=mydir, pattern="*.CSV" )
#   file.remove(file.path(mydir, delfiles))
#   
# }
# 
# #write.csv(GDELT_US_CHINA,file = "/Elements/Data/GDELTDATA/GDELT_US_CHINA2018-2020_2.csv")
# 
# #write.csv(GDELT_US_CHINA,file = "/Users/sandy/Documents/DataCode/GDELTDATA/GDELT_US_CHINA2018-2020.csv")
# 
# unique(GDELT_US_CHINA$yearEvent)
# unique(GDELT_US_CHINA$codeActor1)
# unique(GDELT_US_CHINA$codeActor2)
# 
# 
# GDELT_US_CHINA_Clean<-GDELT_US_CHINA[-which(GDELT_US_CHINA$yearEvent %in% c(2017,2008,2009,1920,2010)),]
# unique(GDELT_US_CHINA_Clean$yearEvent)
# 
# 
# #write.csv(GDELT_US_CHINA_Clean,file = "/Users/sandy/Documents/DataCode/GDELTDATA/GDELT_US_CHINA_Clean2018-2020.csv")











