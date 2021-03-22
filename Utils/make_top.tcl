;# Liam Sharp
;# 2/10/2021

;# Assumption this is for A2AaR
proc load_structure {inpt} {
     mol new "${inpt}" type {pdb} first 0 last -1 step 1 waitfor 1
}

proc sel_non_protein {inpt_list z_mid} {
    set amino_acids [list ALA ARG ASN ASP CYS GLN GLU GLY HIS HSD ILE LEU LYS MET PHE PRO SER THR TRP TYR VAL ASX GLX]

    set sel [atomselect top "all and not resname ${amino_acids}"]
    set resnms_not_pro [lsort -unique [$sel get resname]]
    $sel delete

    foreach rsnm $resnms_not_pro {
        if {$rsnm=="TIP3"} {
            set sel [atomselect top "resname $rsnm and name OH2"]
            lappend inpt_list "$rsnm\t\t[$sel num]"
            $sel delete
        } elseif {${rsnm}=="ZMA"} {
            set sel [atomselect top "resname $rsnm and name N10"]
            lappend inpt_list "$rsnm\t\t[$sel num]"
            $sel delete
        } elseif {${rsnm}=="SOD"} {
            set sel [atomselect top "resname $rsnm"]
            lappend inpt_list "$rsnm\t\t[$sel num]"
            $sel delete
        } elseif {${rsnm}=="CLA"} {
            set sel [atomselect top "resname $rsnm"]
            lappend inpt_list "$rsnm\t\t[$sel num]"
            $sel delete
        } else {
            set sel [atomselect top "resname $rsnm and name P and z > ${z_mid}"]
            lappend inpt_list "$rsnm\t\t[$sel num]"
            $sel delete

            set sel [atomselect top "resname $rsnm and name P and z < ${z_mid}"]
            lappend inpt_list "$rsnm\t\t[$sel num]"
            $sel delete
        }
    }
    return [list ${inpt_list} $resnms_not_pro]
}

proc sel_protein {inpt_list chns} {
    if {[llength $chns] == 0} {
        lappend input_list ";; No Protein detected.\nPlease confirm, script assumes\nchains can be checked."
        return ""
    } else {
        foreach chn $chns {
            lappend inpt_list "PRO${chn}\t\t1"
        }
    }
    return ${inpt_list}
}

proc set_reslist {} {

    set pro [atomselect top "protein"]
    set chns [lsort -unique [${pro} get chain]]
    if {${chns} == "X" || ${chns} == "P"} {
        set chns "A"
    }
    $pro delete

    set lip [atomselect top "lipids and name P"]
    set z [lindex [measure center ${lip} weight mass] 2]


    set res_list [list ]
    set res_list [sel_non_protein ${res_list} ${z}]
    set resnames [lindex ${res_list} 1]
    set res_list [lindex ${res_list} 0]
    set res_list [sel_protein ${res_list} ${chns}]
    
    return [list ${res_list} ${resnames}]
}

proc sel_itp {p1 p2} {
    set path "~/Censere/github/Iterative_Protein_Embedder/test/prot_memb_${p1}${p2}/toppar"
    set itp_files [glob -nocomplain -tails -directory "${path}" "*.itp"]
    return ${itp_files}
}

proc writetop {inpt_pdb p1 p2} {

    load_structure ${inpt_pdb}

    set res_list_2D [set_reslist]
    set res_list [lindex ${res_list_2D} 0]
    set resnames [lindex ${res_list_2D} 1]
    set itps [sel_itp ${p1} ${p2}]

    set f [open "/home/liam/Censere/github/Iterative_Protein_Embedder/test/prot_memb_${p1}${p2}/topol.top" w]
    if {[lsearch ${itps} "forcefield.itp"] >= 0 } {
        puts $f "#include \"toppar/forcefield.itp\""
    } else {
        puts "Warning:There is no forcefield.itp file in this list!"
        puts "\tConfirm this file exists."
        puts "\tExiting without writing topology file."
        close $f 
        return -1
    }
    foreach resnm ${resnames} {
        if {[lsearch ${itps} "${resnm}.itp"] >= 0 } {
            puts $f "#include \"toppar/${resnm}.itp\""
        } else {
            puts "Warning:There is no ${resnm}.itp file in this list!"
            puts "\tThis molecule exists in the simulations though."
            puts "\tConfirm this file exists."
            puts "\tExiting without writing topology file."
            close $f 
            return -1
        }
    }
    
    set protein_indx [lsearch -all $itps *PRO*]
    if {[llength $protein_indx] > 0} {
        foreach pidx ${protein_indx} {
            puts $f "#include \"toppar/[lindex ${itps} ${pidx}]\""
        }
    } else {
        puts "Warning:There is no protein itp files in this list!"
        puts "\tPlease confirm this is correct."
        puts "\tIt will not prevent the toplogy file from being writtent"
    }
    
    puts ${f} "\n\n\[ system \]\n; Name\nTitle\n\n"
    puts ${f} "\[ molecules \]\n; Compound\t#mols"
    foreach res [lsort -dictionary $res_list] {
        puts $f "${res}"
    }
    close $f 
    return 0
}


# if { $argc < 1 } {
#     puts "Error: Impropper argument input number"
#     puts "\tPlease try again."
# } else {     
#     puts "[lindex ${argv} 0]"  
#     #set fin [write_pdb [lindex ${argv} 0] [lindex $argv 1] [lindex $argv 2]]
#     load_structure [lindex ${argv} 0]
#     writetop
# }
# exit