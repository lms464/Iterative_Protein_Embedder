
proc combine {pro_in p1 p2} {

    #!/usr/local/bin/vmd -dispdev text

    ## embed (parts of) protein into a membrane
    # Ilya Balabin (ilya@ks.uiuc.edu), 2002-2003
    #
    # You need: a) membrane structure (membrane.psf/pdb);
    # b) properly oriented and aligned to the membrane
    # protein structure (protein.psf/pdb)


    # set echo on for debugging
    #echo on

    # need psfgen module and topology

    set path_def "" 

    if {${p1} == "None" || ${p2} == "None"} {
        set p1 "" 
        set p2 ""
        set path_def "/Censere/github/Iterative_Protein_Embedder/test/def"
    } else {
        set path_def "/Censere/github/Iterative_Protein_Embedder/test/prot_memb_${p1}${p2}/def"
    }

    puts ""
    puts ""
    puts ${path_def}
    puts ""
    puts ""

    package require psfgen
    topology /usr/local/lib/vmd/plugins/noarch/tcl/readcharmmtop1.2/top_all36_prot.rtf
    topology /usr/local/lib/vmd/plugins/noarch/tcl/readcharmmtop1.2/top_all36_lipid.rtf
    topology /usr/local/lib/vmd/plugins/noarch/tcl/readcharmmtop1.2/toppar_water_ions_namd.str
    ;#top_all27_prot_lipid.inp

    # load structures
    resetpsf

    readpsf ${path_def}/membrane.psf
    coordpdb ${path_def}/membrane.pdb

    readpsf ${path_def}/protein.psf
    coordpdb $pro_in

    # can delete some protein segments; list them in brackets on next line
    set pseg2del   { }
    foreach seg $pseg2del {
      delatom $seg
    }

    # write temporary structure
    set temp "${path_def}/temp"
    writepsf ${temp}.psf
    writepdb ${temp}.pdb

    # reload full structure (do NOT resetpsf!)
    mol load psf ${temp}.psf pdb ${temp}.pdb

    # select and delete lipids that overlap protein:
    # any atom to any atom distance under 0.8A
    # (alternative: heavy atom to heavy atom distance under 1.3A)
    set sellip [atomselect top "resname DPPC"]
    set lseglist [lsort -unique [$sellip get segid]]
    foreach lseg $lseglist {
      # find lipid backbone atoms
      set selover [atomselect top "segid $lseg and within 0.8 of protein"]
      # delete these residues
      set resover [lsort -unique [$selover get resid]]
      foreach res $resover {
        delatom $lseg $res
      }
    }

    # delete lipids that stick into gaps in protein
    foreach res { } {delatom $LIP1 $res}
    foreach res { } {delatom $LIP2 $res}

    # delete lipids that fall out of the PBC box
    # the following numbers are for example only; yours are different!
    set xmin -55
    set xmax  41
    set ymin -51
    set ymax  34
    foreach lseg {"LIP1" "LIP2"} {
      # find lipid backbone atoms
      set selover [atomselect top "segid $lseg and (x<$xmin or x>$xmax or y<$ymin or y>$ymax)"]
      # delete these residues
      set resover [lsort -unique [$selover get resid]]
      foreach res $resover {
        delatom $lseg $res
      }
    }

    if { ${p1} != "" || ${p2} != "" } {
        set path_def "/Censere/github/Iterative_Protein_Embedder/test/prot_memb_${p1}${p2}"
    }

    # write full structure
    writepsf ${path_def}/protein_mem${p1}${p2}.psf
    ;#if {[file exists ${path_def}/membrane.psf ] == 0} {exit 0}
    writepdb ${path_def}/protein_mem${p1}${p2}.pdb
    ;#if {[file exists ${path_def}/membrane.pdb ] == 0} {exit 0}
    # clean up
    file delete $temp.psf
    file delete $temp.pdb
    # non-interactive script
    ;#quit
    return 0
}
