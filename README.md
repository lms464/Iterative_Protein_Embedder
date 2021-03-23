# Iterative_Protein_Embedder

Bins a membrane into ~protein sized bins and builds/modifies starting structures and run parameters for gromacs. The script iterates through each bin, places a protein in it, and builds a gromacs .top file, organizes mdps, and topology paramteters (this last one is still a little of a work in progress). This script does not build you GROMACS topologies from NAMD psfs! 

* Bit of a Frankenstein's Monster Script
	* Bash script wrapper (combine.sh), calls various TCL and Python scripts
	* Uses combine.tcl from Ilya Balabin and addCrystPdb.py from CHARMM-GUI
	* Error catching is still a work in progress unfortunatly

For running:
1. Have a membrane pdb and psf you want to use
2. Have a protein pdb and psf that has been centered so the transmembrane region is the center of the membrane
3. Have the GROMACS topologies paramaters.

#TODO Add an example organization tar.gz
