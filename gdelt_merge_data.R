# 本程序合并并保存csv文件
rm(list = ls())
options(scipen = 200)

readCSV <- function(dir_dta){
  file_list <- list.files(path=dir_dta,full.names=T)
  varSave_func <- function(x){
    table_x <- read.csv(file=x,sep=",",header = T)
  }
  a<-invisible(lapply(file_list,FUN=varSave_func))
  b<-as.data.frame(a[[1]])
  for (i in 2:length(a)){
    c<-rbind(b,a[[i]])
    b <- c
  }
  return(b)
}


dir_dta <- "G:\\gdelt_data_selected\\2013"
result <-readCSV(dir_dta)
write.csv(result, file = paste("G:\\gdelt_data_selected\\", "2013.csv", sep = ""), row.names = FALSE)
