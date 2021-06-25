#!/bin/bash

## TODO at the end of TCL scripts have a return -1 or 1
## bash reads the file for that value
## TODO for dealing with various membrane frames try:
## having an input array or a file containing 
## various membrane traj stored as pdb names


## global variables ####

## activation state IN or AC 
act=$1

if [ -z ${act} ] ; then
	echo "No activation state has been declared."
	echo "please declare:"
	echo ""
	echo "    AC (Active)"
	echo "    IN (Inactive)"
	echo ""
	read -p "Please choose a state" act

	if [ -z ${act} ] ; then
		echo ""
		echo "Really? REALLY? No input? Exiting"
		echo ""
		exit 0
	fi 

fi


## I did not know bash returned 0 if it passes!
## Accept and error are changed to reflect that
ACCEPT=0
ERROR=1

## Paths for existing folders and files
## Required to build systems
SCRIPTS="/home/liam/Censere/github/Iterative_Protein_Embedder/Scripts"
path="/Censere/github/Iterative_Protein_Embedder/test"
path_def="/home/liam/Censere/github/Iterative_Protein_Embedder/test/def"
path_top="/home/liam/Censere/github/Iterative_Protein_Embedder/test/toppar"
path_pdb="/home/liam/Censere/github/Iterative_Protein_Embedder/test/pdb_files"
path_mdp="/home/liam/Censere/github/Iterative_Protein_Embedder/test/MDP"
UTILS="/Censere/github/Iterative_Protein_Embedder/Utils"
## File intiation for logs and errors
date=$(date '+%Y-%m-%d_%H.%M.%S')
LOG=${date}.log
Err_Log=${date}.err
touch ${LOG}
touch ${Err_Log}

# date the log files
# date >> ${LOG}
# date >> ${Err_Log}

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
	    mkdir ${embd_dir} #>> ${LOG} 
	    result=${ACCEPT}
	fi
	echo ${result}
	return ${result}
}

get_toppar () {
	# Where is ""
	cp -r ${path_top} ${embd_dir} >> ${LOG}
}

get_mdb () {
	cp -r ${path_mdp} ${embd_dir}
	cp ${embd_dir}/MDP/*.bash ${embd_dir}
}

get_default_pdbs () {
	# get alligned protein.pdb/.psf
	# get membrane.pdb/psf
	# need to consider having various membranes
	local ii=${i}
	local jj=${j}
	cp -r ${path_def} ${embd_dir} >> ${LOG} 
	cp ${path_pdb}/pro_${ii}${jj}.pdb ${embd_dir} >> ${LOG}
	unset ii
	unset jj
}

## Simulation Utility, manipulate membrane
## make and move run files
bin_memb_build_prot () {
	# based off a refference build memb_prot.pdb
	# predict number of bins
	# write pdb's of prot for each bin

	vmd -dispdev text -e Membrane_Binner.tcl -args ${act} >> ${LOG}
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
		vmd -dispdev text -e ${UTILS}/TCL_InptArg.tcl -args c ${ii} ${jj} ${act} >> ${LOG}
	else
		pro=${embd_dir}/pro_${ii}${jj}.pdb
		vmd -dispdev text -e ${UTILS}/TCL_InptArg.tcl -args c ${ii} ${jj} ${act} >> ${LOG}
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
	cp ${path_pdb}/pro_${ii}${jj}.pdb ${embd_dir}
	cd ${embd_dir}
	gmx pdb2gmx -f ./pro_${ii}${jj}.pdb -i ./toppar/ -o ./toppar/prot.pdb -p ./toppar/toppar.top -ignh < ${UTILS}/ff_wat.dat >> ${LOG}
	cd ${SCRIPTS}
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
	#cp ${UTILS}/addCrystPdb.py ${embd_dir}
	#cd ${embd_dir}
	pro="${embd_dir}/protein_mem${ii}${jj}.pdb"
	python ${UTILS}/addCrystPdb.py -i ${pro} -cryst ${embd_dir}/def/input.config.dat >> ${LOG}
	#cd ${SCRIPTS}
	# Ohhhgod right this
	# I don't have a plan here yet...

	unset ii
 	unset jj
 	return ${ACCEPT} 
}

build_top () {
	local ii=${i}
	local jj=${j}
	#pro="${embd_dir}/protein_mem${ii}${jj}.pdb"
	#vmd -dispdev text -e ${UTILS}/TCL_InptArg.tcl -args t ${pro} ${ii} ${jj}>> ${LOG}
	python ${UTILS}/parse.py ${embd_dir} ${ii} ${jj}
	unset ii
 	unset jj
 	return ${ACCEPT} 
}

add_ions () {
	local ii=${i}
	local jj=${j}
	pro="${embd_dir}/protein_mem${ii}${jj}"
	vmd -dispdev text -e ${UTILS}/TCL_InptArg.tcl -args i ${pro} ${ii} ${jj}>> ${LOG}
	unset ii
 	unset jj
 	return ${ACCEPT} 
}
########################

#### TESTING ####

## This block should initialize
## The reference combied memb-prot

if [[ ${act} == "IN" ]]; 
then
	init_prot="IN_protein_aligned.pdb"
elif [[ ${act} == "AC" ]];
then
	init_prot="AC_protein_aligned.pdb"
fi

i="None"
j="None"

echo "Initializing files" >> ${LOG}
echo "Constructing reference combined protein membrane pdb and psf" >> ${LOG}
echo "" >> ${LOG}
echo "" >> ${LOG}
echo "" >> ${LOG}

combine_tcl
if [ $? != ${ACCEPT} ]; then
	echo "Could not merge initial protein and membrane. Exiting" >> ${Err_Log}
	exit 1
fi

echo "Predicting number of membranes and building moved proteins" >> ${LOG}
echo "" >> ${LOG}
echo "" >> ${LOG}
echo "" >> ${LOG}

bin_memb_build_prot
if [ $? != ${ACCEPT} ]; then
	echo "Could not bin membrane. Exiting" >> ${Err_Log}
	exit 1
fi

## Determine the number of protein
## placemnt pdbs to iterate through
## *assumes sqrt-able number*
nfiles=$(ls ${path_pdb} | wc -l)
ij=$(echo "sqrt($nfiles)-1" | bc)

## Build the systems en-mass
echo "Starting Loop" >> ${LOG}
echo "" >> ${LOG}
echo "" >> ${LOG}
for i in `seq 0 0` #${ij}`;
do
	for j in `seq 0 0` #${ij}`;
	do 
		echo "Building iteration ${i} ${j}"
		embd_dir="${path}/prot_memb_${i}${j}"
		echo "${embd_dir}"
		
		make_embedded_folder 
		if [ $? != ${ACCEPT} ]; then
	    	echo "Fatal Error: Directory ${path}/prot_memb_${ii}${jj} exists." >> ${Err_Log}
	    	echo "    Check to confirm if the directory is populated." >> ${Err_Log}
	    	exit 1
		fi
		get_toppar 
		if [ $? != ${ACCEPT} ]; then
			echo "Error: Did not move the topology directory" >> ${Err_Log}
			exit 1
		fi
		get_default_pdbs 
		if [ $? != ${ACCEPT} ]; then
			echo "Error: Did not move the initial pdbs" >> ${Err_Log}
			exit 1
		fi
		### gmx_pdb2gmx
		### if [ $? != ${ACCEPT} ]; then
		### 	echo "Error: gmx_pdb2gmx failed at pro_${i}${j}.pdb" >> ${Err_Log}
		### 	exit 1
		## fi
		
		combine_tcl
		if [ $? != ${ACCEPT} ]; then
			echo "Error: combine_tcl failed at combining pro_${i}${j}.pdb and membrane.pdb" >> ${Err_Log}
			exit 1
		fi
		add_ions
		if [ $? != ${ACCEPT} ]; then
			echo "Error: add_ions failed at adding ions to protein_mem${i}${j}.pdb and membrane.pdb" >> ${Err_Log}
			exit 1
		fi
		# addCrystal
		# #TODO move a addCrystal.py to each file.. might need to cd into the file
		# if [ $? != ${ACCEPT} ]; then
		# 	echo "Error: addCrystal failed at protein_mem${i}${j}.pdb" >> ${Err_Log}
		# 	exit 1
		# fi
		# build_top
		# if [ $? != ${ACCEPT} ]; then
		# 	echo "Error: build_top failed at protein_mem${i}${j}.pdb" >> ${Err_Log}
		# 	exit 1
		# fi
		# get_mdb

	done
done
################
