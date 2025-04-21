# This is the workflow to reproduce the results of the DSA 595 project by
# Name: Zhen He

# Step 1: Process and explore data
Rscript eda_script.r

# Step 2: Run model simulation with multiple seeds
for seed in {1..10}
do
  Rscript run_file.r $seed
done

# Step 3: Aggregate results and compute performance metrics
Rscript out_file.r