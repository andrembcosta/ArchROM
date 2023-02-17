%kinetic energy script
tic
yresolution=50;
xresolution=60;
KEmatrix=zeros(50,60);
for i=1:25%yresolution
    parfor j=1:xresolution
        KEmatrix(i,j)=Kenergy(i,j);
    end
    disp(i)
end
toc