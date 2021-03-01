# 本程序重命名文件
folder <- "G:/bbc"
files <- list.files(folder)
for(f in files){
  if (str_detect(f,'£') == TRUE){
    print (f)
    newname <- gsub('£', '', f)
    file.rename(paste0(folder,'/',f), paste0(folder,'/',newname))
  }
}
# list.files(folder)