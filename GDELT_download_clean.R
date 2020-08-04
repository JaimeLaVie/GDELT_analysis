rm(list = ls())
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

save(urlData, file = "GDELT/Clean_data/urlData.RData")
head(urlData)



## use loop for downloan 
periods <- urlData$periodData[-1] #remove 1979-2013

### download the data: 1979-201303; starting from 20130401, new data

for (i in 1: 114) {
  
  
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
  #if col = 57, use the variable names from event
  if (gdelt_cols == 57) {
    
    assign(paste("gdelt_data", periods[i], sep = "_"), con %>%
             readr::read_tsv(col_names = F) %>%
             suppressWarnings() %>%
             suppressMessages()
    )
    
    df.tmp <- get(paste("gdelt_data", periods[i], sep = "_"))  
    
    names(df.tmp) <- 
      c("idGlobalEvent",
        "dateEvent",
        "monthYearEvent",
        "yearEvent",
        "dateFraction",
        "codeActor1",
        "nameActor1",
        "codeISOActor1",
        "codeCAMEOGroupActor1",
        "codeCAMEOEthnicityActor1",
        "codeCAMEOReligionActor1",
        "codeCAMEOReligion2Actor1",
        "codeCAMEOTypeActor1",
        "codeCAMEOType2Actor1",
        "codeCAMEOType3Actor1",
        "codeActor2",
        "nameActor2",
        "codeISOActor2",
        "codeCAMEOGroupActor2",
        "codeCAMEOEthnicityActor2",
        "codeCAMEOReligionActor2",
        "codeCAMEOReligion2Actor2",
        "codeCAMEOTypeActor2",
        "codeCAMEOType2Actor2",
        "codeCAMEOType3Actor.3",
        "isRootEvent",
        "idCAMEOEvent",
        "idCAMEOEventBase",
        "idCAMEOEventRoot",
        "classQuad",
        "scoreGoldstein",
        "countMentions",
        "countSources",
        "countArticles",
        "avgTone",
        "idTypeLocationActor1",
        "locationActor1",
        "idCountryActor1",
        "idADM1CodeActor1",
        "latitudeActor1",
        "longitudeActor1",
        "idFeatureActor1",
        "idTypeLocationActor2",
        "locationActor2",
        "idCountryActor2",
        "idADM1CodeActor2",
        "latitudeActor2",
        "longitudeActor2",
        "idFeatureActor2",
        "idTypeLocationAction",
        "locationAction",
        "idCountryAction",
        "idADM1CodeAction",
        "latitudeAction",
        "longitudeAction",
        "idFeatureAction",
        "dateAdded"
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
       file = paste0(paste( "GDELT/Clean_data/gdelt_data", periods[i], sep = "_"), ".RData"))
  rm(list = c(paste("gdelt_data", periods[i], sep = "_"))); rm(df.tmp)
  ##remove cvs files
   mydir <- getwd()
   delfiles <- dir(path=mydir, pattern="*.csv")
    file.remove(file.path(mydir, delfiles))
  
}


### 2013-04-01 onwards
for (i in 115: length(periods)) {
  
  
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
      c("idGlobalEvent",
        "dateEvent",
        "monthYearEvent",
        "yearEvent",
        "dateFraction",
        "codeActor1",
        "nameActor1",
        "codeISOActor1",
        "codeCAMEOGroupActor1",
        "codeCAMEOEthnicityActor1",
        "codeCAMEOReligionActor1",
        "codeCAMEOReligion2Actor1",
        "codeCAMEOTypeActor1",
        "codeCAMEOType2Actor1",
        "codeCAMEOType3Actor1",
        "codeActor2",
        "nameActor2",
        "codeISOActor2",
        "codeCAMEOGroupActor2",
        "codeCAMEOEthnicityActor2",
        "codeCAMEOReligionActor2",
        "codeCAMEOReligion2Actor2",
        "codeCAMEOTypeActor2",
        "codeCAMEOType2Actor2",
        "codeCAMEOType3Actor.3",
        "isRootEvent",
        "idCAMEOEvent",
        "idCAMEOEventBase",
        "idCAMEOEventRoot",
        "classQuad",
        "scoreGoldstein",
        "countMentions",
        "countSources",
        "countArticles",
        "avgTone",
        "idTypeLocationActor1",
        "locationActor1",
        "idCountryActor1",
        "idADM1CodeActor1",
        "latitudeActor1",
        "longitudeActor1",
        "idFeatureActor1",
        "idTypeLocationActor2",
        "locationActor2",
        "idCountryActor2",
        "idADM1CodeActor2",
        "latitudeActor2",
        "longitudeActor2",
        "idFeatureActor2",
        "idTypeLocationAction",
        "locationAction",
        "idCountryAction",
        "idADM1CodeAction",
        "latitudeAction",
        "longitudeAction",
        "idFeatureAction",
        "dateAdded",
        "source"
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
       file = paste0(paste( "GDELT/Clean_data/gdelt_data", periods[i], sep = "_"), ".RData"))
  rm(list = c(paste("gdelt_data", periods[i], sep = "_"))); rm(df.tmp)
  ##remove cvs files
  mydir <- getwd()
  delfiles <- dir(path=mydir, pattern="*.csv")
  file.remove(file.path(mydir, delfiles))
}

