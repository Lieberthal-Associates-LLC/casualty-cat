# Given R output, export to CSV files

# Bring in openxlsx2 package

import(openxlsx2)
import(utils)

# Create a CSV file in the given output path
create_CSV <- function(fileName, outputPath) {
  
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

# Add CSVs for inputs

# Add CSVs for interim results

# Add CSVs for simulation outputs

# Generic for data.frames

export_CSV <- function(outputName, outputDir) {
  path <- file.path(outputDir, paste0(outputName, ".csv"))
  utils::write.csv(get(outputName), path, row.names = FALSE)
  cat("Wrote", basename(path), "\n")
}

# Flatten events

flatten_events <- function(events) {
  rows <- list()
  run_num <- 1
  for(run_events in events) {
    if(length(run_events) > 0) {
      for(event_num in seq_along(run_events)) {
        event <- run_events[[event_num]]
        active_acts <- names(event$affectsActivities)[event$affectsActivities]
        row <- data.frame(
          Run = run_num,
          Event = event_num,
          Severity = event$severity,
          ActiveActivities = if(length(active_acts)>0) paste(active_acts, collapse=", ") else ""
        )
        rows[[length(rows)+1]] <- row
      }
    }
    run_num <- run_num + 1
  }
  do.call(rbind, rows)
}

export_matrix_list <- function(obj_name, output_dir) {
  obj <- get(obj_name, envir = globalenv())
  path <- file.path(output_dir, paste0(obj_name, ".csv"))
  con <- file(path, "w")
  for(run_num in seq_along(obj)) {
    mat <- obj[[run_num]]
    writeLines(sprintf("Run %d", run_num), con)
    utils::write.csv(mat, con, row.names = TRUE)
    writeLines("", con)
  }
  close(con)
  cat("Wrote", basename(path), "\n")
}

#' Master exporter for all simulation outputs
#' 
#' Exports parameters/policies/compExposures as simple CSVs,
#' events as flattened data frame, losses/payouts as Run-block matrices.
#' 
#' @param output_dir Directory to write CSVs (default: "output")
batch_export <- function(output_dir = "output") {
  # Simple data frames
  simple_objs = c("parameters", "policies", "compExposures")
  for(name in simple_objs) {
    write.csv(get(name, parent.frame()), 
              file.path(output_dir, paste0(name, ".csv")), 
              row.names = FALSE)
    cat("Wrote", name, ".csv\n")
  }
  
  # Events (flatten)
  events_flat <- flatten_events(get("events", parent.frame()))
  write.csv(events_flat, file.path(output_dir, "events.csv"), row.names = FALSE)
  cat("Wrote events.csv (flattened)\n")
  
  # Matrix lists (Run blocks)
  matrix_objs = c("losses", "payouts")
  for(name in matrix_objs) {
    export_matrix_list(name, output_dir)
  }
  
  cat("All exports complete to", output_dir, "\n")
}

