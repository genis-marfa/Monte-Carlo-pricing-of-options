% OilVolatility.m calculates the historical volatility of oil prices.

% Inputs:
% - filename: File name of data file (from EIA).

% Outputs:
% - vol:  Calculated historical volatility (annulaised).
% - spot: Underlying spot price (most recent quoted price in data).
% - Price time series + Log returns plots. 

function [vol spot] = OilVolatility(filename)
    warning('off')
    file = strcat(filename,".xls");
    T = readtable(file, 'Sheet', 'Data 1');
    head(T);
    
    disp("Succesfully loaded oil historical data.")
    disp("Calculating historical volatilities...")
    
    Dates         = T.Date;
    Prices        = T.SpotPrices;
    
    % Search for and delete NaNs
    [row]         = find(isnan(Prices));
    Dates(row)    = [];
    Prices(row)   = [];
    
    % Historical volatility calculations
    LogRet        = diff(log(Prices));
    DailyVol      = std(LogRet);
    fprintf('Daily volatility: %.2f percent.\n', DailyVol*100);
    
    AnnualVol     = DailyVol*sqrt(252);
    fprintf('Anualised volatility: %.2f percent.\n', AnnualVol*100);
    
    vol           = AnnualVol;
    spot          = Prices(end);
    
    figure(1)
    subplot(1,2,1)
    plot(Dates, Prices, 'k-', 'LineWidth', 1.5) 
    sgtitle("Daily spot prices for Brent Crude (USD per Barrel)",...
        'FontSize', 20, 'Color', 'b', 'FontWeight', 'bold');
    ylabel('Spot price'); grid('on'); xlabel('Date');
    set(gcf,'color','w'); set(gca, 'FontSize', 14);
    
    subplot(1,2,2)
    plot(Dates(2:end), 100*LogRet, 'k-', 'LineWidth', 1.5) 
    xlabel('Date'); ylabel('LogRet (%)'); grid('on');
    set(gcf,'color','w'); set(gca, 'FontSize', 14);
    
    disp(" ")
    
    warning('on')
    
end
