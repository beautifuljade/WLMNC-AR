/*
 * =============================================================
 * findimps3D_hmy.c 
  
 * takes two input matrices X1,X2 and one vector t1
 * 
 * equivalent to: 
 *     Dist=distance(X1.'*X2);
 *     imp1=find(Dist<repmat(t1,N1,1))';
 *     [a,b]=ind2sub([N1,N2],[imp1]);
 *
  * =============================================================
 */


// Reference code: LMNN implementation package provided by Kilian Q. Weinberger at http://www.cs.cornell.edu/~kilian/code/code.html
// Copyright by Meiyu Huang, 2018
// Qian Xuesen Laboratory of Space Technology,
// China Academy of Space Technology, Beijing, China
// Contact huangmeiyu@qxslab.cn


#include "mex.h"
//#include "stdio.h"

/* If you are using a compiler that equates NaN to zero, you must
 * compile this example using the flag -DNAN_EQUALS_ZERO. For 
 * example:
 *
 *     mex -DNAN_EQUALS_ZERO findnz.c  
 *
 * This will correctly define the IsNonZero macro for your
   compiler. */

#if NAN_EQUALS_ZERO
#define IsNonZero(d) ((d) != 0.0 || mxIsNaN(d))
#else
#define IsNonZero(d) ((d) != 0.0)
#endif


double square(double x) { return(x*x);}

void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[])
{
  /* Declare variables. */ 
  int N1,N2, o1,o2,ind;
  int c,r,size1,size2;
  double *x1,*x2,*po,*X1,*X2,*Thresh1;
  int m,p,n, oi;
  char *chn="N"; 
  char *chn2="T";
  double d2=0,minustwo=-2.0,one=1.0, zero=0.0, bigguy;



  /* Check for proper number of input and output arguments. */    
  if (nrhs != 3)
    mexErrMsgTxt("three input arguments required.");
   

  if (nlhs > 1) {
    mexErrMsgTxt("Too many output arguments.");
  }

  /* Check data type of input argument. */
  if (!(mxIsDouble(prhs[0]))) {
   mexErrMsgTxt("Input array must be of type double.");
  }

    
  /* Get the number of elements in the input argument. */
/*  N1 = mxGetNumberOfElements(prhs[0]);/*


  /* Get the data. */
  X1  = mxGetPr(prhs[0]);
  X2  = mxGetPr(prhs[1]);
  Thresh1=mxGetPr(prhs[2]);


  p = mxGetM(prhs[0]);
  m = mxGetN(prhs[0]);
  n = mxGetN(prhs[1]);
 // printf("number of samples:%d",n);
  
 if(p!=mxGetM(prhs[1])) mexErrMsgTxt("Inner dimensions must agree!\n");
 if(n!=mxGetN(prhs[2])) mexErrMsgTxt("Threshold1 must be of same length as second input has columns!\n");
  


  plhs[0]= mxCreateDoubleMatrix(2,m*n,mxREAL);
  po=mxGetPr(plhs[0]);
  
  oi=0;x2=&X2[0];//samples
 for(c=0;c<n;c++) {
   x1=&X1[0];//centers
   bigguy=Thresh1[c];
   for(r=0;r<m;r++){
	d2=0;
	

/*    for(ind=0;ind<p && (d2<bigguy);ind++) d2+=square(x1[ind]-x2[ind]);
    if(ind==p){po[oi]=r+1;po[oi+1]=c+1;oi=oi+2;};*/
    for(ind=0;ind<p && d2<bigguy;ind++) d2+=square(x1[ind]-x2[ind]);
    if(d2<bigguy){
		po[oi]=r+1;po[oi+1]=c+1;oi=oi+2;
		};

	x1+=p;
   }
   x2+=p;
  }
 /* 
  mxSetN(plhs[0],ceil(oi/2));  
 */

}



