%% FM443 Individual Project.
%   Monte Carlo pricing of path dependent and currency options.
%   Candidate No: 15200
%   London School of Economics.
%   MT 2020-21. 
%% Set up directories to folders:
Dir           = cd;
DataDir       = strcat(Dir, '/data');
BarrierDir    = strcat(Dir, '/barrier');
AsianDir      = strcat(Dir, '/asian');
DomStrikeDir  = strcat(Dir, '/domestic_strike');
QuantoDir     = strcat(Dir, '/quanto');
%% Barrier Option:
cd(DataDir) % Change working directory to data folder
% Option Parameters:
[vol spot] = OilVolatility("oilprices");
B          = 52;     % Barrier level.
K          = 58;     % Strike.
T          = 0.25;   % Maturity = 3 month.
r          = QueryInterestRates("Interest_Rates", "United States", "United Kingdom");

% Analytic Solution:
Settle   = '01-Jan-2021';
Maturity = '01-Apr-2021';    % Aritrary 3 month period. 
Compounding = -1;            % For continuous compounding.
Basis = 1;                   % Day count basis.

% Define a RateSpec structure.
RateSpec = intenvset('ValuationDate', Settle, 'StartDates', Settle, 'EndDates', ...
Maturity, 'Rates', r, 'Compounding', Compounding, 'Basis', Basis);

% Define a StockSpec structure.
StockSpec = stockspec(vol, spot);

% Down and out call:
V = barrierbybls(RateSpec, StockSpec, 'call', K, Settle, Maturity,  'DO', B)

% Simulation analysis:
cd(BarrierDir)  % Change working directory to barrier folder
analyse_barrier(vol, spot, B, K, T, r, V)
cd(Dir)         % Go back to main directory.

%% Geometric Asian Option:

% Analytic Solution:
sigG       = vol/sqrt(3);
b          = 0.5*(r-0.5*sigG^2);
d1         = (log(spot/K)+(b+0.5*sigG^2)*T)/(sigG*sqrt(T));
d2         = d1-sigG*sqrt(T);

disp('Analytic Solution:')
A = spot*exp((b-r)*T)*normcdf(d1)-K*exp(-r*T)*normcdf(d2)

Q = 50; 

% Simulation analysis:
cd(AsianDir)
analyse_asian(spot, vol, r, T, K, Q, A)
cd(Dir)

%% Quanto Option:

% Market parameters:
cd(DataDir) 
% Domestic and foreign interest rates:
[rd, rf]  = QueryInterestRates("Interest_Rates", "United Kingdom", "United States")
% GBP-USD exchange rate volatility and spot price: 
[sigX X0] = HistVolatility("GBPUSD",3); 

% Foreign stock parameters:
[sig_Sf Sf_0] = HistVolatility("TSLA",4); 

% Option parameters:
Xbar   = 1.38; % Pre-specified exchange rate.
Kf     = 850;  % Strike price in foreign currency.
T      = 1;    % Maturity.

% Analytic Solution
d1 = 1/(sig_Sf*sqrt(T))*( log(Sf_0/Kf) + (rf-sig_Sf*sigX + 0.5*sig_Sf^2)*T );
d2 = 1/(sig_Sf*sqrt(T))*( log(Sf_0/Kf) + (rf-sig_Sf*sigX - 0.5*sig_Sf^2)*T );
V  = exp((rf-rd-sig_Sf*sigX)*T)*Xbar*Sf_0*normcdf(d1)-exp(-rd*T)*Xbar*Kf*normcdf(d2)

% Simulation analysis:
cd(QuantoDir)
analyse_quanto(X0, Sf_0,  Kf, sigX, sig_Sf, rd, rf, T, Xbar, V)
cd(Dir)
%% Foreign Equity call struck on domestic currency:

Kd  = Kf*X0;
sig = sqrt(sigX^2+sig_Sf^2); 

% Analytic Solution
d1 = 1/(sig*sqrt(T))*( log(Sf_0*X0/Kd) + (rd+0.5*sig^2)*T );
d2 = 1/(sig*sqrt(T))*( log(Sf_0*X0/Kd) + (rd-0.5*sig^2)*T );
V  = X0*Sf_0*normcdf(d1)-exp(-rd*T)*Kd*normcdf(d2)

% Simulation analysis:
cd(DomStrikeDir)
analyse_domstrike(X0, Sf_0,  Kd, sig, rd, rf, T, V);
cd(Dir)