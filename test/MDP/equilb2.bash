#!/bin/bash
#SBATCH -J s21_1                 
#SBATCH -o s21_1_out           
#SBATCH -p skx-dev         
#SBATCH -N 3                    
#SBATCH -n 144                  
#SBATCH -t 02:00:00             
#SBATCH --mail-user=aleon@udel.edu
#SBATCH --mail-type=end          

set OMP_NUM_THREADS=1
export OMP_NUM_THREADS=1

module load intel/18.0.2
module load impi/18.0.2
module load gromacs/2018.3


cd $SLURM_SUBMIT_DIR

#Replace below "em" by your input file name
#gmx grompp -f step6.1_equilibration.mdp -o step6.1_equilibration.tpr.out 
#mpirun -np $SLURM_NPROCS gmx_mpi mdrun -s step6.1_equilibration.tpr -o step6.1_equilibration.out 

gmx grompp -f ./MDP/step6.0_minimization.mdp -o step6.0_minimization.tpr -c step5_input.gro -r step5_input.gro -p topol.top
#wait
ibrun -np 144 ${TACC_GROMACS_BIN}/mdrun_mpi -c step6.0_minimization.gro -s step6.0_minimization.tpr -mp topol.top

# Equilibration
#set cnt    = 1
#set cntmax = 6

#while ( ${cnt} <= ${cntmax} )
#    @ pcnt = ${cnt} - 1
#    if ( ${cnt} == 1 ) then
gmx grompp -f ./MDP/step6.1_equilibration.mdp -o step6.1_equilibration.tpr -c step6.0_minimization.gro -r step5_input.gro -p topol.top
ibrun -np 144 ${TACC_GROMACS_BIN}/mdrun_mpi -c step6.1_equilibration.gro  -s step6.1_equilibration.tpr -mp topol.top 

         gmx grompp -f ./MDP/step6.2_equilibration.mdp -o step6.2_equilibration.tpr -c step6.1_equilibration.gro -r step5_input.gro -p topol.top
        ibrun -np 144 ${TACC_GROMACS_BIN}/mdrun_mpi -c step6.2_equilibration.gro  -s step6.2_equilibration.tpr -mp topol.top

         gmx grompp -f ./MDP/step6.3_equilibration.mdp -o step6.3_equilibration.tpr -c step6.2_equilibration.gro -r step5_input.gro -p topol.top
        ibrun -np 144 ${TACC_GROMACS_BIN}/mdrun_mpi -c step6.3_equilibration.gro  -s step6.3_equilibration.tpr -mp topol.top

         gmx grompp -f ./MDP/step6.4_equilibration.mdp -o step6.4_equilibration.tpr -c step6.3_equilibration.gro -r step5_input.gro -p topol.top
        ibrun -np 144 ${TACC_GROMACS_BIN}/mdrun_mpi -c step6.4_equilibration.gro  -s step6.4_equilibration.tpr -mp topol.top

         gmx grompp -f ./MDP/step6.5_equilibration.mdp -o step6.5_equilibration.tpr -c step6.4_equilibration.gro -r step5_input.gro -p topol.top
        ibrun -np 144 ${TACC_GROMACS_BIN}/mdrun_mpi -c step6.5_equilibration.gro  -s step6.5_equilibration.tpr -mp topol.top

         gmx grompp -f ./MDP/step6.6_equilibration.mdp -o step6.6_equilibration.tpr -c step6.5_equilibration.gro -r step5_input.gro -p topol.top
        ibrun -np 144 ${TACC_GROMACS_BIN}/mdrun_mpi -c step6.6_equilibration.gro  -s step6.6_equilibration.tpr -mp topol.top











#gmx grompp -f run.mdp -c step7.gro -p topol.top -maxwarn 5 -o run.tpr

#wait
#ibrun -np 192 ${TACC_GROMACS_BIN}/mdrun_mpi -s run.tpr -o run1 -mp topol.top  -c step7.gro  \
