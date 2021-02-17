#!/bin/bash


path_pro="/home/liam/UDel/Test_Memb_Extracter/pdb_files"
path_mem="/home/liam/UDel/Test_Memb_Extracter/membrane.pdb"
nfiles=$(ls ${path} | wc -l)
ij=$(echo "sqrt($nfiles)-1" | bc)

clean_up () {
	#Assumes temp
	if [ -f  "${path}/temp.pdb" ]; then
		rm -f ${path}/temp.pdb
	else
		echo "File does not exist"
	fi
}

cat_pdb () {
	clean_up
	cat ${pro} ${path_mem} > ${path_pro}/temp.pdb
	sed -i 's/END//g' ${path_pro}/temp.pdb
	sed -i '/^$/d' ${path_pro}/temp.pdb
	echo "END" >> ${path_pro}/temp.pdb
}

finalize_pdb () {
	for i in `seq 0 1`; do
		for j in `seq 0 1`; do
			pro=${path_pro}/pro_${i}${j}.pdb
			cat_pdb
			vmd -dispdev text -e ../Utils/TCL_InptArg.tcl -args "${path_pro}/temp.pdb" "${i}" "${j}"
		done
	done
	clean_up
}

finalize_pdb