# Save current workspace to output.RData (run this line first in RStudio)
# save.image(file.path("output", "output.RData"))

# Load output.RData and export to Excel

if(!require(openxlsx2)) install.packages("openxlsx2")
library(openxlsx2)

# Load the RData file
load("output/output.RData")

# Create workbook
wb <- wb_workbook()

# Export each object to its own sheet
wb$add_worksheet("compExposures")
wb$add_data("compExposures", compExposures, row_names = TRUE)

wb$add_worksheet("policies")
wb$add_data("policies", policies, row_names = TRUE)

wb$add_worksheet("parameters")
wb$add_data("parameters", as.data.frame(parameters))

# Export events - flatten into rows with activity flags
# First, get all unique activity names across all events
all_activity_names <- c()
for(run_idx in seq_along(events)) {
  if(length(events[[run_idx]]) > 0) {
    for(event_idx in seq_along(events[[run_idx]])) {
      if(!is.null(events[[run_idx]][[event_idx]]$affectsActivities)) {
        all_activity_names <- unique(c(all_activity_names, names(events[[run_idx]][[event_idx]]$affectsActivities)))
      }
    }
  }
}

# Now create rows ensuring all have the same columns
events_df <- do.call(rbind, lapply(seq_along(events), function(run_idx) {
  if(length(events[[run_idx]]) > 0) {
    do.call(rbind, lapply(seq_along(events[[run_idx]]), function(event_idx) {
      event <- events[[run_idx]][[event_idx]]

      # Start with Run, Event_Index, and Severity
      row_data <- list(
        Run = run_idx,
        Event_Index = event_idx,
        Severity = if(!is.null(event$severity)) event$severity else NA
      )

      # Add activity flags (0 or 1) for ALL activities
      for(activity_name in all_activity_names) {
        if(!is.null(event$affectsActivities) && activity_name %in% names(event$affectsActivities)) {
          row_data[[activity_name]] <- as.integer(event$affectsActivities[activity_name])
        } else {
          row_data[[activity_name]] <- 0
        }
      }

      data.frame(row_data, row.names = NULL)
    }))
  } else {
    # Create empty row with all activities set to 0
    row_data <- list(Run = run_idx, Event_Index = 0, Severity = 0)
    for(activity_name in all_activity_names) {
      row_data[[activity_name]] <- 0
    }
    data.frame(row_data, row.names = NULL)
  }
}))

# Fix column names to remove X prefix (R adds X to numeric column names)
col_names <- names(events_df)
col_names <- gsub("^X", "", col_names)
names(events_df) <- col_names

wb$add_worksheet("events")
wb$add_data("events", events_df)

# Export losses - convert list to data frame
losses_df <- do.call(rbind, lapply(seq_along(losses), function(i) {
  if(length(losses[[i]]) > 0) {
    data.frame(Run = i, Loss_Index = seq_along(losses[[i]]), Loss_Value = losses[[i]], row.names = NULL)
  }
}))
wb$add_worksheet("losses")
wb$add_data("losses", losses_df)

# Export payouts - convert list to data frame
payouts_df <- do.call(rbind, lapply(seq_along(payouts), function(i) {
  if(length(payouts[[i]]) > 0) {
    data.frame(Run = i, Payout_Index = seq_along(payouts[[i]]), Payout_Value = payouts[[i]], row.names = NULL)
  }
}))
wb$add_worksheet("payouts")
wb$add_data("payouts", payouts_df)

# Add results sheet with formulas
wb$add_worksheet("results")

# Detect number of events dynamically
num_loss_events <- ncol(losses_df) - 2  # subtract Run and Loss_Index columns
num_payout_events <- ncol(payouts_df) - 2

# Headers
wb$add_data("results", t(c("Run", "Total_Severity", "Total_Losses", "Total_Payouts", 
                           "Num_Events", "Fraction_Paid")), 
            start_row = 1, col_names = FALSE)

# Get unique runs
unique_runs <- sort(unique(events_df$Run))

# Write run numbers
wb$add_data("results", unique_runs, start_col = 1, start_row = 2, col_names = FALSE)

# Add formulas for each metric
for (i in seq_along(unique_runs)) {
  row_num <- i + 1
  
  # Total Severity
  wb$add_formula("results", sprintf("SUMIF(events!$A:$A,$A%d,events!$C:$C)", row_num),
                 start_col = 2, start_row = row_num)
  
  # Total Losses - sum across all event columns dynamically
  loss_parts <- sapply(1:num_loss_events, function(event_idx) {
    col_letter <- LETTERS[2 + event_idx]  # starts at C (2+1)
    sprintf("SUMIF(losses!$A:$A,$A%d,losses!$%s:$%s)", row_num, col_letter, col_letter)
  })
  wb$add_formula("results", paste(loss_parts, collapse = "+"), start_col = 3, start_row = row_num)
  
  # Total Payouts - same approach
  payout_parts <- sapply(1:num_payout_events, function(event_idx) {
    col_letter <- LETTERS[2 + event_idx]
    sprintf("SUMIF(payouts!$A:$A,$A%d,payouts!$%s:$%s)", row_num, col_letter, col_letter)
  })
  wb$add_formula("results", paste(payout_parts, collapse = "+"), start_col = 4, start_row = row_num)
  
  # Num Events
  wb$add_formula("results", sprintf("COUNTIF(events!$A:$A,$A%d)-1", row_num),
                 start_col = 5, start_row = row_num)
  
  # Fraction Paid
  wb$add_formula("results", sprintf("IF($B%d=0,0,$D%d/$B%d)", row_num, row_num, row_num),
                 start_col = 6, start_row = row_num)
}

# Grand totals
total_row <- length(unique_runs) + 3
wb$add_data("results", "GRAND TOTAL", start_col = 1, start_row = total_row, col_names = FALSE)
max_run_row <- length(unique_runs) + 1

for(col_idx in 2:6) {
  if(col_idx == 6) {  # Fraction paid needs special handling
    wb$add_formula("results", sprintf("IF(B%d=0,0,D%d/B%d)", total_row, total_row, total_row),
                   start_col = col_idx, start_row = total_row)
  } else {
    wb$add_formula("results", sprintf("SUM(%s2:%s%d)", LETTERS[col_idx], LETTERS[col_idx], max_run_row),
                   start_col = col_idx, start_row = total_row)
  }
}

# Distribution stats
summary_start <- total_row + 3
stat_labels <- c("Mean Severity", "Median Severity", "Mean Total Payout", "Mean Fraction Paid",
                 "Payout 90% CI Lower", "Payout 90% CI Upper")
wb$add_data("results", stat_labels, start_col = 1, start_row = summary_start, col_names = FALSE)

summary_formulas <- c(
  sprintf("AVERAGE(B2:B%d)", max_run_row),
  sprintf("MEDIAN(B2:B%d)", max_run_row),
  sprintf("AVERAGE(D2:D%d)", max_run_row),
  sprintf("AVERAGE(F2:F%d)", max_run_row),
  sprintf("PERCENTILE(D2:D%d,0.05)", max_run_row),
  sprintf("PERCENTILE(D2:D%d,0.95)", max_run_row)
)

for (i in seq_along(summary_formulas)) {
  wb$add_formula("results", summary_formulas[i], start_col = 2, start_row = summary_start + i - 1)
}

# Save
wb$save("Excel_version/casualty_model_data.xlsx")
cat("Excel file created: Excel_version/casualty_model_data.xlsx\n")
