% This code is the implementation of  the rough-to-fine depth recovery method based on WLMNC-AR in the local stage
%
% Refrence code: AR implementation package provided by Jingyu Yang et al. at http://cs.tju.edu.cn/faculty/likun/projects/depth_recovery/index.htm
%
% Main change: 
%          1)  make the code work on human area by introducing the  human mask; 
%          2)  make the code work for large block sizes by using sparse matrix.
%
% Copyright by Meiyu Huang, 2018
% Qian Xuesen Laboratory of Space Technology,
% China Academy of Space Technology, Beijing, China
% Contact huangmeiyu@qxslab.cn

function [blocktime,X]=AReq_block(sampledepth,mask,halfwindow_size,lamda,usespatial,halfsearch_size,sigmaw,usecolor,colormap_temp,sigmac,sigmab,usedepth,guidedmap_temp,sigmad)
tic
G_temp=sampledepth;
G_column=G_temp(:);
G_column_index=find(G_column~=0);
[BM,BN]=size(sampledepth);
X=zeros(BM,BN);
if(~isempty(G_column_index))

    G_column_valid=G_column(G_column_index);
    flags=zeros(BM,BN);
    index=find(mask>0);
    flags(index)=1:size(index,1);
    
    yindex=1:length(G_column_valid);
    yindex=yindex';
    xindex=flags(G_column_index(yindex));
    P=sparse(yindex,xindex,1,length(G_column_valid),length(index));
    %AR construct
    Q = AR_construct_IQ_sparse(mask,halfwindow_size,usespatial,halfsearch_size,sigmaw,usecolor,colormap_temp,sigmac,sigmab,usedepth,guidedmap_temp,sigmad);
    
    
    %%%%%%%%%%%%%%%%%
    %PtP=P'*P, B = Ptd construct
    PtP = P'*P;
    B = P'*G_column_valid;
    %%%%%%%%%%%%%%%%%%
    QtQ = Q'*Q;
    %%%%%%%%%%%%%%%%%%
    % Recovery
    X(index)=(PtP+lamda*QtQ)\B;
    
    % fun = @(x)funX(x,lamda,Q,PtP);
    % [X(index), FLAG,RELRES,ITER]=pcg(fun,B,1e-10,20000);
end
blocktime=toc;
end

function u = funX(x,lamda,Q,PtP)
u = PtP*x+ lamda*Q'*(Q*x);
end