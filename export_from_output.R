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

# Save
wb$save("Excel_version/casualty_model_data.xlsx")
cat("Excel file created: Excel_version/casualty_model_data.xlsx\n")
