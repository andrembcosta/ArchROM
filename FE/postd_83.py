from string import * 
from sys import argv 
from string import *
 
#filename = raw_input("Please enter filename: ") 
filename = argv[1]
f = open( filename, 'r') 
lines = f.readlines() 
f.close() 

fout  = open( filename+".conv", 'w' ) 
frea  = open( filename+".reac", 'w' ) 
fdis  = open( filename+".disp", 'w' ) 
fcoo  = open( filename+".coor", 'w' ) 
fdc   = open( filename+".dc",'w')
fxl   = open( filename+".xl",'w' )
 
reac = 0 
disp = 0 
elem = 0 
coor = 0 
dc   = 0
xl   = 0
 
load_step = 0 
iteration = 0 
time = 0 
conv_str = 0
loadprop = 0
 
for line in lines: 
    row = split( line ) 
    len_row = len( row ) 
     
# what time step and /or what iteration     
     
    if len_row>4 and row[0]=="*Command" and row[3]=="time" : 
        load_step = load_step + 1 
        iteration = 0 
    if len_row>8 and row[0]=="Computing" and row[1]=="solution" and row[3]=="time" : 
        time =row[4] # changed here on May 29,2008 IS9
    if len_row>4 and row[0]=="*Command" : 
        if row[3]=="tang" or row[3]=="utan" : 
                iteration= iteration + 1        
         
 
    if row == ['N','o','d','a','l','R','e','a','c','t','i','o','n','s']: 
        frea.write(str(load_step)) 
        frea.write("\t") 
        frea.write(str(time)) 
        frea.write("\t") 
        frea.write(str(iteration)) 
        frea.write("\n") 
        reac = 1  
        disp = 0 
        elem = 0 
        coor = 0 
        dc   = 0
        xl   = 0
 
    if row == ['E','l','e','m','e','n','t','s']: 
        reac = 0  
        disp = 0 
        elem = 1 
        coor = 0 
        dc   = 0
        xl   = 0
 
        #frea.write("\n") 
         
    if row [:18] == ['N','o','d','a','l','D','i','s','p','l','a','c','e','m','e','n','t','s']:
        fdis.write(str(load_step)) 
        fdis.write("\t") 
        fdis.write(str(time)) 
        fdis.write("\t") 
        fdis.write(str(iteration)) 
        fdis.write("\n") 
        reac = 0  
        disp = 1 
        elem = 0 
        coor = 0 
        cont = 0
        dc   = 0
        xl   = 0
         
    if len_row>3:   
        if row [0] =="node" and row[1]== "in" and row[2]== "contact": 
                reac = 0  
                disp = 0 
                elem = 0 
                coor = 0 
                cont = 1
                dc   = 0
                xl   = 0   
 
    if row == ['N','o','d','a','l','C','o','o','r','d','i','n','a','t','e','s']: 
        reac = 0  
        disp = 0 
        elem = 0 
        coor = 1
        dc   = 0
        xl   = 0

    if row == ['M','a','t','e','r','i','a','l','P','r','o','p','e','r','t','i','e','s'] or row[:1] == ['FEAP']: 
        reac = 0  
        disp = 0 
        elem = 0 
        coor = 0  
        dc   = 0

    if row == ['Output','damage','coefficient']:
        reac = 0  
        disp = 0 
        elem = 0 
        coor = 0  
        dc   = 1
        xl   = 0
    
    if row == ['------','Contour','Values','for','Plot','------']:
        dc   = 0

    if row == ['Output','xl']:
        reac = 0  
        disp = 0 
        elem = 0 
        coor = 0  
        dc   = 0
        xl   = 1

    if len_row>0: 
      if (row[0]  == "Computing") or (len_row > 4 and row[3] == "augm") or (row[0] == "*Command") or (row[0] == "Residual") or (row[0] == "*Command"): 
                reac = 0 
                disp = 0     
                elem = 0 
                coor = 0 
                dc   = 0
                xl   = 0

      if (row[0] == "*WARNING*") or (row[0]=="RHS"): 
                reac = 0 
                disp = 0      
                elem = 0 
                coor = 0 
                dc   = 0
                estra= 0
                xl   = 0
      if (row[0]  == 'Relative'): 
                conv_str = row[2] 
 
    conv_line = ""  
    reac_line = "" 
    disp_line = "" 
    dc_line   = ""
    xl_line   = ""

    if reac == 1 : 
        frea.write( line ) 
    elif disp ==1: 
        fdis.write( line ) 
    elif elem == 1 and row == [  'N','o','d', 'a', 'l',   'B.' ,'C.']:     
        frea.write("\n \n")   
    elif coor == 1: 
        fcoo.write ( line )
    elif dc   == 1:         
        fdc.write ( line )
    elif xl   == 1:
        fxl.write ( line )

    elif len_row>0: 
        if row[0] == "Computing": 
                fout.write( line )
        elif row[0] == 'Relative': 
                conv_line = row[2] +"\n"  
                fout.write( conv_line)
        elif row[0]== 'slip' or row [0]=='RHS': 
                fout.write( line ) 
        elif (len_row > 4 and row[3] == "augm"): 
                conv_line = row[3]+"\n" 
                fout.write(conv_line) 
                fdis.write(conv_line)
fout.write('end convergence') 
fout.close() 
frea.close() 
fdis.close()  
fcoo.close() 
fdc.close()
fxl.close()
 
# reading nodal coordinates and saving in matlab format: 
 
fi1 = open(filename+".coor",'r') 
lines = fi1.readlines() 
fi1.close() 
 
fo1 = open(filename+"_coor.m",'w') 
fo1.write("coordinates = [") 
 
for line in lines: 
    row = split( line ) 
    len_row = len( row ) 
    if len_row ==3: 
         fo1.write(row[0]+"\t"+row[1]+"\t"+row[2]+"\n") 
fo1.write("];") 

fo1.write("\n")
fo1.write("connections = [") 
 
for line in lines: 
    row = split( line ) 
    len_row = len( row ) 
    if len_row ==7: 
         fo1.write(row[0]+"\t"+"\t"+row[3]+"\t"+row[4]+"\t"+row[5]+"\t"+row[6]+"\n") 
fo1.write("];") 
fo1.close() 

# reading the damage coefficients and saving in matlab format: 
 
fi2 = open(filename+".dc",'r') 
lines = fi2.readlines() 
fi2.close() 
 
fo2 = open(filename+"_dc.m",'w') 
fo2.write("dmgcof = ["+"\n")
 
for line in lines: 
    row = split( line ) 
    len_row = len( row )  
    if len_row == 6 and row[0] !="Minimum":
       fo2.write(row[0]+"\t"+row[1]+"\t"+row[2]+"\t"+row[3]+"\t"+row[4]+"\t"+row[5]+"\t"+"\n") 
fo2.write("];") 
fo2.close() 

# reading the local gaussian coordinates and saving in matlab format:
fi21 = open(filename+".xl",'r') 
lines = fi21.readlines() 
fi21.close() 

fo21= open(filename+"_xl.m",'w')
fo21.write("xl = ["+"\n") 
 
for line in lines: 
    row = split( line ) 
    len_row = len( row ) 
    if len_row == 9 and row[0] !="*Command": 
       fo21.write(row[0]+"\t"+row[1]+"\t"+row[2]+"\t"+row[3]+"\t"+row[4]+"\t"+row[5]+"\t"+row[6]+"\t"+row[7]+"\t"+row[8]+"\t"+"\n") 
fo21.write("];")
fo21.close() 
 
# reading reactions and saving in matlab format 
 
fi3 = open(filename+".reac",'r') 
lines = fi3.readlines() 
fi3.close() 
 
fo3 = open(filename+"_reac.m",'w') 
fo3.write("reactions_c =[" ) 

old_time = 0;

for line in lines: 
         row = split(line) 
         len_row = len(row) 
         if len_row ==3: 
                load_step = row[0] 
                time = row[1]
                lentime=len(time)
                iteration = row[2]
                #if iteration == "30" and old_time!=time:
                 #       fo5.write(str(load_step))
                  #      fo5.write("\t") 
                   #     fo5.write(str(time[0:lentime-1])+"\n")
                old_time = time
         if len_row ==4: 
                if row[0]!="Pr.Sum" and row[0]!="Sum" and row[0]!="|Sum|" and iteration!="600000000": 
                        fo3.write(str(load_step)) 
                        fo3.write("\t") 
                        fo3.write(str(time[0:lentime-1])) 
                        fo3.write("\t") 
                        fo3.write(str(iteration)) 
                        fo3.write("\t") 
                        fo3.write(row[0]+"\t"+row[1]+"\t"+row[2]+"\t"+row[3]+"\n")
                         
fo3.write("];") 
fo3.close()
 
# reading displacements and saving in matlab format 
 
fi4 = open(filename+".disp",'r') 
lines = fi4.readlines() 
fi4.close() 
 
fo4 = open(filename+"_disp.m",'w')
fo4n = open(filename+"_nonc.m",'w')
fo4n.write("nonconverged=[")
fo4.write("displacements =[" ) 
for line in lines: 
         row = split(line) 
         len_row = len(row) 
         if len_row ==3 and row[0]!="Prop.": 
                load_step = row[0] 
                iteration = row[2]
         if len_row ==3 and row[0]=="Prop.": 
                loadprop = row[2] 
         if len_row > 15:
             time = row[19]
         if len_row ==6 and row[0]!="*End":
             if iteration!="60000000000": 
                        #fo4.write(str(load_step)) 
                        #fo4.write("\t") 
                        fo4.write(str(time)) 
                        #fo4.write("\t")
                        fo4.write(line)
                        #fo4.write(str(iteration)) 
                        #fo4.write("\t") 
                        #fo4.write(row[0]+"\t"+row[4]+"\t"+row[5]+"\t"+row[6]+"\n")
             else:
                 fo4n.write(str(time))
                 fo4n.write("\n")
fo4.write("];")
fo4n.write("];")
fo4.close()
fo4n.close()

# reading convergence rate and saving in matlab format 
 
fi5 = open(filename+".conv",'r') 
lines = fi5.readlines() 
fi5.close() 
 
fo5 = open(filename+"_conv.m",'w')
fo5.write("converg =[" )
numc = 0
for line in lines: 
         row = split(line) 
         len_row = len(row)  
         if len_row > 2:
             if numc > 0:
                fo5.write(str(float(loadstep[:10])) + '    ' + str(numc) + '    ' + temp )
                fo5.write("\n")                
             loadstep = row[4]
             numc = 0
             flagl = 1
         elif len_row == 1:
             numc = numc + 1
             flagc = 1
             temp  = row[0]
         if len_row == 2:
             fo5.write(str(float(loadstep[:10])) + '    ' + str(numc) + '    ' + temp )
             fo5.write("\n")  
fo5.write("];")
fo5.close()
