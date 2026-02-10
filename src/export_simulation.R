# Given R output, export to Excel

# Bring in openxlsx2 package

import(openxlsx2)

# Create a spreadsheet in the given output path
create_spreadsheet <- function(sheetName, outputPath) {
  
}

# Material to output
## Inputs to the simulation
### Parameters
### Policies
## Interim results
### compExposures
### Events
## Simulation outputs 
### Losses
### Payouts 
## Outputs for check
### 90% confidence interval for payouts and losses
### Total event severity, total loss, total payout
### Fraction of severity and loss paid out 

# Add worksheets for inputs

# Add worksheets for interim results

# Add worksheets for simulation outputs

export_outputs <- function(parameters, policies, compExposures, events,
                           losses, payouts, outputPath) {
  wb <- wb_workbook()
  wb$add_worksheet("parameters")
  wb$add_worksheet("policies")
  wb$add_worksheet("compExposures")
  wb$add_worksheet("events")
  wb$add_worksheet("losses")
  wb$add_worksheet("payouts")

  # Parameters sheet
  params_df <- flatten_parameters(parameters)
  wb$add_data("parameters", params_df)
  
  # Policies sheet
  wb$add_data("policies", policies, row_names = TRUE)
  
  # CompExposures sheet
  wb$add_data("compExposures", compExposures, row_names = TRUE)
  
  # Events sheet
  events_df <- flatten_events(events)
  wb$add_data("events", events_df)
  
  # Losses sheet
  start_row = 1
  for(i in seq_along(losses)) {
    loss_matrix = losses[[i]]
    wb$add_data("losses", paste("Run", i), start_row = start_row, col_names = FALSE)
    start_row = start_row + 1
    wb$add_data("losses", loss_matrix, start_row = start_row, row_names = TRUE)
    start_row = start_row + nrow(loss_matrix) + 2
  }
  
  # Payouts sheet
  start_row = 1
  for(i in seq_along(payouts)) {
    payout_matrix = payouts[[i]]
    wb$add_data("payouts", paste("Run", i), start_row = start_row, col_names = FALSE)
    start_row = start_row + 1
    wb$add_data("payouts", payout_matrix, start_row = start_row, row_names = TRUE)
    start_row = start_row + nrow(payout_matrix) + 2
  }
  
  wb$save(outputPath)
  cat("Excel file created:", outputPath, "\n")
}

# Flatten the parameters file for export to Excel

flatten_parameters <- function(parameters) {
  # Handle activityNames and activityProbs specially
  if("activityNames" %in% names(parameters) && "activityProbs" %in% names(parameters)) {
    activities_df <- data.frame(
      activityName = parameters$activityNames,
      activityProb = parameters$activityProbs
    )
    names(activities_df) <- c("Parameter", "Value")
  } else {
    activities_df <- NULL
  }
  
  # All other scalar parameters
  other_params <- parameters[!names(parameters) %in% c("activityNames", "activityProbs")]
  params_df <- data.frame(
    Parameter = names(other_params),
    Value = unlist(other_params)
  )
  
  # Combine with header row
  if(!is.null(activities_df)) {
    return(rbind(
      params_df,
      data.frame(Parameter = "Activities", Value = "Prob"),
      activities_df
    ))
  } else {
    return(params_df)
  }
}

# Flatten the events file for export to Excel

flatten_events <- function(events) {
  event_rows <- list()
  for(run_num in seq_along(events)) {
    run_events <- events[[run_num]]
    if(length(run_events) > 0) {
      for(event_num in seq_along(run_events)) {
        event <- run_events[[event_num]]
        row <- data.frame(
          Run = run_num,
          Event = event_num,
          Severity = event$severity
        )
        # Add binary columns for each activity
        for(activity in names(event$affectsActivities)) {
          row[[activity]] <- as.integer(event$affectsActivities[[activity]])
        }
        event_rows[[length(event_rows) + 1]] <- row
      }
    }
  }
  
  if(length(event_rows) > 0) {
    return(do.call(rbind, event_rows))
  } else {
    return(data.frame(Run = integer(), Event = integer(), Severity = numeric()))
  }
}

# Add outputs for checks
  
  
