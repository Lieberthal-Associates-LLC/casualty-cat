# Add a pivot table that includes analysis of events by year.
# Adds pivot table data and pivot table analysis to Excel. 

import(openxlsx2)

add_severity_pivot <- function(file_path, data_sheet, metric,
                               row_field, col_field,
                               pivot_sheet = "Pivot") {
  wb <- wb_load(file_path)
  original_df <- wb_to_df(file_path, sheet = data_sheet)
  
  if (nrow(original_df) == 0) return(message("No data"))
  
  wb$add_worksheet("Pivot_Data")$add_data(
    x = original_df[, c(row_field, col_field, metric)]
  )
  
  df <- wb_data(wb, "Pivot_Data")
  wb$add_worksheet(pivot_sheet)
  wb$add_pivot_table(x = df, sheet = pivot_sheet, dims = "A3",
                     rows = row_field, cols = col_field,
                     data = metric, fun = "sum")
  
  wb_save(wb, file_path)
  message("✅ Analytics added!")
}
