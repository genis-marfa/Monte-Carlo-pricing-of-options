% Halton.m generates low-discrepancy Halton sequence
% Inputs:
    % N  = Number of simulations per time instant
    % Q  = Number of steps (dimensions) between current time and maturity       
% Output:
    % N*Q matrix of N(0,1) numbers from Halton sequence.

function RandNums = GenerateHalton(N, Q)
   % Generate set of Halton numbers.
   HaltonSet = haltonset(2,'Skip',1e3,'Leap',1e2);
   % Extract the first N/2*Q elements and store in two vectors.
   U0        = net(HaltonSet,N/2*Q);
   U1        = U0(:,1); U2 = U0(:,2);

    % Box Muller Method:  takes any uniformly distributed variables and turns
    %    them into normally distributed ones.
    y1 = cos(2*pi.*U2).*sqrt(-2*log(U1));
    y2 = sin(2*pi.*U1).*sqrt(-2*log(U2));
    rng = [y1; y2];
    
    % Return N*Q matrix.
    RandNums = reshape(rng,N,Q);
   
end


