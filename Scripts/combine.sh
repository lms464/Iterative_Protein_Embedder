#!/bin/bash

## TODO at the end of TCL scripts have a return -1 or 1
## bash reads the file for that value
## TODO for dealing with various membrane frames try:
## having an input array or a file containing 
## various membrane traj stored as pdb names


## global variables ####

## I did not know bash returned 0 if it passes!
## Accept and error are changed to reflect that
ACCEPT=0
ERROR=1

## Paths for existing folders and files
## Required to build systems
path="/Censere/github/Iterative_Protein_Embedder/test"
path_def="/home/liam/Censere/github/Iterative_Protein_Embedder/test/def"
path_top="/home/liam/Censere/github/Iterative_Protein_Embedder/test/toppar"

## File intiation for logs and errors
LOG="test.log"
Err_Log="test.err"
touch test.log
touch test.err

# date the log files
date >> ${LOG}
date >> ${Err_Log}

#######################

### Functions #########

## File Utility functions, build and move files
make_embedded_folder () {

	local result=0
	if [ -d "${embd_dir}" ] 
	then
	    echo "Directory ${embd_dir} exists." 
	    echo "Check to confirm if the directory is populated."
	    echo "Re-printed in error log"
	    result=${ERROR}
	else
	    mkdir ${embd_dir}
	    result=${ACCEPT}
	fi
	echo ${result}
	return ${result}
}

get_toppar () {
	# Where is ""
	cp -r ${path_top} ${embd_dir}
}

get_default_pdbs () {
	# get alligned protein.pdb/.psf
	# get membrane.pdb/psf
	# need to consider having various membranes

	cp -r ${path_def} ${embd_dir}
}

## Simulation Utility, manipulate membrane
## make and move run files
bin_memb_build_prot () {
	# based off a refference build memb_prot.pdb
	# predict number of bins
	# write pdb's of prot for each bin

	echo "vmd -dispdev text -e Membrane_Binner.tcl" >> ${LOG}
	return ${ACCEPT}
}

combine_tcl () {
	# if none -> write reference memb_prot
	# otherwise, combine prot for specific bin
	# and membrane

	local ii=${i}
	local jj=${j}
	if [ "${ii}" = "None" ] || [ "${jj}" = "None" ]
	then
		echo "vmd -dispdev text -e TCL_InptArg.tcl -args #{path_def}/protein_aligned.pdb ${ii} ${jj}" >> ${LOG}
	else
		pro="${path}/pro_${ii}${jj}.pdb"
		echo "vmd -dispdev text -e TCL_InptArg.tcl -args ${pro} ${ii} ${jj}" >> ${LOG}
 	fi
 	unset ii
 	unset jj
 	return ${ACCEPT}
}


gmx_pdb2gmx () {
	# get protein itps
	# don't run for things besides protein

	local ii=${i}
	local jj=${j}
	pro="${path}/pro_${ii}${jj}.pdb"
	echo "gmx pdb2gmx -f ${pro} < ../Utils/ff_wat.dat" >> ${LOG}
	unset ii
 	unset jj
	return ${ACCEPT} 
}

addCrystal () {
	# Run the CHARMM-GUI script
	# to add pbc box dimensions 
	# back in
	local ii=${i}
	local jj=${j}
	pro="${path}/pro_${ii}${jj}.pdb"
	echo "python addCrystal.py -i ${pro} -cryst 0.00 0.00 0.00 90.00 90.00 90.00" >> ${LOG}
	# Ohhhgod right this
	# I don't have a plan here yet...

	unset ii
 	unset jj
 	return ${ACCEPT} 
}
########################

#### TESTING ####

## This block should initialize
## The reference combied memb-prot
i="None"
j="None"
combine_tcl

if [ $? != ${ACCEPT} ]; then
	echo "Could not merge initial protein and membrane. Exiting" >> ${Err_Log}
	exit 1
fi
exit 1
bin_memb_build_prot

if [ $? != ${ACCEPT} ]; then
	echo "Could not bin membrane. Exiting" >> ${Err_Log}
	exit 1
fi

## Build the systems en-mass
echo "Starting Loop"
echo ""
echo ""
for i in `seq 0 1`;
do
	for j in `seq 0 1`;
	do 
		embd_dir="${path}/prot_memb_${i}${j}"
		
		make_embedded_folder 
		if [ $? != ${ACCEPT} ]; then
	    	echo "Fatal Error: Directory ${path}/prot_memb_${ii}${jj} exists." >> ${Err_Log}
	    	echo "    Check to confirm if the directory is populated." >> ${Err_Log}
	    	exit 1
		fi
		get_toppar 
		if [ $? != ${Accept} ]; then
			echo "Error: Did not move the topology directory" >> ${Err_Log}
			exit 1
		fi
		get_default_pdbs 
		if [ $? != ${Accept} ]; then
			echo "Error: Did not move the initial pdbs" >> ${Err_Log}
			exit 1
		fi
		gmx_pdb2gmx
		if [ $? != ${ACCEPT} ]; then
			echo "Error: gmx_pdb2gmx failed at pro_${i}${j}.pdb" >> ${Err_Log}
			exit 1
		fi
		combine_tcl
		if [ $? != ${ACCEPT} ]; then
			echo "Error: combine_tcl failed at combining pro_${i}${j}.pdb and membrane.pdb" >> ${Err_Log}
			exit 1
		fi
		addCrystal
		if [ $? != ${ACCEPT} ]; then
			echo "Error: addCrystal failed at protein_mem_${i}${j}.pdb" >> ${Err_Log}
			exit 1
		fi
	done
done
################
