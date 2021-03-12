% dom_strike_pricer.m Price a European call option on a foreign equity struck 
% on domestic currency, via MC methods:

% Inputs:
%  - X0:   Exchange rate spot value.
%  - Sf_0: Equity spot price (foreign currency).
%  - Kd:   Strike price (domestic currency). 
%  - sig:  sqrt((Exchange rate Volatility)^2+(Foreign Equity Volatility)^2); 
%  - rd:   Domestic Risk-free rate.
%  - rf:   Foreign Risk-free rate.
%  - T:    Option Maturity.
%  - phi:  N-vector of N(0,1) random numbers.
%  - N:    Number of simulations (paths).

% Outputs:
%  Option price.

function price = quanto_pricer(X0, Sf_0,  Kd, sig, rd, rf, T, phi, N)     
    Values = NaN(N,1);
    for n = 1:N
        XT_ST_f  = X0*Sf_0 * exp( (rd-0.5*sig^2)*T+sig*sqrt(T)*phi(n,1));
        Values(n,1) = exp(-rd*T)*max(XT_ST_f-Kd, 0);
    end
    price = mean(Values);
end