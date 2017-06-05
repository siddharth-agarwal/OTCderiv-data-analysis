commodity_url <- '/slices/CUMULATIVE_COMMODITIES_%s.zip'
credit_url <- '/slices/CUMULATIVE_CREDITS_%s.zip'
equities_url <- '/slices/CUMULATIVE_EQUITIES_%s.zip'
fx_url <- '/slices/CUMULATIVE_FOREX_%s.zip'
rates_url <- '/slices/CUMULATIVE_RATES_%s.zip'

cur_date <- Sys.Date()

dl_url<-sprintf(rates_url,as.character.POSIXt(cur_date-1,'%Y_%m_%d'))

temp <- tempfile()
download.file(dl_url,temp)
datatst <- read.csv(unzip(temp))
unlink(temp)

datatst2 <- datatst
## ISDA TAXONOMY
excel_sheets('data/ISDA_OTC_deriv_taxonomies.xls')
isda_taxonomy_credit<-read_xls('data/ISDA_OTC_deriv_taxonomies.xls',sheet = 'Credit Full Taxonomy')
isda_taxonomy_ir<-read_xls('data/ISDA_OTC_deriv_taxonomies.xls',sheet = 'Interest Rate Full Taxonomy')
isda_taxonomy_comm<-read_xls('data/ISDA_OTC_deriv_taxonomies.xls',sheet = 'Commodity Full Taxonomy')
isda_taxonomy_fx<-read_xls('data/ISDA_OTC_deriv_taxonomies.xls',sheet = 'Foreign Exchange Full Taxonomy')
isda_taxonomy_eq<-read_xls('data/ISDA_OTC_deriv_taxonomies.xls',sheet = 'Equity Taxonomy Full')

options(digits.secs = 3)
library(dplyr)

datatst2$PRICE_NOTATION <- as.numeric(datatst$PRICE_NOTATION)
datatst2$ROUNDED_NOTIONAL_AMOUNT_1 <- as.numeric(datatst$ROUNDED_NOTIONAL_AMOUNT_1)
datatst2$EXECUTION_TIMESTAMP <- as.POSIXct(strptime(datatst2$EXECUTION_TIMESTAMP, "%Y-%m-%dT%H:%M:%S"))


times <- c("06:00:00","10:00:00","16:00:00")
x <- paste(cur_date-1, times)
time_slices <- strptime(x, "%Y-%m-%d %H:%M:%S")

tstslice<-datatst2 %>% 
  filter(EXECUTION_TIMESTAMP< time_slices[1])%>% 
  filter(TAXONOMY=='InterestRate:FRA') %>%
  filter(UNDERLYING_ASSET_1=='USD-LIBOR-BBA') %>%
  filter(ACTION=='NEW') %>%
  
  ggplot(aes(x= (EXECUTION_TIMESTAMP),y=PRICE_NOTATION)) +
    geom_point()
