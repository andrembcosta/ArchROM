function avgKE=Kenergy(amp,freq)
load(strcat('RO_p',num2str(amp),'fr',num2str(freq)));
load('base13POD');
A=6.4516;%Area
mu=7.834000e-09*A;%mass per unit lenght
V=U1*Vconv;
V=V*r/timefactor;
Vsq=V.*V;
KE=trapz(Vsq)*304.8/100;
KE=KE*0.5*mu;
avgKE=mean(KE);
%plot(tconv*timefactor,KE)
end