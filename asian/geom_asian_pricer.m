% geom_asian_pricer.m Price a geometrically averaged Asian option via MC methods:

% Inputs:
%  - spot: Underlying spot price.
%  - vol:  Underlying volatility.
%  - r:    Risk-free rate
%  - K:    Option strike price. 
%  - T:    Option maturity.
%  - N:    Number of simulations (paths).
%  - Q:    Number of times stock path is realised.
%  - phi:  N*Q matrix of N(0,1) random numbers.

% Outputs:
%  Option price.

function price = geom_asian_pricer(spot, vol, r, T, K, N, Q, phi)
    % N is the no. of simulations, Q the discretisation frequency.
    dt      = T/Q;       % Time increment.
    Value   = NaN(N,1);
    
    for n = 1:N
        St      = NaN(Q,1);  % Stock path.
        St(1,1) = spot; 
    
        for q  = 2:Q 
            St(q,1) = St(q-1,1) * exp((r-0.5*vol^2)*dt + sqrt(dt)*vol*phi(n,q));
        end
    
        geom_av = mean(log(St));
        Value(n,1) = max(exp(geom_av)-K,0);
    end
    price = exp(-r*T)*mean(Value);
end

