#!/bin/bash
path="/home/liam/UDel/Test_Memb_Extracter/pdb_files"
nfiles=$(ls ${path} | wc -l)
ij=$(echo "sqrt($nfiles)-1" | bc)

set -e

for i in `seq 0 ${ij}`; do
	for j in `seq 0 ${ij}`; do
		vmd -dispdev text -e TCL_InptArg.tcl -args "${path}/pro_${i}${j}.pdb" "${i}" "${j}"
	done
done