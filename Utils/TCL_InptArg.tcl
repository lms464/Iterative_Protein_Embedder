source ~/Censere/github/Iterative_Protein_Embedder/Utils/combine.tcl

if { $argc < 2 } {
    puts "No input protein"
    puts "Please try again."
} else {       
    combine [lindex ${argv} 0] [lindex $argv 1] [lindex $argv 2]
}