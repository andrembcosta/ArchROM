load('maxdispcell')
N=5;%number of different scenarios
snap=cell(1,N);%initialize cell
probsnap=zeros(50,60);
threshold=23;%threshold for dynamical snap in nondimensional units
for i=1:N
    snap{i}=zeros(50,60);
    snap{i}(find(maxdisp{i}>threshold))=1;
    probsnap=probsnap+snap{i};
end
probsnap=probsnap/N;
surf(probsnap)
colorbar
