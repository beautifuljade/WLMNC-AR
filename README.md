# WLMNC-AR

Author:  Meiyu Huang, Qian Xuesen Laboratory of Space Technology, China Academy of Space Technology, Beijing, China

This package contains the novel dataset and sample code for implementation of the WLMNC-AR based Human Depth Recovery method. If you use this file or package for your work, please refer to the following paper:

[1]. Meiyu Huang, Xueshuang Xiang, Yiqiang Chen, Da Fan, "Weighted large margin nearest center distance based human depth recovery with limited bandwidth consumption", IEEE Transactions on Image Processing,2018.

Reference code:

1.LMNN implementation package provided by Kilian Q. Weinberger at http://www.cs.cornell.edu/~kilian/code/code.html

2.AR implementation package provided by Jingyu Yang et al. at http://cs.tju.edu.cn/faculty/likun/projects/depth_recovery/index.htm


Code Usage:

1.run install.m to compile all mex functions

2.run trainwlmnc.m to train a WLMNC distance for a human posture

3.run testwlmncar.m to recover a rough and fine depth map for a human posture, and compute recovery mad error

4.run drawwlmncar.m to recover a rough and fine depth map for a human posture, and draw the skeletal block structure division result, the recovered rough and fine depth map.

Please contact huangmeiyu@qxslab.cn for problems in using this code. 
