% DownAndOutCall2.m Price a down-and-out call option via Brownian bridge MC
% methods:

% Inputs:
%  - spot: Underlying spot price.
%  - vol:  Underlying volatility.
%  - r:    Risk-free rate
%  - K:    Option strike price. 
%  - B:    Barrier level.
%  - T:    Option maturity.
%  - N:    Number of simulations (paths).
%  - phi:  N-vector of N(0,1) random numbers.

% Outputs:
%  Option price.

function price = DownAndOutCall2(N, spot, vol, K, B, T, r, phi)
    C = 0;  
    for n = 1:N
        ST = spot * exp((r-0.5*vol^2)*T + sqrt(T)*vol*phi(n,1));
        
        % Brownian bridge probability p:
        if B < ST
            p = 1 - exp(-2*log(B/spot)*log(B/ST)/(vol^2*T));
        else 
            p = 0;
        end
        C  = C + p*max(ST-K,0);
    end
    price = C*exp(-r*T)/N;
end
