;# Liam Sharp
;# 2/3/2021

# Reference Membrane No Protein
set PI 3.14159265359

proc load_structure {inpt} {
	 mol new "${inpt}"
}

load_structure "./membrane.pdb"
set memb [atomselect 0 "resname DPPC"]
set memb_minmax [measure minmax $memb]
$memb delete

set r [vecsub [lindex $memb_minmax 1] [lindex $memb_minmax 0]]
set x [lindex $r 0]
set y [lindex $r 1]
set A [expr $x * $y]


set memb [atomselect 0 "resname DPPC and name P"]
set numLip [$memb num]
$memb delete
set A_lip [expr (0.5*$numLip)/(1.0*$A) ]


# Membrane with protein embeded
# dependant on which protein has been embedded

load_structure "protein_mem.pdb"

set memb [atomselect 1 "resname DPPC and name P"]
set numLip_adj [$memb num]
$memb delete

set A_adj [expr 0.5*$numLip_adj / $A_lip]
set A_pro [expr $A- $A_adj]
set A_bin [expr $A_pro / (2*$PI)]
set bin_size [expr sqrt($A_bin)]
set num_bin [expr int(1.0*$A/$A_bin)]

