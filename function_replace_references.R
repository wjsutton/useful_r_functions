
replace_references <- function(folder,name,new_name){

  user_folder <- folder
  search_term <- name
  replacement_term <- new_name
  
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
  
  if(nrow(output_df)>0){
    files_to_change <- unique(output_df$file_name_and_path)
    
    for(i in 1:length(files_to_change)){
      
      editing_file <- readLines(paste0(files_to_change[i]))
      edited_file <- gsub(search_term,replacement_term,editing_file)
      
      fileConn <- file(files_to_change[i])
      writeLines(edited_file, fileConn)
      close(fileConn)
      
      changes_made <- nrow(output_df[which(output_df$file_name_and_path == files_to_change[i]),])
      
      print(paste0(changes_made," changes made to file: ",files_to_change[i]))
    }
  }
  
  if(nrow(output_df)==0){
    print("No changes made.")
  }
  
}

user_folder <- "/data/users/will/migration/tests"
search_term <- "central_insights"
replacement_term <- "central_insights_sandbox"

replace_references(user_folder,search_term,replacement_term)
