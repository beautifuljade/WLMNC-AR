% This code is used to extract skeletal block structures for a human posture
%
% Copyright by Meiyu Huang, 2018
% Qian Xuesen Laboratory of Space Technology,
% China Academy of Space Technology, Beijing, China
% Contact huangmeiyu@qxslab.cn

function  [skeletalblocks,skeletalblocksdepth,skeletonjoints,skeletonjointsdepth]=readskeletalblocks(skeletonfilename)
%  function [skeletalblocks,skeletalblocksdepth,skeletonjoints,skeletonjointsdepth]=readskeletalblocks(skeletonfilename);
%
% input:
%
%             skeletonfilename: skeleton file name
%
% output:
%
%             skeletalblocks: [sj1 sj2]
%             skeletalblocksdepth: [D(sj1), D(sj2)]
%             skeletonjoints:[sj]
%             skeletonjointsdepth:[D(sj)]

data=load(skeletonfilename);
% data: matrix 20*5
% each row describes a skeleton joint, including its label, confidence, X
% coordinate, Y coordinate and depth
% row 1: JOINT_HIP_CENTER
% row 2:JOINT_SPINE
% row 3:JOINT_SHOULDER_CENTER
% row 4:JOINT_HEAD
%
% row 5:JOINT_SHOULDER_LEFT
% row 6:JOINT_ELBOW_LEFT
% row 7:JOINT_WRIST_LEFT
% row 8:JOINT_HAND_LEFT
%
% row 9:JOINT_SHOULDER_RIGHT
% row 10:JOINT_ELBOW_RIGHT
% row 11:JOINT_WRIST_RIGHT
% row 12:JOINT_HAND_RIGHT
%
% row 13:JOINT_HIP_LEFT
% row 14:JOINT_KNEE_LEFT
% row 15:JOINT_ANKLE_LEFT
% row 16:JOINT_FOOT_LEFT
%
% row 17:JOINT_HIP_RIGHT
% row 18:JOINT_KNEE_RIGHT
% row 19:JOINT_ANKLE_RIGHT
% row 20:JOINT_FOOT_RIGHT


xl=[];
yl=[];
xl2=[];
yl2=[];


if(data(1,1)~=0) %detected a human
    if(data(4,2)==1)%detected head joint
        xy=[data(4,4) data(4,3)];
        z=data(4,5);
        xl=[xl;xy xy]; %image coordinates of head joint
        yl=[yl;z z];   % depth of head joint
        xl2=[xl2;xy]; %image coordinates of head joint
        yl2=[yl2;z];   %depth of head joint
        if(data(3,2)==1) %detected center shoulder joint
            oldxy=xy;
            oldz=z;
            xy=[data(3,4) data(3,3)];
            z=data(3,5);
            xl=[xl;oldxy xy];
            yl=[yl;oldz z];
            xl2=[xl2;xy]; %coordinates of center shoulder joint
            yl2=[yl2;z];   %depth of center shoulder joint
            shouldercenterxy=xy;
            shouldercenterz=z;
            shouldercenterflag=0;
            
            if(data(5,2)==1)  %detected left shoulder joint
                oldxy=shouldercenterxy;
                oldz=shouldercenterz;
                shouldercenterflag=1;
                xy=[data(5,4) data(5,3)];
                z=data(5,5);
                xl=[xl;oldxy xy];
                yl=[yl;oldz z];
                xl2=[xl2;xy]; %coordinates of left shoulder joint
                yl2=[yl2;z];   %depth of left shoulder joint
                
                if(data(6,2)==1)%detected  left elbow joint
                    oldxy=xy;
                    oldz=z;
                    xy=[data(6,4) data(6,3)];
                    z=data(6,5);
                    xl=[xl;oldxy xy];
                    yl=[yl;oldz z];
                    xl2=[xl2;xy]; %coordinates of left elbow joint
                    yl2=[yl2;z];   %depth of left elbow joint
                    
                    if(data(7,2)==1)%detected left wrist joint
                        oldxy=xy;
                        oldz=z;
                        xy=[data(7,4) data(7,3)];
                        z=data(7,5);
                        xl=[xl;oldxy xy];
                        yl=[yl;oldz z];
                        xl2=[xl2;xy]; %coordinates of left wrist joint
                        yl2=[yl2;z];   %depth of left wrist joint
                        
                        if(data(8,2)==1)%detected left hand joint
                            oldxy=xy;
                            oldz=z;
                            xy=[data(8,4) data(8,3)];
                            z=data(8,5);
                            xl=[xl;oldxy xy];
                            yl=[yl;oldz z];
                            xl=[xl;xy xy];
                            yl=[yl;z z];
                            xl2=[xl2;xy]; %coordinates of left hand joint
                            yl2=[yl2;z];   %depth of left hand joint
                            
                        else %no left hand joint detected
                            xl=[xl;xy xy];
                            yl=[yl;z z];
                        end
                    else %no left wrist joint detected
                        xl=[xl;xy xy];
                        yl=[yl;z z];
                    end
                else %no left elbow joint detected
                    xl=[xl;xy xy];
                    yl=[yl;z z];
                end
            end
            if(data(9,2)==1) %detected right shoulder joint
                oldxy=shouldercenterxy;
                oldz=shouldercenterz;
                shouldercenterflag=1;
                xy=[data(9,4) data(9,3)];
                z=data(9,5);
                xl=[xl;oldxy xy];
                yl=[yl;oldz z];
                xl2=[xl2;xy]; %coordinates of right shoulder joint
                yl2=[yl2;z];   %depth of right shoulder joint
                
                if(data(10,2)==1)%detected right elbow joint
                    oldxy=xy;
                    oldz=z;
                    xy=[data(10,4) data(10,3)];
                    z=data(10,5);
                    xl=[xl;oldxy xy];
                    yl=[yl;oldz z];
                    xl2=[xl2;xy]; %coordinates of right elbow joint
                    yl2=[yl2;z];   %depth of right elbow joint
                    
                    if(data(11,2)==1)%detected right wrist joint
                        oldxy=xy;
                        oldz=z;
                        xy=[data(11,4) data(11,3)];
                        z=data(11,5);
                        xl=[xl;oldxy xy];
                        yl=[yl;oldz z];
                        xl2=[xl2;xy]; %coordinates of right wrist joint
                        yl2=[yl2;z];   %depth of right wrist joint
                        
                        if(data(12,2)==1)%detected right hand joint
                            oldxy=xy;
                            oldz=z;
                            xy=[data(12,4) data(12,3)];
                            z=data(12,5);
                            xl=[xl;oldxy xy];
                            yl=[yl;oldz z];
                            xl=[xl;xy xy];
                            yl=[yl;z z];
                            xl2=[xl2;xy]; %coordinates of right hand joint
                            yl2=[yl2;z];   %depth of right hand joint
                            
                        else %no right hand joint detected
                            xl=[xl;xy xy];
                            yl=[yl;z z];
                        end
                    else %no right wrist joint detected
                        xl=[xl;xy xy];
                        yl=[yl;z z];
                    end
                else %no right elbow joint detected
                    xl=[xl;xy xy];
                    yl=[yl;z z];
                end
            end
            if(data(2,2)==1) %detected spine joint
                oldxy=shouldercenterxy;
                oldz=shouldercenterz;
                shouldercenterflag=1;
                xy=[data(2,4) data(2,3)];
                z=data(2,5);
                xl=[xl;oldxy xy];
                yl=[yl;oldz z];
                xl2=[xl2;xy]; %coordinates of spine joint
                yl2=[yl2;z];   %depth of spine joint
                
                if(data(1,2)==1)%detected center hip joint
                    oldxy=xy;
                    oldz=z;
                    xy=[data(1,4) data(1,3)];
                    z=data(1,5);
                    xl=[xl;oldxy xy];
                    yl=[yl;oldz z];
                    xl2=[xl2;xy]; %coordinates of center hip joint
                    yl2=[yl2;z];   %depth of center hip joint
                    hipcenterxy=xy;
                    hipcenterz=z;
                    hipcenterflag=0;
                    
                    if(data(13,2)==1)%detected left hip joint
                        oldxy=hipcenterxy;
                        oldz=hipcenterz;
                        hipcenterflag=1;
                        xy=[data(13,4) data(13,3)];
                        z=data(13,5);
                        xl=[xl;oldxy xy];
                        yl=[yl;oldz z];
                        xl2=[xl2;xy]; %coordinates of left hip joint
                        yl2=[yl2;z];   %depth of left hip joint
                        
                        if(data(14,2)==1)%detected left knee joint
                            oldxy=xy;
                            oldz=z;
                            xy=[data(14,4) data(14,3)];
                            z=data(14,5);
                            xl=[xl;oldxy xy];
                            yl=[yl;oldz z];
                            xl2=[xl2;xy]; %coordinates of left knee joint
                            yl2=[yl2;z];   %depth of left knee joint
                            
                            if(data(15,2)==1)%detected left ankle joint
                                oldxy=xy;
                                oldz=z;
                                xy=[data(15,4) data(15,3)];
                                z=data(15,5);
                                xl=[xl;oldxy xy];
                                yl=[yl;oldz z];
                                xl2=[xl2;xy]; %coordinates of left ankle joint
                                yl2=[yl2;z];   %depth of left ankle joint
                                
                                if(data(16,2)==1)%detected leff foot joint
                                    oldxy=xy;
                                    oldz=z;
                                    xy=[data(16,4) data(16,3)];
                                    z=data(16,5);
                                    xl=[xl;oldxy xy];
                                    yl=[yl;oldz z];
                                    xl=[xl;xy xy];
                                    yl=[yl;z z];
                                    xl2=[xl2;xy]; %coordinates of left foot joint
                                    yl2=[yl2;z];   %depth of left foot joint
                                    
                                else %no left foot joint detected
                                    xl=[xl;xy xy];
                                    yl=[yl;z z];
                                end
                            else %no left ankle joint detected
                                xl=[xl;xy xy];
                                yl=[yl;z z];
                            end
                        else %no left knee joint detected
                            xl=[xl;xy xy];
                            yl=[yl;z z];
                        end
                    end
                    if(data(17,2)==1)%detected right hip joint
                        oldxy=hipcenterxy;
                        oldz=hipcenterz;
                        hipcenterflag=1;
                        xy=[data(17,4) data(17,3)];
                        z=data(17,5);
                        xl=[xl;oldxy xy];
                        yl=[yl;oldz z];
                        xl2=[xl2;xy]; %coordinates of right hip joint
                        yl2=[yl2;z];   %depth of right hip joint
                        
                        if(data(18,2)==1)%detected right knee joint
                            oldxy=xy;
                            oldz=z;
                            xy=[data(18,4) data(18,3)];
                            z=data(18,5);
                            xl=[xl;oldxy xy];
                            yl=[yl;oldz z];
                            xl2=[xl2;xy]; %coordinates of right knee joint
                            yl2=[yl2;z];   %depth of right knee joint
                            
                            if(data(19,2)==1)%detected right ankle joint
                                oldxy=xy;
                                oldz=z;
                                xy=[data(19,4) data(19,3)];
                                z=data(19,5);
                                xl=[xl;oldxy xy];
                                yl=[yl;oldz z];
                                xl2=[xl2;xy]; %coordinates of right ankle joint
                                yl2=[yl2;z];   %depth of right ankle joint
                                
                                if(data(20,2)==1)%detected right foot joint
                                    oldxy=xy;
                                    oldz=z;
                                    xy=[data(20,4) data(20,3)];
                                    z=data(20,5);
                                    xl=[xl;oldxy xy];
                                    yl=[yl;oldz z];
                                    xl=[xl;xy xy];
                                    yl=[yl;z z];
                                    xl2=[xl2;xy]; %coordinates of right foot joint
                                    yl2=[yl2;z];   %depth of right foot joint
                                    
                                else %no right foot joint detected
                                    xl=[xl;xy xy];
                                    yl=[yl;z z];
                                end
                            else %no right ankle joint detected
                                xl=[xl;xy xy];
                                yl=[yl;z z];
                            end
                        else %no right knee joint detected
                            xl=[xl;xy xy];
                            yl=[yl;z z];
                        end
                    end
                    if(hipcenterflag==0)%no left hip joint, right hip joint detected
                        xl=[xl;hipcenterxy hipcenterxy];
                        yl=[yl;hipcentery hipcentery];
                    end
                else %no center hip joint detected
                    xl=[xl;xy xy];
                    yl=[xl;z z];
                end
            else %no spine joint detected
                xl=[xl;xy xy];
                yl=[yl;z z];
            end
            if(shouldercenterflag==0)%no lef shoulder joint, right shoulder joint, spine joint detected
                xl=[xl;shouldercenterxy shouldercenterxy];
                yl=[yl;shoudercenterz shouldercenterz];
            end
        else %no center shoulder joint detected
            xl=[xl;xy xy];
            yl=[yl;z z];
        end
    end
end
skeletalblocks=xl+1; % c coordinates to matlab coordinates
skeletalblocksdepth=yl;
skeletonjoints=xl2+1; % c coordinates to matlab coordinates
skeletonjointsdepth=yl2;
end
