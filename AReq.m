function [totaltime,result]=AReq(block_sizem,block_sizen,sampledepth,mask,halfwindow_size,lamda,usespatial,halfsearch_size,sigmaw,usecolor,colormap,sigmac,sigmab,usedepth,guidedmap,sigmad)

[m,n]=size(sampledepth);
result=zeros(m,n);
totaltime=0;
for i=1:block_sizem:m
    BM=min(block_sizem,m-i+1);
    for j=1:block_sizen:n
        BN=min(block_sizen,n-j+1);
        sampledepth_temp=sampledepth(i:i+BM-1,j:j+BN-1,:);%sampled depth image
        mask_temp=mask(i:i+BM-1,j:j+BN-1,:);%mask image
        colormap_temp=colormap(i:i+BM-1,j:j+BN-1,:);%guide color image
        guidedmap_temp=guidedmap(i:i+BM-1,j:j+BN-1,:); %guide depth image
        [blocktime,X]=AReq_block(sampledepth_temp,mask_temp,halfwindow_size,lamda,usespatial,halfsearch_size,sigmaw,usecolor,colormap_temp,sigmac,sigmab,usedepth,guidedmap_temp,sigmad);
        totaltime=totaltime+blocktime;
        result(i:i+BM-1,j:j+BN-1)=X;
    end
end