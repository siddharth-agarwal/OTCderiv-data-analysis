# CURRENT SDR SOURCES ARE:
# 1. DTCC
# 2. CME
# 3. BBG (TODO)
# 4. ICE (TODO)

source(func.R)
## CONFIGURABLE
cur_date <- Sys.Date()-1

dtcc_gtr_aws_serv <- 'https://kgc0418-tdw-data2-0.s3.amazonaws.com'
cme_ftp_serv <- 'ftp://ftp.cmegroup.com/sdr'

cme_fx_ext <- '/fx/2017/06/RT.FX.%s.csv.zip'

dtcc_commodity_url <- '/slices/CUMULATIVE_COMMODITIES_%s.zip'
dtcc_credit_url <- '/slices/CUMULATIVE_CREDITS_%s.zip'
dtcc_equities_url <- '/slices/CUMULATIVE_EQUITIES_%s.zip'
dtcc_fx_url <- '/slices/CUMULATIVE_FOREX_%s.zip'
dtcc_rates_url <- '/slices/CUMULATIVE_RATES_%s.zip'

## GET CME FILE
cme_fx_data <- getSDRData(cme_ftp_serv,cme_fx_ext,as.character.POSIXt(cur_date,'%Y%m%d'))
## GET DTCC FILE
dtcc_tmp_data <- getSDRData(dtcc_gtr_aws_serv,dtcc_rates_url,as.character.POSIXt(cur_date,'%Y_%m_%d'))

## ISDA TAXONOMY
library(readxl)
isda_taxonomy_file <- 'data/ISDA_OTC_deriv_taxonomies.xls'
# excel_sheets(isda_taxonomy_file)
isda_taxonomy_credit<-read_xls(isda_taxonomy_file,sheet = 'Credit Full Taxonomy',range='B7:E125')
isda_taxonomy_ir<-read_xls(isda_taxonomy_file,sheet = 'Interest Rate Full Taxonomy',range='B6:D20')
isda_taxonomy_comm<-read_xls(isda_taxonomy_file,sheet = 'Commodity Full Taxonomy',range='B6:E114')
isda_taxonomy_fx<-read_xls(isda_taxonomy_file,sheet = 'Foreign Exchange Full Taxonomy',range='B6:D14')
isda_taxonomy_eq<-read_xls(isda_taxonomy_file,sheet = 'Equity Taxonomy Full',range='B6:E40')

## ANALYZE CUMULATIVE DATA
options(digits.secs = 3)
library(dplyr)
datatst2 <- dtcc_tmp_data
datatst2$PRICE_NOTATION <- as.numeric(datatst2$PRICE_NOTATION)
datatst2$ROUNDED_NOTIONAL_AMOUNT_1 <- as.numeric(datatst2$ROUNDED_NOTIONAL_AMOUNT_1)
datatst2$EXECUTION_TIMESTAMP <- as.POSIXct(strptime(datatst2$EXECUTION_TIMESTAMP, "%Y-%m-%dT%H:%M:%S"))
times <- c("06:00:00","10:00:00","16:00:00")
x <- paste(cur_date-1, times)
time_slices <- strptime(x, "%Y-%m-%d %H:%M:%S")

library(ggplot2)
tst<-datatst2 %>% 
  # filter(EXECUTION_TIMESTAMP< time_slices[1])%>%
  # levels(TAXONOMY)
  filter(TAXONOMY=='InterestRate:FRA') %>%
  filter(UNDERLYING_ASSET_1=='USD-LIBOR-BBA') %>%
  filter(ACTION=='NEW') %>%
  ggplot(aes(x= (EXECUTION_TIMESTAMP),y=PRICE_NOTATION)) +
    geom_point()
