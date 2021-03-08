#!/bin/bash

combine_tcl () {
	if [ ${i}=="None" ] || [ ${j}=="None" ]; then
		echo "-dispdev text -e combine.tcl "protein_aligned.pdb" ${i} ${j}"
	else
		path="" #need to add where the path should be
		pro="${path}/pro_${i}${j}.pdb"
		echo "-dispdev text -e combine.tcl ${pr} ${i} ${j}"
 	fi
}

i="None"
j="None"
combine_tcl

i=1
j=2
combine_tcl
