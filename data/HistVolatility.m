% HistVolatility.m calculates the historical volatility of an underlying.

% Inputs:
% - filename: File name of data file (from Yahoo finance).
% - fig_no:   Figure Number.

% Outputs:
% - vol:  Calculated historical volatility (annulaised).
% - spot: Underlying spot price (most recent quoted price in data).
% - Price time series + Log returns plots. 

function [vol spot] = HistVolatility(filename, fig_no)
    warning('off')
    file = strcat(filename,".csv");
    T = readtable(file);
    head(T);
    
    disp("Succesfully loaded exchange rate data.")
    disp("Calculating historical volatilities...")
    
    Dates         = T.Date;
    Prices        = T.AdjClose;
    
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
    
    figure(fig_no)
    subplot(2,1,1)
    plot(Dates, Prices, 'k-', 'LineWidth', 1.5) 
    sgtitle(filename,...
        'FontSize', 16, 'Color', 'b', 'FontWeight', 'bold');
    ylabel('Underlying Value'); grid('on');
    set(gcf,'color','w'); set(gca, 'FontSize', 14);
    
    subplot(2,1,2)
    plot(Dates(2:end), 100*LogRet, 'k-', 'LineWidth', 1.5) 
    xlabel('Date'); ylabel('LogRet (%)'); grid('on');
    set(gcf,'color','w'); set(gca, 'FontSize', 14);
    
    disp(" ")
    warning('on')
    
end
