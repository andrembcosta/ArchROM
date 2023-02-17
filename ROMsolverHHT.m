function [tconv,Du_mid,Alphaconv]=ROMsolverHHT(V,elementsize,dinitialbeta,initialvelocity,amp,freq)
%tic
%% Problem setup
[newV,nmodes,M,S1,S2,T,F,vel]=setup(V,elementsize,dinitialbeta,initialvelocity);
% disp(M)
% disp(S1)
% disp(S2)
fext=F;
%% Material parameters

L=304.8;%Lenght
I=0.1387438;%Inertia
A=6.4516;%Area
r=sqrt(I/A);%Radius of gyration
%nu=0.28;%Poisson's modulus
mu=7.834000e-09*A;%mass per unit lenght
E=206843;%Young's modulus

timefactor=(1/pi^2)*sqrt((L^4)*mu/(E*I));%nondimensional time
newfreq=(freq/pi^2)*sqrt((L^4)*mu/(E*I));%nondimensional frequency
newamp=amp*(pi^3*E*I*r/L^3)^(-1);%nondimensional amplitude
%% transient parameters set up
FreqSym=0.99407;% in this case we are using the first frequency instead
% of the symetric frequency according to Mihaela(FreqSym should be 1.71289)
mdr=0.002;% mass proportional dampint ratio
mdc=4*pi*FreqSym*mdr;% mass proportional damping coefficient
C=mdc*M;%damping matrix

Pamp=newamp; %harmonic forcing amplitude
f=newfreq; %excitation frequency

omega=2*pi*f;% excitation angular frequency0.5341/
ns=100; % number of sampling points per period
nf=200; % number of forcing periods
period=1/f;% excitation period
dt=period/ns;% time step size
%dt=10^(-4)/timefactor;
t=dt:dt:(period*nf);% computing time series
nt=length(t);% number of computing steps


%% newmark method parameters set up
HHTalpha=0.1;
HHTbeta=(1+HHTalpha)^2/4;
HHTgamma=HHTalpha+0.5;

Alphaconv=zeros(nmodes,1);% store converged displacement
Vconv=zeros(nmodes,1);% store converged velocity
Aconv=zeros(nmodes,1);% store converged acceleration
tconv=zeros(1,1);% store converged time series
tdive=zeros(1,1);% store diverged time series
etol=1e-16;% energy tolerance


%% initial parameters set up for nstep=1
Alpha=zeros(nmodes,1);% initial displacement value for nstep
v=vel;%initial velocity
%v=zeros(nmodes,1);% initial velocity value for nstep
a=zeros(nmodes,1);% initial acceleration value for nstep
maxiter=1000;% maximum number of iterations for Newton-Raphason
nstep=0;% arclength step count
nconv=1;% converged step count
ndive=0;% diverged step count
initflag=1;% options for the initilization
%tic
for kk=1:nt
     lambda1=Pamp*sin(omega*t(kk));% transient force
     if kk==1
         lambda0=0;
     else
         lambda0=Pamp*sin(omega*t(kk-1));
     end
	 nstep=nstep+1;
	 [utemp,vtemp,atemp,relerr]=HHTsolver(Alpha,v,a,lambda1,lambda0,fext,dt,maxiter,etol,HHTalpha,HHTbeta,HHTgamma,initflag,M,C,S1,S2,T);
     if relerr<=etol
		 nconv=nconv+1;
		 Alphaconv(:,nconv)=utemp;
		 Vconv(:,nconv)=vtemp;
		 Aconv(:,nconv)=atemp;
		 tconv(nconv)=t(kk);
     else
		 ndive=ndive+1;
		 tdive(ndive)=t(kk);
     end
     Alpha=utemp;
	 v=vtemp;
	 a=atemp;
end

Du_mid=zeros(1,nconv);
for i=1:nmodes %nmodes
    Du_mid=Du_mid-Alphaconv(i,:)*newV((1+end)/2,i);%compute displacements in the middle
end

%toc
%figure(1)
% plot(tconv*timefactor,-Du_mid*r,'r')%plot midpoint displacements
% load(strcat('p',num2str(amp/0.01778),'fr',num2str(freq/3.22232)))%load FE simulation
% hold on
% plot(displacements(:,1),displacements(:,6))%plot FE midpoint displacements
% legend('ROM','FE')
save(strcat(num2str('RO_','p',num2str(amp/0.01778),'fr',num2str(freq/3.22232)),'tconv','Du_mid','Alphaconv','Vconv','Aconv','dt','period','f','ns','timefactor','r'))
end

function [V,nmodes,M,S1,S2,T,F,vel]=setup(V,elementsize,dinitialbeta,initialvelocity)
%% Do the piecewise polynomial fitting
%V contains the basis functions as columns
nmodes=size(V,2);
[polV1,polV2,polV3,polV4]=polaprox2(V,elementsize,nmodes,1);%perform the polynomial fittings using funtion polaprox2

%% numerical derivative
%evaluate Vprime as a vector because we need it in this form to compute the
%numerical integrals in T

Vprime=zeros(size(V,1),size(V,2));%initialize Vprime

for kk=1:nmodes%Vprime using polynomial fitting
    Vprime(1:26,kk)=polyval(polyder(polV1(kk,:)),(0:elementsize:25*elementsize)');
    Vprime(26:51,kk)=polyval(polyder(polV2(kk,:)),(25*elementsize:elementsize:50*elementsize)');
    Vprime(51:76,kk)=polyval(polyder(polV3(kk,:)),(50*elementsize:elementsize:75*elementsize)');
    Vprime(76:101,kk)=polyval(polyder(polV4(kk,:)),(75*elementsize:elementsize:100*elementsize)');
end


%% Build the Matrices

%Mass Matrix
M=zeros(nmodes,nmodes);
for ii=1:nmodes
    for jj=1:nmodes
        %M(ii,jj)=trapz(newV(:,ii).*newV(:,jj))*elementsize;%-this line
        %would compute M using numerical integration
        M(ii,jj)=diff(polyval(polyint(conv(polV1(ii,:),polV1(jj,:))),[0 pi/4]))+diff(polyval(polyint(conv(polV2(ii,:),polV2(jj,:))),[pi/4 pi/2]))+diff(polyval(polyint(conv(polV3(ii,:),polV3(jj,:))),[pi/2 3*pi/4]))+diff(polyval(polyint(conv(polV4(ii,:),polV4(jj,:))),[3*pi/4 pi]));%analytical integration of the polynomials to get M
    end
    %M=diag(diag(M));
end

%S1 Matrix
S1=zeros(nmodes,nmodes);
for ii=1:nmodes
    for jj=1:nmodes
        %S1(ii,jj)=trapz(Vprime(:,ii).*Vprime(:,jj))*elementsize;%-this
        %line would compute S1 using numerical integration
        S1(ii,jj)=diff(polyval(polyint(conv(polyder(polV1(ii,:)),polyder(polV1(jj,:)))),[0 pi/4]))+diff(polyval(polyint(conv(polyder(polV2(ii,:)),polyder(polV2(jj,:)))),[pi/4 pi/2]))+diff(polyval(polyint(conv(polyder(polV3(ii,:)),polyder(polV3(jj,:)))),[pi/2 3*pi/4]))+diff(polyval(polyint(conv(polyder(polV4(ii,:)),polyder(polV4(jj,:)))),[3*pi/4 pi]));%analytical integration of the polynomials to get S1
    end
    %S1=diag(diag(S1));
end

%S2 Matrix
S2=zeros(nmodes,nmodes);
for ii=1:nmodes
    for jj=1:nmodes
        %S2(ii,jj)=trapz(Vprime2(:,ii).*Vprime2(:,jj))*elementsize;%this
        %line would compute S2 using numerical integration, but Vprime2
        %should be evaluated first.
        S2(ii,jj)=diff(polyval(polyint(conv(polyder(polyder((polV1(ii,:)))),polyder(polyder(polV1(jj,:))))),[0 pi/4]))+diff(polyval(polyint(conv(polyder(polyder((polV2(ii,:)))),polyder(polyder(polV2(jj,:))))),[pi/4 pi/2]))+diff(polyval(polyint(conv(polyder(polyder(polV3(ii,:))),polyder(polyder(polV3(jj,:))))),[pi/2 3*pi/4]))+diff(polyval(polyint(conv(polyder(polyder((polV4(ii,:)))),polyder(polyder(polV4(jj,:))))),[3*pi/4 pi]));%analytical integration of the polynomials to get S2
    end
    %S2=diag(diag(S2));
end

%vector T
T=zeros(nmodes,1);
for ii=1:nmodes
    T(ii)=trapz(Vprime(:,ii).*dinitialbeta)*elementsize;%numerical integration to get T
end

%vector F
fextvec=zeros(101,1);
fextvec(51)=-1/elementsize;%approximation of the Dirac Delta
F=M*(V'*V)^(-1)*V'*fextvec;%writting fextvec in the base of V, this is equivalent to perform numerical integrations, but is probably faster
vel=(V'*V)^(-1)*V'*initialvelocity;
end

function [u v a relerr]=HHTsolver(u0,v0,a0,lambda1,lambda0,fext,dt,maxiter,etol,alpha,beta,gamma,initflag,M,C,S1,S2,T)
%% Newmark time integrator

% u0,u1 - converged displacement in previous time step
% v0,v1 - converged velocity in previous time step
% a0    - converged acceleartion in previous time step
% lambda  - external dynamic load value
% dt - time step size
% nn - maximum number of iterations for Newton
% etol - energy toleration for convergence mearsure 
% alpha, beta, gamma - HHT parameters

%% define intermidate parametres as FEAP 83 dsetci.f 

c1=1/(beta*dt^2); c2=gamma/(beta*dt); c3=1-1/(2*beta); 
c4=1-gamma/beta; c5=(1-gamma/(2*beta))*dt; c6=1/(beta*dt);

%% Initialization at the beginning of each step 
if initflag==1 % u_n+1^0=u_n
    u=u0;
    v=c4*v0+c5*a0;
    a=-c6*v0+c3*a0;
end

ite=0;
relerr=1;
[Fint0,~]=IntForceStiff(u0,S1,S2,T);

%% iteration for corrections
while(relerr>etol && ite<maxiter)
    [Fint,K]=IntForceStiff(u,S1,S2,T); % Internal Force and static stiffness
    RES=(1-alpha)*lambda1*fext+alpha*lambda0*fext-M*a-(1-alpha)*C*v-alpha*C*v0-(1-alpha)*Fint-alpha*Fint0; % Residual force
    %RES=(1-alpha)*lambda1*fext+alpha*lambda0*fext-M*a-C*v-Fint; % Residual force
    Kt=(1-alpha)*K+M/(beta*dt^2)+C*(1-alpha)*gamma/(beta*dt); % Transient Tangent for Newmark 
    du=Kt\RES;
    u=u+du;
    v=v+c2*du;
    a=a+c1*du;
    if(ite==0)
        err0=norm(RES'*du);
    end
    err=norm(RES'*du);
    relerr=err/err0;
    ite=ite+1;
end


end

function [Fint,K]=IntForceStiff(alpha,S1,S2,T)
%% Internal Force and Stiffness matrix of the system
paxial=(alpha'*S1*alpha+2*alpha'*T)/2/pi;

Fint=S2*alpha+S1*paxial*alpha+paxial*T;

K=S2+paxial*S1+(S1*alpha+T)*(S1*alpha+T)'/pi;

end

function [polV1,polV2,polV3,polV4]=polaprox2(newV,h,nmodes,option)
%% Polynomial Fitter
x1=26;%break the interval in 4 parts
x2=51;
x3=76;
x4=101;
if option==1 %option 1 is to use 4 polynomials and do a local fitting
   polV1=zeros(nmodes,6);%initialize polynomial fittings (degree 5)
   polV2=zeros(nmodes,6);%initialize polynomial fittings
   polV3=zeros(nmodes,6);%initialize polynomial fittings
   polV4=zeros(nmodes,6);%initialize polynomial fittings
   for kk=1:nmodes
       polV1(kk,:)=polyfit((0:h:(x1-1)*h)',newV(1:x1,kk),5); %do the polynomial fittings, store them in matrices polV1, polV2, polV3, polV4
       polV2(kk,:)=polyfit(((x1-1)*h:h:(x2-1)*h)',newV(x1:x2,kk),5);
       polV3(kk,:)=polyfit(((x2-1)*h:h:(x3-1)*h)',newV(x2:x3,kk),5);
       polV4(kk,:)=polyfit(((x3-1)*h:h:(x4-1)*h)',newV(x3:x4,kk),5);
   end
   %compute error in the fitting just to make sure it is a good fitting.
   error=zeros(1,nmodes);
   for kk=1:nmodes
       error(kk)=norm(newV(1:x1,kk)'-polyval(polV1(kk,:),0:h:(x1-1)*h),1)+norm(newV(x1:x2,kk)'-polyval(polV2(kk,:),(x1-1)*h:h:(x2-1)*h),1)+norm(newV(x2:x3,kk)'-polyval(polV3(kk,:),(x2-1)*h:h:(x3-1)*h),1)+norm(newV(x3:x4,kk)'-polyval(polV4(kk,:),(x3-1)*h:h*(x4-1)),1);
   end
   
end

if option==2 %option 2 just use 1 polynomial fot the fitting instead of 4.
   polV1=zeros(nmodes,12);%initialize polynomial fittings
   for kk=1:nmodes
       polV1(kk,:)=polyfit((0:h:(size(newV,1)-1)*h)',newV(:,kk),11);%polynomial fitting of degree 11
   end
   polV2=0;
   polV3=0;
   polV4=0;
   %compute error in the fitting
   error=zeros(1,nmodes);
   for kk=1:nmodes
       error(kk)=norm(newV(1:101,kk)'-polyval(polV1(kk,:),(0:h:(size(newV,1)-1)*h)),1);
   end
end
end