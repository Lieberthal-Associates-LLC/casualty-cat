#Given the simulation run, export results to Excel 

import(openxlsx2)

export("export_simulation_results")
export_simulation_results <- function(outputPath, compExposures, policies, parameters, 
                                      events, losses, payouts) {
  wb <- wb_workbook()
  
  add_data_sheet(wb, "compExposures", compExposures, row_names = TRUE)
  add_data_sheet(wb, "policies", policies, row_names = TRUE)
  add_data_sheet(wb, "parameters", as.data.frame(parameters), row_names = FALSE)
  add_events_sheet(wb, events)
  add_data_sheet(wb, "losses", flatten_losses(losses), row_names = FALSE)
  add_data_sheet(wb, "payouts", flatten_payouts(payouts), row_names = FALSE)
  add_results_sheet(wb, events, losses, payouts)
  
  wb$save(outputPath)
  cat("Excel file created:", outputPath, "\n")
  return(invisible(wb))
}


add_data_sheet <- function(wb, sheetName, data, row_names = FALSE) {
  wb$add_worksheet(sheetName)
  wb$add_data(sheetName, data, row_names = row_names)
}

add_events_sheet <- function(wb, events) {
  events_df <- flatten_events(events)
  add_data_sheet(wb, "events", events_df, row_names = FALSE)
}

flatten_events <- function(events) {
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
  
  do.call(rbind, lapply(seq_along(events), function(run_idx) {
    if(length(events[[run_idx]]) > 0) {
      do.call(rbind, lapply(seq_along(events[[run_idx]]), function(event_idx) {
        event <- events[[run_idx]][[event_idx]]
        row_data <- list(Run = run_idx, Event_Index = event_idx, 
                         Severity = if(!is.null(event$severity)) event$severity else NA)
        for(activity_name in all_activity_names) {
          if(!is.null(event$affectsActivities) && activity_name %in% names(event$affectsActivities)) {
            row_data[[activity_name]] <- as.integer(event$affectsActivities[activity_name])
          } else {
            row_data[[activity_name]] <- 0
          }
        }
        data.frame(row_data, row.names = NULL)
      }))
    }
  }))
}

flatten_losses <- function(losses) {
  do.call(rbind, lapply(seq_along(losses), function(i) {
    if(length(losses[[i]]) > 0) {
      data.frame(Run = i, Loss_Index = seq_along(losses[[i]]), Loss_Value = losses[[i]], row.names = NULL)
    }
  }))
}

flatten_payouts <- function(payouts) {
  do.call(rbind, lapply(seq_along(payouts), function(i) {
    if(length(payouts[[i]]) > 0) {
      data.frame(Run = i, Payout_Index = seq_along(payouts[[i]]), Payout_Value = payouts[[i]], row.names = NULL)
    }
  }))
}

add_results_sheet <- function(wb, events, losses, payouts) {
  # placeholder for now
  wb$add_worksheet("results")
}


