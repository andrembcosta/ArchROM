%script for IC study
load('velocityprofiles')
load('base13POD')
load('dinitialbeta')
tic
i=10;
j=10;
ROMsolverHHT(U1,pi/100,dinitialbeta,velocityprofile0,Punit*i,frequnit*j);
figure(2)
ROMsolverHHT(U1,pi/100,dinitialbeta,velocityprofile1,Punit*i,frequnit*j);
figure(3)
ROMsolverHHT(U1,pi/100,dinitialbeta,velocityprofile2,Punit*i,frequnit*j);
figure(4)
ROMsolverHHT(U1,pi/100,dinitialbeta,velocityprofile3,Punit*i,frequnit*j);
figure(5)
ROMsolverHHT(U1,pi/100,dinitialbeta,velocityprofile4,Punit*i,frequnit*j);
toc