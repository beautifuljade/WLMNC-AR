
%This code is used to recover a rough and fine depth map for a human posture, and draw the skeletal block structure division result, the recovered rough and fine depth map.
%
% Copyright by Meiyu Huang, 2018
% Qian Xuesen Laboratory of Space Technology,
% China Academy of Space Technology, Beijing, China
% Contact huangmeiyu@qxslab.cn

clear all; close all; 
path_name='dataset';
path_namet='result';
dataset_name='hug';
sigmad=32;


%% parameter setup
halfwindowsize=4;
Lamda=0.01;
usespatial=1;
halfsearchsize=3;
sigmaw=7;
usecolor=1;
sigmac=0.35*1.732*11;
sigmab=0.1;
usedepth=1;

blockcolor=5;
backcolorb=150;
backcolor=150;
color = {'spring','summer','autumn','winter','vga','cool','bone'};   % �洢Ϊcell�ṹ


%% read ground truth depth map
depthfilename=sprintf('%s\\%s_depth.txt',path_name,dataset_name);
Depth=load(depthfilename);
[m,n]=size(Depth);




%% read skeletal blocks 
skeletonfilename=sprintf('%s\\%s_skeleton.txt',path_name,dataset_name);
[xl,SkeletalBlocksDepth,SkeletonJoints,SkeletalJointsDepth]=readskeletalblocks(skeletonfilename);


%% remove skeleton joints outside of the region of the remote human and
%% those with much different depths from the corresponding pixels
thres=200;
SampleIndex=(SkeletonJoints(:,2)-1)*m+SkeletonJoints(:,1);
SampleDepth=Depth(SampleIndex);
diff=abs(SampleDepth-SkeletalJointsDepth);
indexn=(diff<thres);
SampleIndex=SampleIndex(indexn,:);
SkeletonJoints=SkeletonJoints(indexn,:);


%% remove invalid skeletal block structures
indexl1=(xl(:,2)-1)*m+xl(:,1);
indexl2=(xl(:,4)-1)*m+xl(:,3);
yl=[Depth(indexl1) Depth(indexl2)];
diff=abs(yl-SkeletalBlocksDepth);
indexn=(~(diff(:,1)>=thres &diff(:,2)>=thres));
yl=yl(indexn,:);
xl=xl(indexn,:);
indexl1=indexl1(indexn,:);
indexl2=indexl2(indexn,:);
diff=diff(indexn,:);
indexn1=(diff(:,1)<thres &diff(:,2)>=thres);
indexn2=(diff(:,1)>=thres &diff(:,2)<thres);
yl(indexn1,:)=[yl(indexn1,1) yl(indexn1,1)];
xl(indexn1,:)=[xl(indexn1,1:2) xl(indexn1,1:2)];
yl(indexn2,:)=[yl(indexn2,2) yl(indexn2,2)];
xl(indexn2,:)=[xl(indexn2,3:4) xl(indexn2,3:4)];
indexl2(indexn1,:)=indexl1(indexn1,:);
indexl1(indexn2,:)=indexl2(indexn2,:);
[xx,uindex]=unique(xl,'rows');
uindex=sort(uindex);
xl=xl(uindex,:);
yl=yl(uindex,:);
indexl1=indexl1(uindex,:);
indexl2=indexl2(uindex,:);

%% read original human mask
labelfilename=sprintf('%s\\%s_label.txt',path_name,dataset_name);
labels=load(labelfilename);
labels(indexl1)=0;
labels(indexl2)=0;

%%  find original human pixels
mask=(labels>0)&(Depth>0);
index=find(mask>0);
xindex=floor((index+(m-1))/m);
yindex=index-(xindex-1)*m;
xul=[yindex xindex yindex xindex];
yul=[Depth(index) Depth(index)];


%% compute normalization factor
xy=[xl(:,1:2) yl(:,1);xul(:,1:2) yul(:,1);xl(:,3:4) yl(:,2);xul(:,3:4) yul(:,2);];
maxxy=max(xy,[],1);
minxy=min(xy,[],1);
maxd=maxxy(end);
mind=minxy(end);


%% read corrected human mask
labelfilename=sprintf('%s\\%s_mask.txt',path_name,dataset_name);
labels=load(labelfilename);
labels(indexl1)=0;
labels(indexl2)=0;

%%  find corrected human pixels
mask=labels>0;
index=find(mask>0);
xindex=floor((index+(m-1))/m);
yindex=index-(xindex-1)*m;
xul=[yindex xindex yindex xindex];
yul=[Depth(index) Depth(index)];

%% data normalization
xy=[xl(:,1:2) yl(:,1);xul(:,1:2) yul(:,1);xl(:,3:4) yl(:,2);xul(:,3:4) yul(:,2);];
count=size(xy,1);
maxxy=repmat(maxxy,count,1);
minxy=repmat(minxy,count,1);
xy=(xy-minxy)./(maxxy-minxy);
indexout=xy<0;
xy(indexout)=0;
indexout=xy>1;
xy(indexout)=1;
countl=size(xl,1);
countu=size(xul,1);
xl=[xy(1:countl,1:2) xy(countl+countu+1:countl+countu+countl,1:2)];
yl=[xy(1:countl,3) xy(countl+countu+1:countl+countu+countl,3)];
xul=[xy(countl+1:countl+countu,1:2) xy(countl+countu+countl+1:countl+countu+countl+countu,1:2)];
yul=[xy(countl+1:countl+countu,3) xy(countl+countu+countl+1:countl+countu+countl+countu,3)];


%% read linear transformation matrix learned by WLMNC
Lfilename=sprintf('%s\\%s_wlmnc.txt',path_namet,dataset_name);
L=load(Lfilename);


%% compute each human pixel 's nearest skeletal block structure using the
%% WLMNC distance augmented clustering approach 
xTr=xl';
xTe=xul';
IdxL=ncclustering(L,xTr,xTe);
xTeK=xTr(:,IdxL);

SkeletalBlockimgL=backcolorb*ones(m,n);
SkeletalBlockimgL(indexl1)=[1:countl]'*blockcolor;
SkeletalBlockimgL(indexl2)=[1:countl]'*blockcolor;
SkeletalBlockimgL(index)=IdxL'*blockcolor;
figure(1);
imshow(uint8(SkeletalBlockimgL));
colormap(color{5});
drawnow;

%%  compute each human pixel's rough depth based on WLMNC distance augmented clustering 
diff2=sqrt(sum((L*[xTeK(1:2,:);xTeK(1:2,:)]-L*xTe).^2,1));
diff1=sqrt(sum((L*[xTeK(3:4,:);xTeK(3:4,:)]-L*xTe).^2,1));
diff=[diff1' diff2'];
yulkL=yl(IdxL',:);
yulkL=sum(yulkL.*diff,2)./sum(diff,2);


%% construct guide depth map, interval[0,255]
GuideDepth=zeros(m,n);
GuideDepth(indexl1)=yl(:,1)*255;
GuideDepth(indexl2)=yl(:,2)*255;
GuideDepth(index)=yulkL*255;


%% ground truth depth of skeleton joints, interval[0,255]
SampleDepth=zeros(m,n);
SampleDepth(indexl1)=yl(:,1)*255;
SampleDepth(indexl2)=yl(:,2)*255;

%% read guide color image
Color =double(imread([path_name '\\' dataset_name '_color.bmp']));
yuvColor=image_rgb2yuv(Color);


mask(indexl1)=1;
mask(indexl2)=1;
[block_sizem,block_sizen]=size(Depth);

%% running AR model
[time,result]=AReq(block_sizem,block_sizen,SampleDepth,mask,halfwindowsize,Lamda,usespatial,halfsearchsize,sigmaw,usecolor,yuvColor,sigmac,sigmab,usedepth,GuideDepth,sigmad);
indexout=result<0;
result(indexout)=0;
indexout=result>255;
result(indexout)=255;


%% Show the ground truth and recovered depth map
ColorSection=backcolor*ones(m,n,3);
masks=repmat(mask,[1 1 3]);
ColorSection(masks)=Color(masks);
ColorSection(masks)=Color(masks);
DepthSection=backcolor*ones(m,n);
DepthSection(indexl1)=255-yl(:,1)*255;
DepthSection(indexl2)=255-yl(:,2)*255;
DepthSection(index)=255-yul(:,1)*255;
index0=Depth==0& mask>0;
DepthSection(index0)=0;
DepthSection=repmat(DepthSection,[1 1 3]);
drawGuideDepth=backcolor*ones(m,n);
drawGuideDepth(mask)=255-GuideDepth(mask);
drawGuideDepth=repmat(drawGuideDepth,[1 1 3]);
drawresult=backcolor*ones(m,n);
drawresult(mask)=255-result(mask);
drawresult=repmat(drawresult,[1 1 3]);
figure(2);
subplot(2,2,1);imshow(uint8(ColorSection));title('Color Image');axis off
subplot(2,2,2);imshow(uint8(DepthSection));title('Ground Truth');axis off
subplot(2,2,3);imshow(uint8(drawGuideDepth));title('Rough Depth Map');axis off
subplot(2,2,4);imshow(uint8(drawresult));title('Fine Depth Map');axis off

if(~exist(path_namet,'dir'))
        mkdir(path_namet)         
end
roughdepthfilename=sprintf('%s\\%s_roughdepth.bmp',path_namet,dataset_name);
imwrite(uint8(drawGuideDepth),roughdepthfilename);
finedepthfilename=sprintf('%s\\%s_finedepth.bmp',path_namet,dataset_name);
imwrite(uint8(drawresult),finedepthfilename);


