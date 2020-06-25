# Function to convert Excel date formats (DD/MM/YYYY) to YYYY-MM-DD

function_convert_excel_date <- function(date){
  if(class(date)=="character" && nchar(date)==10){
    date <- paste0(substr(date,7,10),'-',substr(date,4,5),'-',substr(date,1,2))
  }
  return(date)
}
