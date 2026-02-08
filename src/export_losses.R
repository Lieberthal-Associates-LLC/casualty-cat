import(openxlsx2)

export_losses <- function(losses, outputPath) {
  wb <- wb_workbook()
  wb$add_worksheet("losses")
  
  start_row = 1
  for(i in seq_along(losses)) {
    loss_matrix = losses[[i]]
    wb$add_data("losses", paste("Run", i), start_row = start_row, col_names = FALSE)
    start_row = start_row + 1
    wb$add_data("losses", loss_matrix, start_row = start_row, row_names = TRUE)
    start_row = start_row + nrow(loss_matrix) + 2
  }
  
  wb$save(outputPath)
  cat("Excel file created:", outputPath, "\n")
}