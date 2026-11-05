
# Healthcare Workforce Data Analysis
# R version 4.6.2

# 1. Load the cleaned dataset

healthcare <- read.csv(
  file.choose(),
  stringsAsFactors = FALSE,
  na.strings = c("NULL", "")
)

# Take a first look at the data

head(healthcare)
dim(healthcare)
names(healthcare)
str(healthcare)


# 2. Prepare the variables for analysis

healthcare$shift_hours_per_week <-
  as.numeric(healthcare$shift_hours_per_week)

healthcare$burnout_score <-
  as.numeric(healthcare$burnout_score)

healthcare$department <- as.factor(healthcare$department)
healthcare$profession <- as.factor(healthcare$profession)
healthcare$burnout_category <- as.factor(healthcare$burnout_category)
healthcare$high_burnout_flag <- as.factor(healthcare$high_burnout_flag)

# Check for missing values

colSums(is.na(healthcare))


# 3. Explore the main variables

summary(healthcare$shift_hours_per_week)
summary(healthcare$burnout_score)

mean(healthcare$burnout_score)
median(healthcare$burnout_score)
sd(healthcare$burnout_score)

# Count employees by department and profession

table(healthcare$department)
table(healthcare$profession)

# Look at the burnout categories

table(healthcare$burnout_category)
table(healthcare$high_burnout_flag)

# Compare average working hours across departments

aggregate(
  shift_hours_per_week ~ department,
  data = healthcare,
  FUN = mean
)

# Calculate average burnout score for each department

department_burnout <- aggregate(
  burnout_score ~ department,
  data = healthcare,
  FUN = mean
)

department_burnout


# 4. Check the relationship between working hours and burnout

correlation_result <- cor.test(
  healthcare$shift_hours_per_week,
  healthcare$burnout_score,
  method = "pearson"
)

correlation_result


# 5. Compare burnout scores across departments

anova_result <- aov(
  burnout_score ~ department,
  data = healthcare
)

summary(anova_result)


# 6. Create and save the charts

dir.create("r_analysis/plots",
           showWarnings = FALSE,
           recursive = TRUE)

# Chart 1: Distribution of burnout scores

png("r_analysis/plots/burnout_distribution.png",
    width = 1000, height = 700)

hist(
  healthcare$burnout_score,
  main = "Distribution of Burnout Scores",
  xlab = "Burnout Score",
  ylab = "Number of Employees",
  col = "skyblue",
  border = "white"
)

dev.off()


# Chart 2: Number of employees in each burnout category

png("r_analysis/plots/burnout_categories.png",
    width = 1000, height = 700)

barplot(
  table(healthcare$burnout_category),
  main = "Burnout Categories",
  xlab = "Burnout Category",
  ylab = "Number of Employees",
  col = "lightgreen"
)

dev.off()


# Chart 3: Average burnout score by department

png("r_analysis/plots/average_burnout_by_department.png",
    width = 1000, height = 700)

barplot(
  department_burnout$burnout_score,
  names.arg = department_burnout$department,
  main = "Average Burnout Score by Department",
  xlab = "Department",
  ylab = "Average Burnout Score",
  col = "orange"
)

dev.off()


# Chart 4: Working hours and burnout scores

png("r_analysis/plots/hours_vs_burnout.png",
    width = 1000, height = 700)

plot(
  healthcare$shift_hours_per_week,
  healthcare$burnout_score,
  main = "Working Hours and Burnout Scores",
  xlab = "Working Hours per Week",
  ylab = "Burnout Score",
  pch = 19,
  col = "steelblue"
)

abline(
  lm(burnout_score ~ shift_hours_per_week,
     data = healthcare),
  col = "red",
  lwd = 2
)

dev.off()


# 7. Save the main statistical results

capture.output(
  {
    cat("Healthcare Workforce Data Analysis\n\n")
    
    cat("Dataset size:\n")
    print(dim(healthcare))
    
    cat("\nBurnout score summary:\n")
    print(summary(healthcare$burnout_score))
    
    cat("\nDepartment distribution:\n")
    print(table(healthcare$department))
    
    cat("\nProfession distribution:\n")
    print(table(healthcare$profession))
    
    cat("\nBurnout category distribution:\n")
    print(table(healthcare$burnout_category))
    
    cat("\nCorrelation results:\n")
    print(correlation_result)
    
    cat("\nANOVA results:\n")
    print(summary(anova_result))
  },
  file = "r_analysis/statistical_results.txt"
)

cat("Analysis finished. Charts and results have been saved.\n")

