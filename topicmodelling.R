library(mallet)
library(tm)
library(dplyr)
library(readr)

choice <- mallet.read.dir("editors-choice/")
inputs <- mallet.read.dir("inputs/")

stops <- stopwords("english")
stops_file <- file("stopwords.txt")
writeLines(stops, stops_file)
close(stops_file)

inst <- mallet.import(c(choice$id, inputs$id),
                      c(choice$text, inputs$text),
                      "stopwords.txt")

topic_model <- MalletLDA(num.topics = 40)
topic_model$loadDocuments(inst)
topic_model$setAlphaOptimization(20, 50)


freq <- mallet.word.freqs(topic_model)
freq %>%
  arrange(-term.freq) %>%
  top_n(20)

freq %>%
  arrange(-doc.freq) %>%
  top_n(20)

topic_model$train(200)
topic_model$maximize(10)

doc.topics <- mallet.doc.topics(topic_model, smoothed = T, normalized = T)

class <- rep("nonchoice", length = nrow(doc.topics))
class[1:length(choice$id)] <- "choice"

filenames <- c(choice$id, inputs$id)

doc.topics <- cbind(doc.topics, class, filenames)

View(doc.topics)

write_csv(doc.topics, "docs-by-topics.csv")
