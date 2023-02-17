function [apAlpha,order,totalerror,U1,S1,V1,U,S,V]=Lowrankapproximation(string)
%This function takes the displacement field matrix from a FE simulation and
%produces low rank approximations for that matrix. In the process, it
%obtain the POD modes for that particular response. 
tic
Str=load(string);
Alpha=Str.disp_all(end-50*100:end,2:end);%steady state - not subtracting anything
[U S V]=svds(Alpha,10);%using SVDS because the matrix is symmetric and large
d=diag(S)/sum(diag(S));%partial sum of the eigenvalues, that are all positive, because the matrix was symmetric and positive
dim=find(cumsum(d)>0.998);%find the minimum number of eigenvalues to reach a certain level of contribution to the matrix norm(0.998 is arbitraty, can be changed) 
%Maybe I should order the eigenvalues wrt to their contribution but it is
%probably unecessary.
order=dim(1);
U1=U(:,1:dim(1));%select the part of U that is related to the important eigenvalues
S1=S(1:dim,1:dim(1));%select the part of S that contains the important eigenvalues
V1=V(:,1:dim(1));%select the part of V that is related to the important eigenvalues(this matrix have the POD modes as column vectors).
apAlpha=U1*S1*V1';%construct the low-rank approximation for Alpha using U1,S1 and V1

errorvec=Str.disp_all(end-50*100:end,52)-apAlpha(:,51);%error in the midpoint displacement obtained when doing the low-rank approximation as a vector
totalerror=norm(errorvec)/norm(Str.disp_all(end-50*100:end,52));%relative error (global)

plot(Str.disp_all(end-50*100:end,1),Str.disp_all(end-50*100:end,52))%plot midpoint displacement from FE
hold on
plot(Str.disp_all(end-50*100:end,1),apAlpha(:,52),'ro')%plot midpoint displacement from low rank approximation
title(['local',' ','reduced dimension',' ',num2str(dim(1)),' ','functions'],'FontSize',15)
toc
end


