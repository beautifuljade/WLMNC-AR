% This code  is used to train a WLMNC distance for a human posture
%
% Copyright by Meiyu Huang, 2018
% Qian Xuesen Laboratory of Space Technology,
% China Academy of Space Technology, Beijing, China
% Contact huangmeiyu@qxslab.cn


clear all; close all; 
setpaths
path_name='dataset';
path_namet='result';
dataset_name='hug';



%% parameter setup
order=-3;
stepsize=1/2*10^(order);
weightorder=-10;
weight=2^(weightorder);
maxiter=80;
sigmadorder=0;
sigmad=2^(sigmadorder);


%% read ground truth depth map
depthfilename=sprintf('%s\\%s_depth.txt',path_name,dataset_name);
Depth=load(depthfilename);
[m,n]=size(Depth);





%% read skeleton blocks 
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

%% read human mask
labelfilename=sprintf('%s\\%s_label.txt',path_name,dataset_name);
labels=load(labelfilename);
labels(indexl1)=0;
labels(indexl2)=0;

%% find human pixels
mask=(labels>0)&(Depth>0);
index=find(mask>0);
xindex=floor((index+(m-1))/m);
yindex=index-(xindex-1)*m;
xul=[yindex xindex yindex xindex];
yul=[Depth(index) Depth(index)];



%% data normalization
xy=[xl(:,1:2) yl(:,1);xul(:,1:2) yul(:,1);xl(:,3:4) yl(:,2);xul(:,3:4) yul(:,2);];
maxxy=max(xy,[],1);
minxy=min(xy,[],1);
count=size(xy,1);
maxxy=repmat(maxxy,count,1);
minxy=repmat(minxy,count,1);
xy=(xy-minxy)./(maxxy-minxy);
countl=size(xl,1);
countu=size(xul,1);
xl=[xy(1:countl,1:2) xy(countl+countu+1:countl+countu+countl,1:2)];
yl=[xy(1:countl,3) xy(countl+countu+1:countl+countu+countl,3)];
xul=[xy(countl+1:countl+countu,1:2) xy(countl+countu+countl+1:countl+countu+countl+countu,1:2)];
yul=[xy(countl+1:countl+countu,3) xy(countl+countu+countl+1:countl+countu+countl+countu,3)];


%% compute the label of each human pixel 's real nearest skeletal block structure in the three-dimensional physical space
xTr=[xl';yl'];
xTe=[xul';yul'];
NC=ncclustering(eye(size(xTr,1)),xTr,xTe);
X=xul';
Xd=yul';
Z=xl';
Zd=yl';




[L,Det]=wlmnc(X,Z,Xd,Zd,sigmad,NC,stepsize,maxiter,weight);
fprintf('Learning the WLMNC distance costs %f s\n', Det.time);
Lfilename=sprintf('%s\\%s_wlmnc.txt',path_namet,dataset_name);
save(Lfilename,'L','-ASCII');











