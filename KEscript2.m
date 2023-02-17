%kinetic energy script
tic
yresolution=50;
xresolution=60;
KEmatrix=zeros(50,60);
for i=26:yresolution
    parfor j=1:xresolution
        KEmatrix2(i,j)=Kenergy(i,j);
    end
    disp(i)
end
toc