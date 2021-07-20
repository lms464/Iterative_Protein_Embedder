fl = open('protein_mem.pdb','r')
lines = fl.readlines()

res = []
res_name = 0
res_name_old = 0

for li, line in enumerate(lines[1:-1]):
    res_name = line[17:21]

    if li != 0:
        if res_name != res_name_old:
            print("%s \t %i"%(res_name_old,len(res)))
            res = []

    if res_name == 'CHL1':
        if line[13:15] != 'C3':
            res_name_old = line[17:21]
            continue
        else:
            res.append(res_name)
        
    
    if line[13:16] != 'P  ':
        res_name_old = line[17:21]
        continue
    else:
        res.append(res_name)
    res_name_old = line[17:21]
    
    