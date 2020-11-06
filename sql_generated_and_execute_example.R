
### Basic Function

# Create Function
global_sales_weekly <- function(date_from,date_to){
  
  query <- paste0("
SELECT 
region
,DATE_TRUNC('week',date) as date
,'Weekly' as date_type
,product
,SUM(sales) as sales
,'",Sys.Date(),"' as data_written_date
FROM schema.global_sales
WHERE date>='",date_from,"'
AND date<='",date_to,"'
GROUP BY 
region
,DATE_TRUNC('week',date)
,product
")
  
  return(query)
  
}

# Run Function
weekly_sales <- global_sales_weekly(date_from = '2020-10-26',date_to = '2020-11-01')

# Write SQL to file
fileConn <- file("weekly_sales.sql")
writeLines(weekly_sales, fileConn)
close(fileConn)

### Looping

# Make lists of start & end dates
start_dates <- c('2020-10-26','2020-10-19','2020-10-12')
end_dates <- c('2020-11-01','2020-10-25','2020-10-18')

# Loop over all dates
for(i in seq(start_dates)){
  
  # Run Function
  weekly_sales <- global_sales_weekly(date_from = start_dates[i],date_to = end_dates[i])
  
  # Remove dashs for file name
  file_date <- gsub('-','',start_dates[i])
  
  # Write SQL to file
  fileConn <- file(paste0("weekly_sales_",file_date,".sql"))
  writeLines(weekly_sales, fileConn)
  close(fileConn)
}

### Adding Arguments

# Create Function
global_sales <- function(date_from,date_to,date_type = c('Daily','Weekly','Monthly')){
  
  date_column <- ifelse(date_type == "Daily","date",
                        ifelse(date_type == "Weekly","DATE_TRUNC('week',date)"
                               ,"DATE_TRUNC('month',date)"))
  
  
  query <- paste0("
SELECT 
region
,",date_column," as date
,'",date_type,"' as date_type
,product
,SUM(sales) as sales
,'",Sys.Date(),"' as data_written_date
FROM schema.global_sales
WHERE date>='",date_from,"'
AND date<='",date_to,"'
GROUP BY 
region
,",date_column,"
,product
")
  
  return(query)
  
}

daily_sales <- global_sales(date_from = '2020-10-26',date_to = '2020-11-01',date_type = 'Daily')
weekly_sales <- global_sales(date_from = '2020-10-26',date_to = '2020-11-01',date_type = 'Weekly')
monthly_sales <- global_sales(date_from = '2020-10-01',date_to = '2020-10-31',date_type = 'Monthly')

# Write SQL to file
fileConn <- file("daily_sales.sql")
writeLines(daily_sales, fileConn)
close(fileConn)

fileConn <- file("weekly_sales.sql")
writeLines(weekly_sales, fileConn)
close(fileConn)

fileConn <- file("monthly_sales.sql")
writeLines(monthly_sales, fileConn)
close(fileConn)


### Execute over a folder of queries

# Function to read SQL scripts
# From: https://stackoverflow.com/questions/44853322/how-to-read-the-contents-of-an-sql-file-into-an-r-script-to-run-a-query
getSQL <- function(filepath){
  con = file(filepath, "r")
  sql.string <- ""
  
  while (TRUE){
    line <- readLines(con, n = 1)
    
    if ( length(line) == 0 ){
      break
    }
    
    line <- gsub("\\t", " ", line)
    
    if(grepl("--",line) == TRUE){
      line <- paste(sub("--","/*",line),"*/")
    }
    
    sql.string <- paste(sql.string, line)
  }
  
  close(con)
  return(sql.string)
}

# Connect to Database (Redshift)
library(RJDBC)
conn <- dbConnect(...)

# Read SQL and get query results
query <- getSQL("weekly_sales.sql")
orders <- dbGetQuery(conn,query)

# Write data as insert
query <- getSQL("weekly_sales.sql")
insert_query <- paste0("INSERT INTO my_schema.my_global_weekly_sales_table (",query,")")
dbSendQuery(conn,query)



