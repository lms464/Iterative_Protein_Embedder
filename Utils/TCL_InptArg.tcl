;#source ~/Censere/github/Iterative_Protein_Embedder/Scripts/combine_no_psf.tcl
source ~/Censere/github/Iterative_Protein_Embedder/Utils/combine.tcl

if { $argc < 2 } {
    puts "Error: Impropper argument input number"
    puts "\tPlease try again."
} else {     
	puts "[lindex ${argv} 0]"  
    #set fin [write_pdb [lindex ${argv} 0] [lindex $argv 1] [lindex $argv 2]]
    set fin [combine [lindex ${argv} 0] [lindex $argv 1] [lindex $argv 2]]
}
if {${fin} == 1} {
	exit
} else {
	puts "Error: see statements above"
}