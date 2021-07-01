import sys
def write_itp(path, i, j, act):
    itps = []
    
    if act == "IN":
    
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
    
    elif act == "AC":
        
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
                '#include "toppar/PROA.itp"','#include "toppar/PROB.itp"',
                '#include "toppar/NEC.itp"','#include "toppar/GDP.itp"',
                '#include "toppar/SOD.itp"',
                '[ system ]','; Name','Title',
                "[ molecules ]",'; Compound      #mols']
    
    
    fl = open('%s/%s_protein_mem%s%s_ion.pdb'%(path,act,i,j),'r')
    lines = fl.readlines()
    
    res = []
    res_name = 0
    res_name_old = 0
    
    amino_a = ["ALA ","ARG ","ASN ","ASP ","CYS ","GLN ","GLU ","GLY ","HIS ",
               "HSD ","ILE ","LEU ","LYS ","MET ","PHE ","PRO ","SER ","THR ",
               "TRP ", "TYR ", "VAL ", 'ASX ', 'GLX ']
    aa_bool = True
    proa_bool = True
    prob_bool = True
    zma_bool = True
    gpd_bool = True
    nec_bool = True
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
    
        if (line[-7:-3] == "PROA") and (proa_bool == True):
                res.append("PROA")
                proa_bool = False    
        if (line[-7:-3] == "PROB") and (prob_bool == True):
                res.append("PROB")
                prob_bool = False   
        if (line[-7:-3] == "PROA") and (proa_bool == False):
            res_name_old = "PROA"
            continue
        if (line[-7:-3] == "PROB") and (prob_bool == False):
            res_name_old = "PROB"
            continue
            
        if res_name == "ZMA " and zma_bool == True:
            res.append("ZMA")
            zma_bool = False

        if res_name == "GDP " and gpd_bool == True:
            res.append("GDP")
            gpd_bool = False

        if res_name == "NEC " and nec_bool == True:
            res.append("NEC")
            nec_bool = False


    
        res_name_old = line[17:21]
        
    f.close()   

if len(sys.argv) < 3:
    print("wrong inputs number")
write_itp(sys.argv[1],sys.argv[2],sys.argv[3],sys.argv[4])