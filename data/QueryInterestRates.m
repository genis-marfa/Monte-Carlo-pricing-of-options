% QueryInterestRates.m query IMF data to look for most recently quoted 
% risk-free rates of two specified countries.

% Inputs:
% - filename: File name of data file (from IMF).
% - domestic: Domestic country name (e.g. United Kingdom).
% - foreign:  Foreign country name (e.g. United States). 

% Outputs:
% - rd: Domestic rate.
% - rf: Foreign rate.

function [rd, rf] = QueryInterestRates(filename, domestic, foreign)
    warning('off')
    file = strcat(filename,".xlsx");    
    T    = readtable(file);
    
    % Look for row of rates for domestic and foreign countries:
    domesticRates = T(T.Country == domestic,:);
    foreignRates  = T(T.Country == foreign,:);
    
    l = width(domesticRates);
    LastDomesticRate = 0;
    LastForeignRate  = 0;
    
    % Iterate over row of rates, store the last quoted rate (Unless it is 
    % not quoted or NaN). 
    for i = 4:l
        if (isnumeric(domesticRates{1,i}) & isnan(domesticRates{1,i}) == 0)
            LastDomesticRate = domesticRates{1,i};
        end
        if (isnumeric(foreignRates{1,i}) & isnan(foreignRates{1,i}) == 0)
            LastForeignRate = foreignRates{1,i};
        end
    end
    rd = LastDomesticRate/100;
    rf = LastForeignRate/100;
    warning('on')
end
