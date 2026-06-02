#!/bin/bash
#SBATCH --job-name=sparvus_final_stats
#SBATCH --output=sparvus_final_stats_%j.out
#SBATCH --error=sparvus_final_stats_%j.err
#SBATCH --time=48:00:00
#SBATCH --cpus-per-task=8
#SBATCH --mem=256G
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=kfloer@smith.edu
