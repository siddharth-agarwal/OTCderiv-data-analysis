getSDRData <- function(serv,file_ext,date_str){
  dl_url<-sprintf(paste(serv,file_ext,sep=""),date_str)
  temp <- tempfile()
  download.file(dl_url,temp)
  dtaset <- read.csv(unzip(temp))
  unlink(temp)
  return(dtaset)
}