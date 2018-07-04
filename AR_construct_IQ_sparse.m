% This code is used to construct AR coefficients
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

function NLM = AR_construct_IQ_sparse(mask,halfwindow_size,usespatial,halfsearch_size,sigmaw,usecolor,colormap_temp,sigmac,sigmab,usedepth,guidedmap_temp,sigmad)

[block_sizeM, block_sizeN]=size(mask);
%non-local term
w=halfwindow_size;%half size of the search window
f=halfsearch_size;%block size to diff

if(usespatial)
    [X,Y] = meshgrid(-f:f,-f:f);
    G_kernel = exp(-(X.^2+Y.^2)/(2*sigmaw^2));%gaussian kernal
end

if(usedepth)
    if(sigmad)
        sigmad=repmat(sigmad,[block_sizeM, block_sizeN]);
    else
        [Dx,Dy]= gradient(guidedmap_temp);
        D = sqrt(Dx.^2+Dy.^2);
        norm_D = (D-min(D(:)))/(max(D(:))-min(D(:)));
        sigmad = 3*exp(-log(6)*norm_D);
    end
end

if(usecolor)
    image = padarray(colormap_temp, [f,f], 'symmetric');
end

index=find(mask~=0);
flags=zeros(block_sizeM, block_sizeN);
flags(index)=1:size(index,1);
label = padarray(mask, [f,f], 'symmetric');

yindex=[];
xindex=[];
value=[];
for t=1:block_sizeN
    for s=1:block_sizeM
        if(label(s+f,t+f)~=0)
            NLM_temp=zeros(2*w+1);
            sMin = max(s-w,1);
            sMax = min(s+w,block_sizeM);
            tMin = max(t-w,1);
            tMax = min(t+w,block_sizeN);
            
            if(usecolor)
                sigma_P=image(s:s+2*f,t:t+2*f,:);
                label_P=label(s:s+2*f,t:t+2*f);
                dR = abs(sigma_P(:,:,1)-image(s+f,t+f,1));
                dG = abs(sigma_P(:,:,2)-image(s+f,t+f,2));
                dB = abs(sigma_P(:,:,3)-image(s+f,t+f,3));
                color_kernel = exp(-(dR.^2+dG.^2+dB.^2)/(2*3*sigmab^2));   
                if(usespatial)
                    color_kernel =color_kernel.*G_kernel;
                end
                for k=sMin+f:sMax+f
                    for l=tMin+f:tMax+f
                        if ~(k==(s+f) && l==(t+f))
                            if(label(k,l)~=0)
                                sigma_Q=image(k-f:k+f,l-f:l+f,:);
                                label_Q=label(k-f:k+f,l-f:l+f);
                                diff=sum((sigma_P-sigma_Q),3);
                                kpq=exp(-sum(sum (label_P.*label_Q.*color_kernel.*(diff.^2)))/(2*3*sigmac^2));
                                NLM_temp(k-f-s+w+1,l-f-t+w+1)=-kpq;
                            end
                        end
                    end
                end
            end
            if(usedepth)
                guided_kernel=zeros(2*w+1);       
                minsigmad=min(sigmad(sMin:sMax,tMin:tMax),sigmad(s,t));
                guided_kernel((sMin:sMax)-s+w+1,(tMin:tMax)-t+w+1)=...
                    exp(-(abs(guidedmap_temp(sMin:sMax,tMin:tMax)-guidedmap_temp(s,t))).^2./(2*minsigmad.^2));
                guided_kernel(w+1,w+1)=0;
                mask_temp=zeros(2*w+1);  
                mask_temp((sMin:sMax)-s+w+1,(tMin:tMax)-t+w+1)=mask(sMin:sMax,tMin:tMax);
                if(usecolor)
                    NLM_temp=NLM_temp.*guided_kernel.*(mask_temp>0);
                else
                    NLM_temp=-guided_kernel.*(mask_temp>0);
                end             
            end
            
            if(sum(NLM_temp(:))~=0)
                NLM_temp=-NLM_temp/sum(NLM_temp(:));
            end
            NLM_temp(w+1,w+1)=1;
            [y,x]=meshgrid((sMin:sMax),(tMin:tMax));
            y=y';
            x=x';
            xindextemp=(x-1)*block_sizeM+y;
            xindextemp=xindextemp(:);
            indextemp=mask(xindextemp)~=0;
            xindextemp=flags(xindextemp(indextemp));
            yindextemp=repmat(flags((t-1)*block_sizeM+s),[size(xindextemp,1),1]);
            valuetemp=NLM_temp((sMin:sMax)-s+w+1,(tMin:tMax)-t+w+1);
            valuetemp=valuetemp(indextemp);
            yindex=[yindex;yindextemp];
            xindex=[xindex;xindextemp];
            value=[value;valuetemp];
        end
    end
    NLM=sparse(yindex,xindex,value,size(index,1),size(index,1));
end







