library(mallet)
library(tm)
library(dplyr)
library(readr)

choice <- mallet.read.dir("editors-choice/")
inputs <- mallet.read.dir("inputs/")

inst <- mallet.import(c(choice$id, inputs$id),
                      c(choice$text, inputs$text),
                      "stopwords.txt")

topic_model <- MalletLDA(num.topics = 40)
topic_model$loadDocuments(inst)
topic_model$setAlphaOptimization(20, 50)

topic_model$train(200)
topic_model$maximize(10)

doc.topics <- mallet.doc.topics(topic_model, smoothed = T, normalized = T)

class <- rep("nonchoice", length = nrow(doc.topics))
class[1:length(choice$id)] <- "choice"
filenames <- c(choice$id, inputs$id)
doc.topics <- cbind(doc.topics, class, filenames)
doc.topics <- as.data.frame(doc.topics)
write_csv(doc.topics, "docs-by-topics.csv")
