```{r}
#| message: false

library(nhlscraper)
library(dplyr)
library(purrr)
library(tidyverse)

# --- 1. Define the Scraper Function ---
get_sog_leader <- function(season_code) {
  Sys.sleep(0.5) # Pause to be polite to API
  tryCatch({
    stats <- get_skater_statistics(season = season_code, game_type = 2)
    
    if ("shots" %in% names(stats)) {
      stats %>%
        mutate(shots = as.numeric(shots)) %>%
        arrange(desc(shots)) %>%
        slice(1) %>%
        select(seasonId, skaterFullName, playerId, shots)
    } else {
      return(NULL)
    }
  }, error = function(e) return(NULL))
}

# --- 2. Run the Loop (With Progress) ---
seasons <- paste0(1959:2023, 1960:2024)
message("Starting scrape... please wait.")

sog_leaders_history <- map_dfr(seasons, function(s) {
  message(paste("Scraping:", s)) # This shows you it's working!
  get_sog_leader(s)
})

# --- 3. Save to CSV immediately ---
write.csv(sog_leaders_history, "sog_leaders_history.csv", row.names = FALSE)
message("SUCCESS: File 'sog_leaders_history.csv' has been saved!")
```
