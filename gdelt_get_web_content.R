# 本程序实现BBC爬虫，是gdelt_select_news_data.R的前续程序。
rm(list = ls())

library(stringr)
library(rvest)

data_address <- "gdelt_data/"
target_address <- "bbc/"
gdelt_files <- list.files(data_address)
length_files <- length(gdelt_files)

for (num in 1:length_files){
  if (str_detect(gdelt_files[num], ".csv$") == TRUE){
    print (str_sub(gdelt_files[num], 7, 14))
    csv_file <- read.csv(paste(data_address, gdelt_files[num], sep = ""))
    length_csv_file <- length(csv_file$MonthYear)
    print (length_csv_file)
    url_complete <- ''
    for (i in 1:length_csv_file){
      # 显示进度
      if (i %% 200 == 0){
        cat (str_sub(gdelt_files[num], 7, 14), ": ", round(i/length_csv_file, 2)*100, '%', '\n')
      }
      # other_website <- 1
      url <- csv_file[i, 'SOURCEURL'] %>% as.character()
      # url <- 'https://www.bbc.com/news/uk-northern-ireland-foyle-west-50328767'
      # 选出BBC新闻并剔除明显无关内容
      if (str_detect(url,'www.bbc') == TRUE && str_detect(url,'/live/') == FALSE && str_detect(url,'mediacentre/') == FALSE && str_detect(url,'/sport/') == FALSE && str_detect(url,'/future/') == FALSE && str_detect(url,'/culture/') == FALSE && str_detect(url,'/programmes/') == FALSE && str_detect(url,'/cbbc/') == FALSE){
        if (str_detect(url_complete, url) == FALSE){           # 防止重复收集同一个网页的内容
          url_complete <- paste(url_complete, url, sep = ' ')
          print ('Find one!')
          print (i)
          # 避免网址不存在，出现404错误
          possibleError <- tryCatch({
            web <- read_html(url)
            }, error=function(e){
            print('HTTP Error 404, go next.')})
          if(inherits(possibleError, "error")) next
          # web <- read_html(url)
          # 第一种网页，如https://www.bbc.com/news/uk-northern-ireland-foyle-west-50328767：
          title <- web %>% html_nodes('h1.e1fj1fc10') %>% html_text()
          if (length(title) != 0){
            flag <- 1
            title <- title[1]     # 以免出现数行的title导致后续无法存储
            # 命名规则：日期_原文件中的行数_网页类别_新闻标题.txt
            title <- paste(str_sub(gdelt_files[num], 7, 14), paste(as.character(i), paste(as.character(flag), title, sep = '_'), sep = '_'), sep = '_')
            text <- web %>% html_nodes('div.e5tfeyi2') %>% html_text()
          } else {
          # 第二种网页，如https://www.bbc.com/news/business-50896066：
            title <- web %>% html_nodes('div.story-body h1') %>% html_text()
            if (length(title) != 0){
              flag <- 2
              title <- title[1]
              title <- paste(str_sub(gdelt_files[num], 7, 14), paste(as.character(i), paste(as.character(flag), title, sep = '_'), sep = '_'), sep = '_')
              text <- web %>% html_nodes('div.story-body__inner p') %>% html_text()
            } else {
          # 第三种网页，如https://www.bbc.com/pidgin/media-50985597：
              title <- web %>% html_nodes('div.gVouae h1') %>% html_text()
              if (length(title) != 0){
                flag <- 3
                title <- title[1]
                title <- paste(str_sub(gdelt_files[num], 7, 14), paste(as.character(i), paste(as.character(flag), title, sep = '_'), sep = '_'), sep = '_')
                text <- web %>% html_nodes('div.fVauYi p') %>% html_text()
              } else {
          # 第四种网页，如https://www.bbc.co.uk/newsround/51060735：
                title <- web %>% html_nodes('div.newsround-story-header__title-layout h1') %>% html_text()
                if (length(title) != 0){
                  flag <- 4
                  title <- title[1]
                  title <- paste(str_sub(gdelt_files[num], 7, 14), paste(as.character(i), paste(as.character(flag), title, sep = '_'), sep = '_'), sep = '_')
                  text <- web %>% html_nodes('p.newsround-story-body__text') %>% html_text()
                } else {
          # 其它网页，记录下来
                  flag <- 0
                  title <- paste(str_sub(gdelt_files[num], 7, 14), paste(as.character(i), paste(as.character(flag), 'other_website', sep = '_'), sep = '_'), sep = '_')
                  text <- ''
                }
              }
            }
          }
          title <- gsub('/', '', title)
          title <- gsub('£', '', title)
          length_text <- length(text)
          text[length_text + 1] <- url
          
          write.table (text, file = paste(target_address, paste(title, '.txt', sep = ''), sep = ''), row.names = FALSE, col.names = FALSE)
          cat ('Web type: ', flag, '\n')
        }
      }
    }
  }
}

cat ('Finished!')