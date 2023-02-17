tic
yresolution=50;
xresolution=60;
maxdisp1=zeros(50,60);
for i=1:25%yresolution
    parfor j=1:xresolution
        Str=load(strcat('RO_p',num2str(i),'fr',num2str(j)));
        maxdisp1(i,j)=max(abs(Str.Du_mid(1:200*100)));
    end
    disp(i)
end
numofsnaps=zeros(1,70);
for k=1:1:70
    numofsnaps(k)=size(find(maxdisp>k),1);
end
plot(numofsnaps)
toc