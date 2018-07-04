% This code is the implementation of the WLMNC distance augmented Clustering method
%
% Refrence code: LMNN implementation package provided by Kilian Q. Weinberger at http://www.cs.cornell.edu/~kilian/code/code.html
%
% Copyright by Meiyu Huang, 2018
% Qian Xuesen Laboratory of Space Technology,
% China Academy of Space Technology, Beijing, China
% Contact huangmeiyu@qxslab.cn

function iTe=ncclustering(L,xTr,xTe)
% function iTe=ncclustering(L,xTr,xTe);
%
% Input:
%  L	:   transformation matrix (learned by WLMNC)
%  xTr	:   centers (each column is a center instance)
%  xTe  :   test vectors
%
% Output£º
%  iTe :  index of the nearest centers of the test vectors

KK=1;
Kn=max(KK);
D=length(L);
xTr=L*xTr(1:D,:);
xTe=L*xTe(1:D,:);
B=700;
[NTr]=size(xTr,2);
[NTe]=size(xTe,2);
iTe=zeros(Kn,NTe);
sx1=sum(xTr.^2,1);
sx2=sum(xTe.^2,1);

for i=1:B:NTe
    if(i<=NTe)
        BTe=min(B-1,NTe-i);
        Dtr=addh(addv(-2*xTr'*xTe(:,i:i+BTe),sx1),sx2(i:i+BTe));
        [dist,nc]=mink(Dtr,NTr);
        nc=nc(1:Kn,:);
        iTe(:,i:i+BTe)=nc;
    end;
    %   fprintf('%2.2f%%.:\n',(i+BTr)/NTe*100);
    
end;




