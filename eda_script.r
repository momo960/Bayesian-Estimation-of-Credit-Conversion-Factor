# eda_script.R

# these libraries are used for graphs
library(ggplot2)
library(dplyr)
library(readr)
library(ggcorrplot)
library(rlang)

raw_path <- "/Users/hezhen/Desktop/credit_risk_model/accepted_2007_to_2018Q4.csv"
df <- read_csv(raw_path, show_col_types = FALSE)

# keep defaulted observations
defaulted <- df %>%
  filter(loan_status %in% c("Charged Off", "Does not meet the credit policy. Status:Charged Off"))

# compute Credit Conversion Factor
defaulted <- defaulted %>%
  mutate(CCF = (funded_amnt - total_rec_prncp) / funded_amnt)

# keep only variables of interest
columns_to_keep <- c('CCF', 'loan_amnt', 'int_rate', 'annual_inc', 'dti',
                     'revol_bal', 'revol_util', 'open_acc',  
                     'mo_sin_old_rev_tl_op',  'avg_cur_bal')

model_df <- defaulted %>%
  select(all_of(columns_to_keep)) %>%
  mutate(across(everything(), as.numeric)) %>%
  na.omit()

write_csv(model_df, "cleaned_lendingclub_ccf_data.csv")

# ========== exploratory data analysis ==========
# summary stats
print(summary(model_df))

# hist of every variables
for (var in setdiff(names(model_df), "CCF")) {
  p <- ggplot(model_df, aes(x = !!sym(var))) +
    geom_histogram(bins = 30, fill = "steelblue", color = "white") +
    theme_minimal() +
    labs(title = paste("Histogram of", var), x = var, y = "Count")
  ggsave(paste0("hist_", var, ".png"), plot = p, width = 6, height = 4)
}

# CCF dist
p <- ggplot(model_df, aes(x = CCF)) +
  geom_histogram(bins = 30, fill = "steelblue", color = "white") +
  theme_minimal() +
  labs(title = "Distribution of CCF", x = "CCF", y = "Count")
ggsave("hist_CCF.png", plot = p, width = 6, height = 4)


# cor heatmap
cor_matrix <- cor(model_df, use = "complete.obs")
p <- ggcorrplot(cor_matrix, lab = TRUE, type = "lower")
ggsave("correlation_matrix.png", plot = p, width = 7, height = 6)

