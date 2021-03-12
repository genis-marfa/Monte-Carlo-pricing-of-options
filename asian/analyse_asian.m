% analyse_asian.m computes the 95% CL intervals for the pricing of a geometrically
% average Asian call option through three Monte Carlo samples:
%  1) Crude Monte Carlo (No VRTs)
%  2) Antithetic Variates + Moment Matching Monte Carlo
%  3) Quasi Monte Carlo. 

% Inputs:
%  - spot: Underlying spot price.
%  - vol:  Underlying volatility.
%  - r:    Risk-free rate
%  - K:    Option strike price. 
%  - Q:    Number of times stock path is realised.
%  - T:    Option Maturity.
%  - V:    Analytic solution of the option. 

% Outputs:
%  Option prices for the 3 different samples.
%  95% CL plots + Variance reduction plots + Elapsed time plots. 

function option_prices = analyse_asian(spot, vol, r, T, K, Q, V)
    M    = 100;
    N    = [10, 26, 50, 76, 100, 250, 500, 750, 1000, 2500, 5000, 7500 10000];
    lenN = length(N);
    
    h1 = waitbar(0,'Calculating Crude Monte Carlo. Please wait...');
    
    % ------------------------------------------------------------------------ %
                                % Crude Monte Carlo:
    % ------------------------------------------------------------------------ %
    values_crude = NaN(M,lenN);
    times_crude  = NaN(M,lenN);
    
    for n = 1:lenN
        No_paths = N(n);
        for m = 1:M
            phi_crude           = randn(No_paths,Q);
            tic;
            values_crude(m,n)   = geom_asian_pricer(spot, vol, r, T, K, No_paths, Q, phi_crude);
            times_crude(m,n)    = toc;
        end
            waitbar(n/(3*lenN),h1)     
    end

    % Calculate variances, run times and 95% CL:
    mean_values_crude  = mean(values_crude);
    variances_crude    = var(values_crude);
    run_times_crude    = mean(times_crude);
    upperCL_crude      = mean_values_crude + 2.*sqrt(variances_crude);
    lowerCL_crude      = mean_values_crude - 2.*sqrt(variances_crude);
    
    h2 = waitbar(0,'Applying Anithetic vars + MM. Please wait...');

    % ------------------------------------------------------------------------ % 
    %               Antithetic variables + Moment Matching:
    % ------------------------------------------------------------------------ % 
    values_anti = NaN(M,lenN);
    times_anti  = NaN(M,lenN);

    for n = 1:lenN
        No_paths = N(n);

        for m = 1:M
            phi_anti   = randn(No_paths/2,Q);
            phi_anti   = [phi_anti; -phi_anti];
            phi_anti   = 1./std(phi_anti).*phi_anti;

            tic;
            values_anti(m,n)   = geom_asian_pricer(spot, vol, r, T, K, No_paths, Q, phi_anti);
            times_anti(m,n)    = toc;
        end
        waitbar((lenN+n)/(lenN*3),h2)     
    end    
    
    % Calculate variances, run times and 95% CL:
    mean_values_anti    = mean(values_anti);
    variances_anti      = var(values_anti);
    run_times_anti      = mean(times_anti);
    upperCL_anti        = mean_values_anti + 2.*sqrt(variances_anti);
    lowerCL_anti        = mean_values_anti - 2.*sqrt(variances_anti);
    
    h3 = waitbar(0,'Applying Quasi MC methods. Please wait...');
    
    % ------------------------------------------------------------------------ % 
    %                       Quasi Monte Carlo:
    % ------------------------------------------------------------------------ % 
    values_quasi = NaN(M,lenN);
    times_quasi  = NaN(lenN,1);

    for n = 1:lenN
        tic;
        No_paths  = N(n);
        phi_large = Sobol(No_paths*M,Q);

        for m = 1:M
            % Create submatrix from larger matrix
            start_  = No_paths*(m-1)+1;
            end_    = No_paths*m;
            phi_sub = phi_large(start_:end_,:);
            
            values_quasi(m,n)   = geom_asian_pricer(spot, vol, r, T, K, No_paths, Q, phi_sub);
        end
        waitbar((2*lenN+n)/(lenN*3),h3)    
        times_quasi(n,1) = toc/M;
    end   
    mean_values_quasi    = mean(values_quasi);
    variances_quasi      = var(values_quasi);
    run_times_quasi      = times_quasi;
    upperCL_quasi        = mean_values_quasi + 2.*sqrt(variances_quasi);
    lowerCL_quasi        = mean_values_quasi - 2.*sqrt(variances_quasi);
    
    close([h1 h2 h3]); 
    
    % ------------------------------------------------------------------------ % 
    %                                Plot:
    % ------------------------------------------------------------------------ % 
    sgtitle('Geometric Asian option', 'FontSize', ...
            18, 'Color', 'b', 'FontWeight', 'bold');
    subplot(2,2,[1 3])
    semilogx(N,upperCL_crude, ':k', 'LineWidth', 2.5)
    hold on
    semilogx(N,upperCL_anti, ':b', 'LineWidth', 2.5)
    hold on
    semilogx(N,upperCL_quasi, ':g', 'LineWidth', 2.5)
    hold on
    yline(V, 'r', 'LineWidth', 1.75)
    hold on
    semilogx(N,lowerCL_crude, ':k', 'LineWidth', 2.5)
    hold on
    semilogx(N,lowerCL_anti, ':b', 'LineWidth', 2.5)
    hold on
    semilogx(N,lowerCL_quasi, ':g', 'LineWidth', 2.5)

    xlabel('No. of paths'); ylabel('95% Confidence Levels'); grid('on');
    set(gcf,'color','w'); set(gca, 'FontSize', 14);
    legend('Crude Monte Carlo', 'Antithetic + MM', 'Quasi MC', 'Analytic solution')
    title('95% Confidence levels')  
    
    subplot(2,2,2)
    semilogx(N, run_times_crude, 'k-', 'LineWidth', 1.5)
    hold on
    semilogx(N, run_times_anti, 'b-', 'LineWidth', 1.5)
    hold on
    semilogx(N, run_times_quasi, 'g-', 'LineWidth', 1.5)
    grid('on'); set(gcf,'color','w'); set(gca, 'FontSize', 14);
    legend('Crude Monte Carlo', 'Antithetic + MM', 'Quasi MC')
    ylabel('Average run time(s)'); xlabel('No. of paths');
    title('Run time vs No. of paths')

    subplot(2,2,4)
    semilogx(N, variances_crude, 'k-', 'LineWidth', 1.5)
    hold on
    semilogx(N, variances_anti, 'b-', 'LineWidth', 1.5)
    hold on
    semilogx(N, variances_quasi, 'g-', 'LineWidth', 1.5)
    grid('on'); set(gcf,'color','w'); set(gca, 'FontSize', 14);
    legend('Crude Monte Carlo', 'Antithetic + MM', 'Quasi MC')
    xlabel('No. of paths'); ylabel('Variance'); 
    title('Variance vs No. of paths')  
    
    option_prices = [mean_values_crude(end), mean_values_anti(end),...
                     mean_values_quasi(end)];
end