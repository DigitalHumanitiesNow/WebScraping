library("readr")
library("dplyr")
library("rvest")
library("stringr")

data <- read_csv("dhnow-unfiltered-2015-05-19.csv")

data <- data %>%
  mutate(content_length = str_length(entry_content)) %>%
#   mutate(text_to_use = ifelse(content_length > 0,
#                               entry_content,
#                               entry_summary)) %>%
#   mutate(text_length = str_length(text_to_use)) %>%
  filter(content_length > 0)


cleaning <- function(dirtytext) {

    plain <- try(
      dirtytext %>%
        html() %>%
        html_text()
    )

    if (!class(plain) == "try-error") {
      plain %>%
        str_replace_all("\n", " ") %>%
        str_replace_all("view in full screen", "")
    } else {
      dirtytext %>%
        str_replace_all("\n", " ") %>%
        str_replace_all("view in full screen", "")
    }
}

if(!dir.exists("inputs")) dir.create("inputs")

clean_texts <- data$entry_content %>%
  lapply(cleaning)

for (i in seq_len(length(clean_texts))) {
  writeLines(clean_texts[[i]], str_c("inputs/", i, ".txt"))
}
