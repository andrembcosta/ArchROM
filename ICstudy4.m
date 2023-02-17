frequnit=3.22232;%Hertz
Punit=0.01778;%Newtons
xlim=60*frequnit;
ylim=50*Punit;
xresolution=60;
yresolution=50;
load('velocityprofiles')
load('dinitialbeta')
load('base13POD')
for iii=1:yresolution
   parfor jjj=1:xresolution
       ROMsolverHHT(U1,pi/100,dinitialbeta,velocityprofile4,Punit*iii,frequnit*jjj);
   end
disp(iii)   
end

