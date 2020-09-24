#!/bin/bash
#SBATCH --job-name="HBN_EEG_unzip"
#SBATCH --output="HBN_EEG_unzip.out"
#SBATCH --partition=shared
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --export=ALL
#SBATCH -t 48:00:00
#SBATCH --mail-user=adelorme@ucsd.edu
#SBATCH --mail-type=begin
#SBATCH --mail-type=end
#SBATCH -A TG-IBN140002
source ~/.bashrc
cd /projects/ps-nemar/child-mind; cat *.tar.gz | tar zxvf - -i --verbose --exclude=/EEG/preprocessed  --exclude=._*
