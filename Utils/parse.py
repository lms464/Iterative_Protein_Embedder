import sys
def write_itp(path, i, j):
    itps = ['#include "toppar/forcefield.itp"', '#include "toppar/PAPS.itp"', 
            '#include "toppar/PSM.itp"','#include "toppar/PLPC.itp"', 
            '#include "toppar/POPC.itp"', '#include "toppar/NSM.itp"', 
            '#include "toppar/PLQS.itp"','#include "toppar/LSM.itp"', 
            '#include "toppar/POPE.itp"', '#include "toppar/SOPC.itp"',
            '#include "toppar/PDPE.itp"','#include "toppar/PAPC.itp"',
            '#include "toppar/OAPE.itp"','#include "toppar/SAPS.itp"',
            '#include "toppar/PLAO.itp"','#include "toppar/PLAS.itp"',
            '#include "toppar/DPPC.itp"','#include "toppar/OAPS.itp"',
            '#include "toppar/CHL1.itp"','#include "toppar/SAPI.itp"',
            '#include "toppar/TIP3.itp"','#include "toppar/CLA.itp"',
            '#include "toppar/PROA.itp"','#include "toppar/ZMA.itp"',
            '#include "toppar/SOD.itp"','[ system ]','; Name','Title',
            "[ molecules ]",'; Compound      #mols']
    
    
    fl = open('%s/protein_mem%s%s.pdb'%(path,i,j),'r')
    lines = fl.readlines()
    
    res = []
    res_name = 0
    res_name_old = 0
    
    amino_a = ["ALA ","ARG ","ASN ","ASP ","CYS ","GLN ","GLU ","GLY ","HIS ",
               "HSD ","ILE ","LEU ","LYS ","MET ","PHE ","PRO ","SER ","THR ",
               "TRP ", "TYR ", "VAL ", 'ASX ', 'GLX ']
    aa_bool = True
    zma_bool = True
    lipids = ["DPPC", "LSM ", "NSM ", "OAPE", "OAPS", "PAPC", "PAPS", "PDPE", 
              "PLAO", "PLAS", "PLPC", "PLQS", "POPC", "POPE", "PSM ", "SAPI", 
              "SAPS", "SOPC"]
    
    f = open('%s/topol2.top'%path,'w')
    
    for i in itps:
        f.write("%s\n"%i)
    
    for li, line in enumerate(lines[1:]):
        res_name = line[17:21]
        
            
        if li != 0:
            if res_name != res_name_old:
                if len(res) > 0:
                    print("%s \t %i"%(res_name_old,len(res)))
                    f.write("%s \t %i\n"%(res_name_old,len(res)))
                    res = []
                
        if res_name in lipids and line[13:16] == 'P  ':        
            res.append(res_name)
        
        if res_name == 'CHL1' and line[13:15] == 'C3':
                res.append(res_name)
                
        if res_name == 'TIP3' and line[13:16] == 'OH2':
                res.append(res_name)
                
        if res_name == 'CLA ' and line[13:16] == "CLA":
                res.append(res_name) 
        
        if res_name == 'SOD ' and line[13:16] == "SOD":
                res.append(res_name) 
    
        if (res_name in amino_a) and (aa_bool == True):
            res.append("PROA")
            aa_bool = False     
        if (res_name in amino_a) and (aa_bool == False):
            res_name_old = "PROA"
            continue
            
        if res_name == "ZMA " and zma_bool == True:
            res.append("ZMA")
            zma_bool = False
    
        res_name_old = line[17:21]
        
    f.close()   

if len(sys.argv) < 3:
    print("wrong inputs number")
write_itp(sys.argv[1],sys.argv[2],sys.argv[3])