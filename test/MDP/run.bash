#!/bin/bash
#SBATCH -J s21_1                 
#SBATCH -o s21_1_out           
#SBATCH -p skx-normal           
#SBATCH -N 4                    
#SBATCH -n 192                  
#SBATCH -t 47:50:00             
#SBATCH --mail-user=aleon@udel.edu
#SBATCH --mail-type=end          

set OMP_NUM_THREADS=1
export OMP_NUM_THREADS=1

module load intel/18.0.2
module load impi/18.0.2
module load gromacs/2018.3

#gmx pdb2gmx -f s21.pdb -o s21_real.gro -p s21_real.top -ff charmm36-mar2019
#wait
gmx grompp -f ./MDP/run.mdp -c step6.6_equilibration.gro -p topol.top -maxwarn 5 -o run.tpr

wait
ibrun -np 192 ${TACC_GROMACS_BIN}/mdrun_mpi -s run.tpr -o run1 -mp topol.top  -c dyn1.gro  \
