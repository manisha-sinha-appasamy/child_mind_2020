#!/bin/bash
#SBATCH --job-name="HBN_EEG"
#SBATCH --output="HBN_EEG.out"
#SBATCH --partition=compute
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=4
#SBATCH --export=ALL
#SBATCH -t 48:00:00
#SBATCH --mail-user=adelorme@ucsd.edu
#SBATCH --mail-type=begin
#SBATCH --mail-type=end
source ~/.bashrc
aws s3 sync s3://fcp-indi/data/Archives/HBN/EEG/ /projects/ps-nemar/child-mind --no-sign-request
