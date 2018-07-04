/*
 * =============================================================
 * countw_hmy.c 
  
 * takes one input sorted vector and its corresponding weight, and finds the unique elements and their corresponding weights 
 * 
 * =============================================================
 */

// Reference code: LMNN implementation package provided by Kilian Q. Weinberger at http://www.cs.cornell.edu/~kilian/code/code.html
// Copyright by Meiyu Huang, 2018
// Qian Xuesen Laboratory of Space Technology,
// China Academy of Space Technology, Beijing, China
// Contact huangmeiyu@qxslab.cn

#include "mex.h"

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



void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[])
{
  /* Declare variables. */ 
  int N1,N2, o1,o2,i1,iw,ci,co,r,vi;
  int size1,size2;
  double *pi1, *pi2 , *po1, *po2,*weight;
  int mRows,nCols,mRows2,nCols2;



  /* Check for proper number of input and output arguments. */    
  if (nrhs != 2) {
    mexErrMsgTxt("Two input argument required.");
  } 
  if (nlhs > 2) {
    mexErrMsgTxt("Too many output arguments.");
  }

  /* Check data type of input argument. */
  if (!(mxIsDouble(prhs[0]))) {
    mexErrMsgTxt("Input array must be of type double.");
  }
    
  /* Get the number of elements in the input argument. */
  N1 = mxGetNumberOfElements(prhs[0]);
  

  /* Get the data. */
  pi1  = (double *)mxGetPr(prhs[0]);
  weight  = (double *)mxGetPr(prhs[1]);

  mRows = mxGetM(prhs[0]);
  nCols = mxGetN(prhs[0]);
  mRows2 = mxGetM(prhs[1]);
  nCols2= mxGetN(prhs[1]);
  if(mRows2!=1)
  {
       mexErrMsgTxt("Input weight vector must have ONE row!\n");
  }
  if(nCols!=nCols2)
  {
       mexErrMsgTxt("Hey Bongo! Both input vectors must have same cols!\n");
  }
  /*  m1=mxGetM(prhs[0]);
  n1=mxGetN(prhs[0]);
  m2=mxGetM(prhs[1]);
  n2=mxGetN(prhs[1]);*/
  
  plhs[0]=mxCreateDoubleMatrix(mRows,nCols,mxREAL);
  po1=mxGetPr(plhs[0]);
  plhs[1]=mxCreateDoubleMatrix(1,nCols,mxREAL);
  po2=mxGetPr(plhs[1]);


  ci=0;
  co=-1;
  i1=0;
  iw=0;
  o1=-mRows;
  while(ci<nCols){
    if(ci==0 || pi1[i1]!=po1[o1]){
      o1=o1+mRows;
      for(r=0;r<mRows;r++){
	po1[o1+r]=pi1[i1+r];
      }
    co=co+1;
     po2[co]=weight[iw];
    } else{
      po2[co]=po2[co]+weight[iw];
    }
    ci=ci+1;
    i1=i1+mRows;
    iw=iw+1;
  }

  mxSetN(plhs[0],co+1);
  mxSetN(plhs[1],co+1);
}



