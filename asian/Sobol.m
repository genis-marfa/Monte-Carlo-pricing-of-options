% Sobol.m generates low-discrepancy Sobol sequence
% Inputs:
    % N  = Number of simulations per time instant
    % Q = Number of steps (dimensions) between current and maturity       
% Output:
    % N*Q matrix of N(0,1) numbers from Sobol sequence.
    
function z_RandMat=Sobol(N,Q)
    % Construct quasi-random number stream
    q = qrandstream('sobol',Q,'Skip',1e3,'Leap',1e2);

    % Generate quasi-random points from stream
    RandMat = qrand(q,N);

    % Generate a N*Q matrix which values are normally inveresed of the Sobol sequence points
    z_RandMat = norminv(RandMat,0,1);
end