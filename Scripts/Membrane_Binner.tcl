;# Liam Sharp
;# 2/3/2021

# Reference Membrane No Protein
set PI 3.14159265359


set memb [atomselect 0 "resname DPPC"]
set memb_minmax [measure minmax $memb]
$memb delete

set x [expr abs([lindex [lindex $memb_minmax 0]0]-[expr [lindex [lindex $memb_minmax 0]1])]
set y [expr abs([lindex [lindex $memb_minmax 1]0]-[expr [lindex [lindex $memb_minmax 1]1])]
set A [expr x * y]


set memb [atomselect 0 "resname DPPC and name P"]
set numLip [$memb num]
$memb delete
set A_lip [expr 1.0*$A / (0.5*$numLip)]


# Membrane with protein embeded
# dependant on which protein has been embedded

set memb [atomselect 1 "resname DPPC and name P"]
set numLip_adj [$memb num]
$memb delete

set A_pro [expr 0.5*$numLip_adj / $A_lip]
set A_bin [expr $A_pro / (2*$PI)]
set bin_size [expr sqrt($A_bin)]
set num_bin [expt 1.0*$A/$A_bin]