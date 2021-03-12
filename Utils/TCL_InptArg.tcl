
if { $argc < 2 } {
    puts "Error: Impropper argument input number"
    puts "\tPlease try again."
    exit 0
} else {   
	set UTILS "/Censere/github/Iterative_Protein_Embedder/Utils"

	if { [lindex ${argv} 0] == "c" } {
		source ${UTILS}/combine.tcl
		puts "Combine Prot and Memb"
		set fin [combine [lindex ${argv} 1] [lindex $argv 2] [lindex $argv 3]]

	} elseif { [lindex ${argv} 0] == "t"} {
		source ${UTILS}/make_top.tcl
		puts "Build .top file"
		set fin [writetop [lindex ${argv} 1] [lindex ${argv} 2] [lindex ${argv} 3]]

	} else {
		puts "inproper selction"
		exit 1
	}
	#puts "[lindex ${argv} 0]"  
    #set fin [write_pdb [lindex ${argv} 0] [lindex $argv 1] [lindex $argv 2]]
    #set fin [combine [lindex ${argv} 0] [lindex $argv 1] [lindex $argv 2]]
}
if {${fin} == 0} {
	exit 0
} else {
	puts "Error: see statements above"
	exit 1
}