;# Liam Sharp
;# 2/3/2021

#quick loader for files
proc load_structure {inpt} {
	 mol new "${inpt}"
}

proc get_min_xy {lip} {
	set memb [atomselect top "resname $lip"]
	set memb_minmax [measure minmax $memb]
	$memb delete
	return $memb_minmax
}

proc get_memb_area {lip memb_minmax} {
	;# needs to be updated to manage equilibrated system
	;# and multiple lipids
	set r [vecsub [lindex [lindex $memb_minmax 1]0] [lindex [lindex $memb_minmax 0]0]]
	set x [lindex $r 0]
	set y [lindex $r 1]
	set A [expr $x * $y]
	set memb [atomselect top "resname $lip and name P"]
	set numLip [$memb num]
	$memb delete
	set A_lip [expr (0.5*$numLip)/(1.0*$A) ]
	return [list $A $A_lip]
}
	# Membrane with protein embeded
	# dependant on which protein has been embedded

proc get_memb_adjst_area {lip A_lip} {
	set memb [atomselect top "resname ${lip} and name P"]
	set numLip_adj [$memb num]
	$memb delete
	set A_adj [expr 0.5*$numLip_adj / $A_lip]
	return $A_adj
}

proc get_pro_area {A A_adj} {
	set PI 3.14159265359
	set A_pro [expr $A- $A_adj]
	set A_bin [expr $A_pro / (2*$PI)]
	set bin_size [expr sqrt($A_bin)]
	set num_bin [expr int(1.0*$A/$A_bin)]
	return [list $A_bin $bin_size $num_bin]
}

# Reference Memb
load_structure "./membrane.pdb"
set memb_minmax [get_min_xy "DPPC"]
set x_min [lindex [lindex $memb_minmax 0] 0]
set y_min [lindex [lindex $memb_minmax 0] 1]

set x_max [lindex [lindex $memb_minmax 1] 0]
set y_max [lindex [lindex $memb_minmax 1] 1]
mol delete 

set area_list [get_memb_area "DPPC" $memb_minmax]
set A [lindex $area_list 0]
set A_lip [lindex $area_list 1]

# Memb with Protein
load_structure "protein_mem.pdb"
set A_adj [get_memb_adjst_area "DPPC" $A_lip]
set bin_list [get_pro_area $A $A_adj]
mol delete 

set A_bin [lindex $bin_list 0]
set bin_size [lindex $bin_list 1]
set num_bin [lindex $bin_list 2]

set xi [expr $x_min + 3.0 * $bin_size]
set yi [expr $y_min + 3.0 * $bin_size]

set i 0
set j 0
load_structure "./protein_aligned.pdb"
set pro [atomselect top "protein"]

while {$xi < [expr $x_max - (1.5 * $bin_size)] } {
	while {$yi < [expr $y_max - (1.5* $bin_size)]} {
		;#puts "($xi, $yi) ([expr ($xi+$bin_size)], [expr ($yi+$bin_size)])"
		$pro moveby [list $xi $yi 0]
		$pro writepdb "./pdb_files/pro_${i}${j}.pdb"
		set xin [expr -1.0*$xi]
		set yin [expr -1.0*$yi]
		$pro moveby [list $xin $yin 0]
		set yi [expr $yi + $bin_size]
		incr j
	}
	set yi [expr $y_min + 3.0*$bin_size]
	set j 0
	set xi [expr $xi + int($bin_size)]
	incr i
}
mol delete
exit