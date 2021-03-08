#!/bin/bash

## TODO at the end of TCL scripts have a return -1 or 1
## bash reads the file for that value



# returning from bash food for thought

# #!/bin/bash

# my_function () {
#   echo "some result"
#   return 55
# }

# my_function
# echo $?



# my_function () {
#   func_result="some result"
# }

# my_function
# echo $func_result


## global variables ####
ACCEPT=1
ERROR=-1
path=""
LOG="test.log"
Err_Log="test.err"
touch test.log
touch test.err
# date the log files
date >> ${LOG}
date >> ${Err_Log}

#######################

### Functions #########

make_embedded_folder () {
	local ii=${i}
	local jj=${j}
	local result=0
	if [ -d "${path}/prot_memb_${ii}${jj}" ] 
	then
	    echo "Directory ${path}/prot_memb_${ii}${jj} exists." 
	    echo "Check to confirm if the directory is populated."
	    result=${ERROR}
	else
	    mkdir ${path}/prot_memb_${ii}${jj}
	    result=${ACCEPT}
	fi
	unset ii
	unset jj
	return result
}

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
		echo "vmd -dispdev text -e combine.tcl "protein_aligned.pdb" ${ii} ${jj}" >> ${LOG}
	else
		pro="${path}/pro_${ii}${jj}.pdb"
		echo "vmd -dispdev text -e combine.tcl ${pro} ${ii} ${jj}" >> ${LOG}
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
i="None"
j="None"
combine_tcl
bin_memb_build_prot
result=$?
if [ $result != ${ACCEPT} ]; then
	echo "Could not bin membrane. Exiting" >> ${Err_Log}
	exit 1
fi


echo "Starting Loop"
echo ""
echo ""
for i in `seq 0 4`;
do
	for j in `seq 0 4`;
	do 
		# error catching not working yet... see
		# notes at top of script
		gmx_pdb2gmx
		if [ $? != ${ACCEPT} ]; then
			echo "Error: gmx_pdb2gmx failed at pro_${i}${j}.pdb" >> ${Err_Log}
			exit 1
		fi

		make_embedded_folder
		if [$? != ${ACCEPT}]; then
	    	echo "Fatal Error: Directory ${path}/prot_memb_${ii}${jj} exists." >> ${Err_Log}
	    	echo "    Check to confirm if the directory is populated." >> ${Err_Log}
	    	exit 1
		fi

		combine_tcl
		if [ $? != ${ACCEPT} ]; then
			echo "Error: combine_tcl failed at pro_${i}${j}.pdb" >> ${Err_Log}
			exit 1
		fi
		addCrystal
		if [ $? != ${ACCEPT} ]; then
			echo "Error: addCrystal failed at pro_${i}${j}.pdb" >> ${Err_Log}
			exit 1
		fi
	done
done
################
