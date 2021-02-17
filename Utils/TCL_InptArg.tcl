source ~/Censere/github/Iterative_Protein_Embedder/Scripts.combine_no_psf.tcl

if { $argc < 2 } {
    puts "No input protein"
    puts "Please try again."
} else {       
    write_pdb [lindex ${argv} 0] [lindex $argv 1] [lindex $argv 2]
}