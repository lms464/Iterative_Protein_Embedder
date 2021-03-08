#!/bin/bash

## TODO at the end of TCL scripts have a return -1 or 1
## bash reads the file for that value

ACCEPT=1
ERROR=-1
path=""
LOG="test.log"
touch test.log
bin_memb_build_prot () {
	# based off a refference build memb_prot.pdb
	# predict number of bins
	# write pdb's of prot for each bin

	echo "vmd -dispdev text -e Membrane_Binner.tcl"
	echo "${ACCEPT}"
}

combine_tcl () {
	# if none -> write reference memb_prot
	# otherwise, combine prot for specific bin
	# and membrane

	local ii=${i}
	local jj=${j}
	if [ "${ii}" = "None" ] || [ "${jj}" = "None" ]
	then
		echo "vmd -dispdev text -e combine.tcl "protein_aligned.pdb" ${ii} ${jj}" >> ${LOG}
	else
		pro="${path}/pro_${ii}${jj}.pdb"
		echo "vmd -dispdev text -e combine.tcl ${pro} ${ii} ${jj}" >> ${LOG}
 	fi
 	unset ii
 	unset jj
 	echo "${ACCEPT}"
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
	echo "${ACCEPT}" 
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
 	echo "${ACCEPT}" 
}

#### TESTING ####
i="None"
j="None"
combine_tcl
bin_memb_build_prot

echo "Starting Loop"
echo ""
echo ""
for i in `seq 0 4`;
do
	for j in `seq 0 4`;
	do 
		gmx_pdb2gmx
		combine_tcl
		addCrystal
	done
done
################
