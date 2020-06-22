find_references <- function(folder,name){
  
  user_folder <- folder
  search_term <- name
  
  scripts <- list.files(path = user_folder, recursive = T, full.names = T, pattern = "\\.R$|\\.r$|\\.sql$|\\.py$")
  
  output_df <- data.frame(user_folder=character()
                          ,file_name_and_path=character()
                          ,redshift_table=character()
                          ,stringsAsFactors = F)
  
  for(i in 1:length(scripts)){
    filepath <- scripts[i]
    search_for <- paste0(search_term,"\\.")
    results <- grep(search_for, readLines(paste0(filepath)), value = TRUE)
    
    if(length(results)>0){
      positions <- regexpr(paste0(search_for,"[a-zA-Z0-9_]+"), results, perl=TRUE)
      tables <- unique(regmatches(results,positions))
      
      output <- data.frame(user_folder=user_folder
                           ,file_name_and_path=filepath
                           ,redshift_table=tables
                           ,stringsAsFactors = F)
      
      if(nrow(output_df)>0){
        output_df <- rbind(output_df,output)
      }
      
      if(nrow(output_df)==0){
        output_df <- output
      }
    }
  }
  return(output_df)
}


