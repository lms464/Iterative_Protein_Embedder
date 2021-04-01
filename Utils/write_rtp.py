import sys
import copy

fl = sys.argv[1]
mol = False
mol_nm = ''
atom = False
atoms = []
bond = False
bonds = []
impro = False
impros = []
i = 0
with open("%s.itp"%fl) as f:
    
    for line in f.readlines():
        if line.startswith(';') or line.startswith("#") or line.startswith("[ position_restraints ]") or line.startswith("[ dihedral_restraints ]"):
            continue

        if line == '\n':
            continue
        
        if line.startswith('[ moleculetype ]'):
            mol = True
            atom = False
            bond = False
            impro = False
            continue
         
        if line.startswith('[ atoms ]'):
            mol = False
            atom = True
            bond = False
            impro = False
            atoms.append('  [ atoms ]')
            continue
        
        if line.startswith('[ settles ]'):
            mol = False
            atom = False
            bond = False
            impro = False
            continue
        
        if line.startswith("[ bonds ]"):
            mol = False
            atom = False
            bond = True
            impro = False
            bonds.append('[ bonds ]')
            continue
        
        if line.startswith("[ pairs ]"):
            mol = False
            atom = False
            bond = False
            impro = False
            continue
        
        if line.startswith("[ dihedrals ]"):
            mol = False
            atom = False
            bond = False
            impro = True
            continue
        if line.startswith("[ angles ]"):
            mol = False
            atom = False
            bond = False
            impro = False
            continue
        
        if mol == True:
            mol_nm = '[ %s ]'%line.split()[0]
        if atom == True:
            lin = line.split()
            atoms.append([lin[4],lin[1],lin[6],i])
            i = i + 1
        if bond == True:
            lin = line.split()
            bonds.append([lin[0],lin[1],lin[2]])
        if impro == True:
            lin = line.split()
            if lin[4] != '2':
                continue
            impros.append(lin)
            
        print(line)
        prev_line = copy.deepcopy(line)

f = open('%s.rpt'%fl, 'w')    
f.write('[ %s ]\n'%fl)
atoms_write = []
for a in range(len(atoms)):
    if a == 0:
        f.write("%s\n"%atoms[a])
        continue
    #atoms_write.append("     %s  %s  %s"%(atoms[a][0], atoms[a][1], atoms[a][2]))
    f.write("     %s  %s  %s   %i\n"%(atoms[a][0], 
                                      atoms[a][1], 
                                      atoms[a][2],a-1))

bond_write = []
for b in range(len(bonds)):
    if b == 0:
        f.write("   %s\n"%bonds[b])
        continue
    print(b)
    f.write('       %s   %s\n'%(atoms[int(bonds[b][0])][0],
                                atoms[int(bonds[b][1])][0] ))
    # bond_write.append('       %s   %s'%(atoms[int(bonds[b][0])][0], atoms[int(bonds[b][1])][0] ) )

f.write('[ impropers ]\n')
for im in range(len(impros)):
    f.write('        %s  %s  %s  %s  2\n'%( atoms[int(impros[im][0])][0],
                                           atoms[int(impros[im][1])][0],
                                           atoms[int(impros[im][2])][0],
                                           atoms[int(impros[im][3])][0]) )
f.close()
    
    
