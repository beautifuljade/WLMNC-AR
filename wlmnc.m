% This code is the implementation of the WLMNC distance learning method in the remote stage
%
% Refrence code: LMNN implementation package provided by Kilian Q. Weinberger at http://www.cs.cornell.edu/~kilian/code/code.html
%
% Copyright by Meiyu Huang, 2018
% Qian Xuesen Laboratory of Space Technology,
% China Academy of Space Technology, Beijing, China
% Contact huangmeiyu@qxslab.cn



function [L,Det]=wlmnc( x,z,xd,zd,sigmad,NC,stepsize,maxiter,weight1)
%function [L,iter,Det]=wlmnc( x,z,xd,zd,sigmad,NC,stepsize,maxiter,weight1)
%
%Input:
%
% x = input matrix (each column is an input vector) 
% z = input  centers (each column is a center instance)  
% xd= ground truth depth of the input matrix
% zd= ground truth depth of the input centers
% sigmad= a parameter determines the penalty weight on invading triples
% NC= nearest center index of the input matrix  
% stepsize = step parameter
% maxiter= maximum iteration number
% weight1= a parameter adjusts the importance of the two terms of the objective function

% Output:
%
% L = linear transformation xnew=L*x
%    
% Det.obj = objective function over time
% Det.nimp = number of impostors over time
% Det.pars = all parameters used in run
% Det.time = time needed for computation
% Det.iter = number of iterations

tic

% set parameters
% thresho = (def 1e-3) cut off for change in objective function (if
% improvement is less, stop)
pars.thresho=1e-3;
% thresha = (def 1e-30) cut off for stepsize, if stepsize is
% smaller stop
pars.thresha=1e-30;
% obj = (def 1) if 1, solver solves in L, if 0, solver solves in L'*L
pars.obj=1;
% quiet = {0,1} surpress output (default=0)  
pars.quiet=0; 
%maximp=(def 100000) cut off for number of impostors, if nimp
% is bigger, some impostors are discarded
pars.maximp=100000; 

pars.aggressive=0;
pars.stepsize=stepsize;
pars.minstepsize=0;
pars.maxiter=maxiter;
pars.weight1=weight1;
stepsize=pars.stepsize;




obj=zeros(1,pars.maxiter);
nimp=zeros(1,pars.maxiter);

D=size(z,1);
df=zeros(D^2,1);
N=size(x,2);
gen1=vec(NC')';
gen2=vec((1:N)')';
dfG=vec(SOD_hmy(x,z,gen2,gen1));

%³õÊ¼»¯¾ØÕó
L=eye(D);
for iter=1:pars.maxiter
    % save old position
    Lold=L;dfold=df;
    
    if(iter>1)
        L=step(L,mat((dfG.*pars.weight1+df.*(1-pars.weight1))),stepsize,pars);
    end
    
    if(~pars.quiet)fprintf('%i.',iter);end;
    Lx=L*x;
    Lz=L*z;
    
    %Compute the squared WLMNC distance of input vectors to its target cluster centers plus one absolute unit of distance
    Ni=(sum((Lx-Lz(:,NC)).^2)+1);
    %Compute invading triples
    imp= checkup(Lx,Lz,NC,Ni,pars);
    clear('Lx');
    clear('Lz');
    %Compute the penalty weight on invading triples
    weightimp=1-exp(-sum((xd(:,imp(2,:))-zd(:,imp(1,:))).^2,1)/(2*sigmad.^2));

 
    MINUS1b=imp(1,:);
    MINUS2b=imp(2,:);
    
    [isplus2,i]= sort(imp(2,:));
    PLUS1a=isplus2; 
    PLUS2a=NC(:,isplus2);
    isweightimp=weightimp(:,i);
    [PLUS ,pweight]=countw_hmy([PLUS1a;PLUS2a],isweightimp);
    
    df2=SODW_hmy(x,z,PLUS(1,:),PLUS(2,:),pweight);
    df4=-SODW_hmy(x,z,MINUS2b,MINUS1b,weightimp);
    df=vec(df2+df4);
    totalweight=sum(weightimp,2);
    totalactive=size(imp,2);
    
    
    if(any(any(isnan(df))))
        fprintf('Gradient has NaN value!\n');
        keyboard;
        return;
    end;
    
    obj(iter)=(dfG.*pars.weight1+df.*(1-pars.weight1))'*vec(L'*L)+totalweight.*(1-pars.weight1);
    
    
    if(isnan(obj(iter)))
        fprintf('Obj is NAN!\n');
        keyboard;
        return;
    end;
    
    nimp(iter)=totalactive;
    delta=obj(iter)-obj(max(iter-1,1));
    deltanimp=nimp(iter)-nimp(max(iter-1,1));
    if(~pars.quiet)fprintf(['  Obj:%2.2f Nimp:%i Delta:%2.4f Deltanimp:%i max(G):' ...
            ' %2.4f' ...
            '             \n   '],obj(iter),nimp(iter),delta,deltanimp,max(max(abs(df))));
    end;
    
    
    

    if(iter>1 && (delta>=0))
        stepsize=stepsize*0.5;
        fprintf('***correcting stepsize***\n');
        if(stepsize<pars.minstepsize) stepsize=pars.minstepsize;end;
        if(~pars.aggressive)
            L=Lold;
            df=dfold;
            obj(iter)=obj(iter-1);
            nimp(iter)=nimp(iter-1);
        end;
        
    end;
    
    if(iter>10  && (max(abs(diff(obj(iter-3:iter))))<=pars.thresho*obj(iter) ...
            || stepsize<pars.thresha))
        
        switch(pars.obj)
            case 0
                if(~pars.quiet)fprintf('Stepsize too small. No more progress!\n');end;
                break;
            case 1
                pars.obj=0;
                pars.stepsize=1e-15;
                % if(~pars.quiet | 1)
                if(~pars.quiet)
                    fprintf('\nVerifying solution! %i\n',obj(iter));
                end;
            case 3
                if(~pars.quiet)fprintf('Stepsize too small. No more progress!\n');end;
                break;
        end;
    end;
end


% Output
Det.obj=obj(1:iter);
Det.nimp=nimp;
Det.pars=pars;
Det.time=toc;
Det.iter=iter;
end



function L=step(L,G,stepsize,pars);

% do step in gradient direction
if(size(L,1)~=size(L,2)) pars.obj=1;end;
switch(pars.obj)
    case 0    % updating Q
        Q=L'*L;
        Q=Q-stepsize.*G;
    case 1   % updating L
        G=2.*(L*G);
        L=L-stepsize.*G;
        return;
    case 2    % multiplicative update
        Q=L'*L;
        Q=Q-stepsize.*G+stepsize^2/4.*G*inv(Q)*G;
        return;
    case 3
        Q=L'*L;
        Q=Q-stepsize.*G;
        Q=diag(Q);
        L=diag(sqrt(max(Q,0)));
        return;
    otherwise
        error('Objective function has to be 0,1,2\n');
end;

% decompose Q
[L,dd]=eig(Q);
dd=real(diag(dd));
L=real(L);
% reassemble Q (ignore negative eigenvalues)
j=find(dd<1e-10);
if(~isempty(j))
    if(~pars.quiet)fprintf('[%i]',length(j));end;
end;
dd(j)=0;
[temp,ii]=sort(-dd);
L=L(:,ii);
dd=dd(ii);
% Q=L*diag(dd)*L';
L=(L*diag(sqrt(dd)))';

%for i=1:size(L,1)
% if(L(i,1)~=0) L(i,:)=L(i,:)./sign(L(i,1));end;
%end;
end

function imp=checkup(Lx,Lz,NC,Ni,pars)
if(~pars.quiet)fprintf('Computing nearest center ...\n');end;
[D,N]=size(Lx);

un=size(Lz,2);
imp=[];
index=1:N;
index1=1:un;
for c=1:(un)
    if(~pars.quiet)fprintf('All nearest impostor centers for cluster %i :',c);end;
    i=index(NC(index)==c);
    if(~isempty(i))
        index=index(NC(index)~=c);
        otherindex1=index1(index1~=c);
        limps=LSImps2(Lz(:,otherindex1),Lx(:,i),Ni(i),pars);
        if(size(limps,2)>pars.maximp)
            ip=randperm(size(limps,2));
            ip=ip(1:pars.maximp);
            limps=limps(:,ip);
        end;
        imp=[imp [otherindex1(limps(1,:));i(limps(2,:))]];
    end
    if(~pars.quiet)fprintf('\r');end;
end;


end

function limps=LSImps2(X1,X2,Thresh1,pars)
B=750;
[D,N2]=size(X2);
limps=[];
for i=1:B:N2
    BB=min(B,N2-i+1);
    try
       
        newlimps=findimps3Dac_hmy(X1,X2(:,i:i+BB-1),Thresh1(i:i+BB-1));
        if(~isempty(newlimps) && newlimps(end)==0)
            [minv,endpoint]=min(min(newlimps));
            newlimps=newlimps(:,1:endpoint-1);
        end;
        
    catch
        keyboard;
    end;
    newlimps(2,:)=newlimps(2,:)+i-1;
    limps=[limps newlimps];
    if(~pars.quiet)fprintf('(%i%%) ',round((i+BB-1)/N2*100)); end;
end;
if(~pars.quiet)fprintf(' [%i] ',size(limps,2));end;
end
