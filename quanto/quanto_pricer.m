% quanto_pricer.m Price a European quanto call option via MC methods:

% Inputs:
%  - X0:    Exchange rate spot value.
%  - Sf_0:  Equity spot price (foreign currency).
%  - Kf:    Strike price (foreign currency). 
%  - sigX:  Exchange rate volatility.
%  - sigSf: Foreign equity volatility.
%  - rd:    Domestic Risk-free rate.
%  - rf:    Foreign Risk-free rate.
%  - T:     Option Maturity.
%  - Xbar:  Guaranteed exchange rate.
%  - phi:   N-vector of N(0,1) random numbers.
%  - N:     Number of simulations (paths).

% Outputs:
%  Option price.

function price = quanto_pricer(X0, Sf_0,  Kf, sigX, sigSf, rd, rf, T, Xbar, phi, N) 
    Values = NaN(N,1);
    for n = 1:N
        ST_f  = Sf_0 * exp((rf-sigX*sigSf-0.5*sigSf^2)*T + sigSf*phi(n,1));
        Values(n,1) = Xbar*exp(-rd*T)*max(ST_f-Kf,0);
    end
    price = mean(Values);
end