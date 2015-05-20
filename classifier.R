library(caret)
library(mlbench)
library(magrittr)
data(Sonar)

set.seed(107)

in_train <- createDataPartition(y = Sonar$Class, p = 0.75, list = FALSE)

training <- Sonar[in_train, ]
testing  <- Sonar[-in_train, ]

ctrl <- trainControl(method = "repeatedcv",
                     repeats = 3,
                     classProbs = TRUE,
                     summaryFunction = twoClassSummary
                     )

# See names(getModelInfo()) for potential models
# or http://topepo.github.io/caret/bytag.html
model <- train(Class ~ .,
               data = training,
               method = "pls",
               preProc = c("center", "scale"),
               trControl = ctrl,
               metric = "ROC",
               tuneLength = 15
               )

model
plot(model)

predictions <- predict(model, newdata = testing)
predictions_prob <- predict(model, newdata = testing, type = "prob")

accuracy <- confusionMatrix(data = predictions, testing$Class)
