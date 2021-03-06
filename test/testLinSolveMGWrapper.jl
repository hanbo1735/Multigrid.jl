using jInv.Mesh
using jInv.LinearSolvers
using Base.Test
using KrylovMethods
using Multigrid

println("===  Example 2D DivSigGrad ====");

domain = [0.0, 1.0, 0.0, 1.0];
n      = [50,50];
Mr     = getRegularMesh(domain,n)
G      = getNodalGradientMatrix(Mr);
m      = spdiagm(exp.(randn(size(G,1))));
Ar     = G'*m*G;
Ar     = Ar + 1e-1*norm(Ar,1)*speye(size(Ar,2));
N      = size(Ar,2); 
B      = Ar*rand(N,4);

levels      = 5;
numCores 	= 8; 
maxIter     = 15;
relativeTol = 1e-2;
relaxType   = "SPAI";
relaxParam  = 1.0;
relaxPre 	= 2;
relaxPost   = 2;
cycleType   ='V';
coarseSolveType = "Julia";

MG = getMGparam(levels,numCores,maxIter,relativeTol,relaxType,relaxParam,relaxPre,relaxPost,cycleType,coarseSolveType);

sSAPCG   = getSA_AMGsolver(MG, "PCG",sym=1,out=1);
X,  = solveLinearSystem(Ar,B,sSAPCG);
@test vecnorm(Ar*X-B)/vecnorm(B) < sSAPCG.tol

clear!(sSAPCG);
sSABiCG   = copySolver(sSAPCG);
sSABiCG.Krylov = "BiCGSTAB"
X,  = solveLinearSystem(Ar,B,sSABiCG);
@test vecnorm(Ar*X-B)/vecnorm(B) < sSABiCG.tol
