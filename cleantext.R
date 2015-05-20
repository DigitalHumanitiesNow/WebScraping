library("readr")
library("xml2")
library("dplyr")
library("rvest")
data <- read_csv("dhnow-unfiltered-2015-05-19.csv")

cleaning <- function(dirtytext) {
  text1 <- html(dirtytext)
  text1 <- html_text(text1)
  return (text1)
}

newdata <- data %>% mutate(cleantext = cleaning(entry_content))
newdata <- newdata %>% select(-entry_content)
write.csv(newdata, file="dhnow-unflitered-2015-05-20_cleaned.csv")
text1 <- as.character(text1)
x <- read_html(text1)
xml_text(text1)
xml_text(xml_children(x))
