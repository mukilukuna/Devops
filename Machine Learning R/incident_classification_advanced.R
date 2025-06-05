# Machine Learning Project: Incident classification

# Generate synthetic dataset similar to MSP support tickets
set.seed(2025)

n <- 300

Prioriteit <- sample(c("Hoog","Gemiddeld","Laag"), n, replace=TRUE, prob=c(0.2,0.5,0.3))
Aanvraagtype <- sample(c("Incident","Verzoek","Onderhoud"), n, replace=TRUE, prob=c(0.6,0.3,0.1))
Systeem <- sample(c("Windows","Netwerk","Software","Hardware","Printer"), n, replace=TRUE,
                  prob=c(0.3,0.2,0.2,0.2,0.1))
Uur <- sample(0:23, n, replace=TRUE)
Minuut <- sample(0:59, n, replace=TRUE)

# Beschrijving op basis van type en systeem
Beschrijving <- character(n)
for (i in seq_len(n)) {
  if (Aanvraagtype[i] == "Incident") {
    if (Systeem[i] == "Printer") {
      Beschrijving[i] <- "Printer print niet uit"
    } else if (Systeem[i] == "Netwerk") {
      Beschrijving[i] <- "Geen internet verbinding"
    } else if (Systeem[i] == "Software") {
      Beschrijving[i] <- "Foutmelding in applicatie"
    } else if (Systeem[i] == "Windows") {
      Beschrijving[i] <- "Windows loopt vast"
    } else {
      Beschrijving[i] <- "Hardware defect"
    }
  } else {
    Beschrijving[i] <- "Aanvraag voor installatie of onderhoud"
  }
}

# Categorie toewijzen (met extra variatie bij 'Onderhoud')
Categorie <- character(n)
for (i in seq_len(n)) {
  if (Aanvraagtype[i] == "Onderhoud") {
    Categorie[i] <- "Software"
  } else {
    if (Systeem[i] %in% c("Hardware","Printer")) {
      Categorie[i] <- "Hardware"
    } else if (Systeem[i] %in% c("Software","Windows")) {
      Categorie[i] <- "Software"
    } else {
      Categorie[i] <- "Netwerk"
    }
  }
}

tickets <- data.frame(Prioriteit, Aanvraagtype, Systeem, Uur, Minuut, Beschrijving, Categorie,
                      stringsAsFactors = FALSE)

tickets$Prioriteit <- factor(tickets$Prioriteit, levels=c("Laag","Gemiddeld","Hoog"))
tickets$Aanvraagtype <- factor(tickets$Aanvraagtype, levels=c("Incident","Verzoek","Onderhoud"))
tickets$Systeem <- factor(tickets$Systeem, levels=c("Windows","Netwerk","Software","Hardware","Printer"))
tickets$Categorie <- factor(tickets$Categorie, levels=c("Hardware","Software","Netwerk"))
# Add text length as additional numeric feature
tickets$OmschrijvingLengte <- nchar(tickets$Beschrijving)

# Voeg 10% willekeurige labelruis toe
aantal_ruis <- round(0.1 * nrow(tickets))
ruis_idx <- sample(seq_len(nrow(tickets)), aantal_ruis)

categorien <- c("Hardware","Software","Netwerk")
tickets$Categorie[ruis_idx] <- sample(categorien, aantal_ruis, replace=TRUE)

# Split data in train en test sets
set.seed(2025)
train_idx <- sample(seq_len(nrow(tickets)), size = 0.7 * nrow(tickets))
train_data <- tickets[train_idx, ]
test_data  <- tickets[-train_idx, ]

# Train beslissingsboom
library(rpart)

model <- rpart(Categorie ~ Prioriteit + Aanvraagtype + Systeem + Uur + Minuut,
               data = train_data, method = "class")

# Voorspel categorie op testset
voorspellingen <- predict(model, test_data, type = "class")

# Confusiematrix en accuracy
confusie <- table(Voorspeld = voorspellingen, Werkelijk = test_data$Categorie)
print(confusie)

accuracy <- mean(voorspellingen == test_data$Categorie)
cat(sprintf("Accuracy: %.2f%%\n", accuracy * 100))

# Train a random forest model with 5-fold cross-validation
library(caret)
library(randomForest)
set.seed(2025)
control <- trainControl(method = "cv", number = 5)
rf_model <- train(Categorie ~ Prioriteit + Aanvraagtype + Systeem + Uur + Minuut + OmschrijvingLengte,
                  data = train_data, method = "rf", trControl = control)
rf_predictions <- predict(rf_model, test_data)
rf_confusion <- table(Voorspeld = rf_predictions, Werkelijk = test_data$Categorie)
print(rf_confusion)
rf_accuracy <- mean(rf_predictions == test_data$Categorie)
cat(sprintf("Random Forest Accuracy: %.2f%%\n", rf_accuracy * 100))

# Bereken precisie, recall en F1-score per klasse
f1 <- function(p, r) ifelse(p + r == 0, 0, 2 * (p * r) / (p + r))
class_metrics <- data.frame(Klasse = levels(test_data$Categorie),
                            Precision = numeric(3),
                            Recall = numeric(3),
                            F1 = numeric(3))
for(i in seq_along(class_metrics$Klasse)) {
  cls <- class_metrics$Klasse[i]
  tp <- sum(rf_predictions == cls & test_data$Categorie == cls)
  fp <- sum(rf_predictions == cls & test_data$Categorie != cls)
  fn <- sum(rf_predictions != cls & test_data$Categorie == cls)
  precision <- tp / (tp + fp)
  recall <- tp / (tp + fn)
  class_metrics$Precision[i] <- precision
  class_metrics$Recall[i] <- recall
  class_metrics$F1[i] <- f1(precision, recall)
}
print(class_metrics)

# Voorbeeld van K-means clustering op trainingsdata
features <- data.frame(
  Prioriteit_num = as.integer(train_data$Prioriteit),
  Aanvraagtype_num = as.integer(train_data$Aanvraagtype),
  Systeem_num = as.integer(train_data$Systeem),
  Uur = train_data$Uur,
  Minuut = train_data$Minuut,
  OmschrijvingLengte = train_data$OmschrijvingLengte
)

set.seed(2025)
km <- kmeans(features, centers = 3)

cluster_tab <- table(Cluster = km$cluster, Categorie = train_data$Categorie)
print(cluster_tab)

# Hierarchical clustering as alternative
dist_mat <- dist(scale(features))
hc <- hclust(dist_mat, method = "ward.D2")
hc_clusters <- cutree(hc, k = 3)
hc_tab <- table(HC_Cluster = hc_clusters, Categorie = train_data$Categorie)
print(hc_tab)
