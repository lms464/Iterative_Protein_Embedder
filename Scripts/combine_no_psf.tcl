source ~/Censere/github/Iterative_Protein_Embedder/Utils/make_top.tcl

proc check_protein_z {} {
	set sel [atomselect top "lipids"]
	set comM [measure center ${sel} weight mass]
	$sel delete

	set prot [atomselect top "chain A"]
	set comP [measure center ${prot} weight mass]
	$prot delete

	set dz [expr [lindex $comM 2] - [lindex $comP 2]]
	set dz_abs [expr abs(${dz})]
	if { ${dz_abs} > 5} {
		set prot [atomselect top "protein"]
		${prot} moveby [list 0 0 ${dz}]
		${prot} delete
	} else {
		puts "Protein appears to be properly aligned\nto membrane. Please chech thouth."
	}


}

proc write_pdb {fl_in p1 p2} {
	mol new ${fl_in} type "pdb" first 0 last -1 step 1 waitfor 1
	check_protein_z
	set keep [atomselect top "all and (not (same residue as (lipids within 0.8 of protein)))"]
	$keep writepdb "Censere/UDel/Test_Memb_Extracter/memb_pro_files/protein_mem${p1}${p2}.pdb"
	$keep delete
	writetop
}