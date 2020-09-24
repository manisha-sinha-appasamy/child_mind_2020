#!/bin/bash
#SBATCH --job-name="Child Mind DL"
#SBATCH --output="Child_mind.%j.%N.out"
#SBATCH --partition=gpu-shared
#SBATCH --gres=gpu:k80:1
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=6
#SBATCH --export=ALL
#SBATCH -t 1:00:00
#SBATCH --mail-user=adelorme@ucsd.edu
#SBATCH --mail-type=begin
#SBATCH --mail-type=end
#SBATCH -A TG-IBN140002
source ~/.bashrc
cd /projects/ps-nemar/child_mind_2020
module load matlab
matlab -nodisplay -nosplash -nodesktop < /projects/ps-nemar/child_mind_2020/RestingState.m
