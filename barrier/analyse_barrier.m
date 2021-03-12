% analyse_barrier.m computes the 95% CL intervals for the pricing of a European
% down-and-out barrier call option through three Monte Carlo samples:
%  1) Crude Monte Carlo (No VRTs)
%  2) Antithetic Variates + Moment Matching Monte Carlo
%  3) Quasi Monte Carlo. 

% Inputs:
%  - spot: Underlying spot price.
%  - vol:  Underlying volatility.
%  - B:    Barrier Level
%  - r:    Risk-free rate
%  - T:    Option Maturity.
%  - K:    Option strike price. 
%  - V:    Analytic solution of the option. 

% Outputs:
%  Option prices for the 3 different samples.
%  95% CL plots + Variance reduction plots + Elapsed time plots. 

function option_prices = analyse_barrier(vol, spot, B, K, T, r, V)
    M    = 100;
    N    = [100, 250, 500, 750, 1000, 2500, 5000, 7500 10000 25000 50000 75000 100000];
    lenN = length(N);
    
    % ------------------------------------------------------------------------ %
                                % Crude Monte Carlo:
    % ------------------------------------------------------------------------ %
    values_crude = NaN(M,lenN);
    times_crude  = NaN(M,lenN);

    for n = 1:lenN
        No_paths = N(n);

        for m = 1:M
            phi_crude         = randn(No_paths,1);
            tic;
            values_crude(m,n)   = DownAndOutCall2(No_paths, spot, vol, K, B, T, r, phi_crude);
            times_crude(m,n)    = toc;
        end
    end

    % Calculate variances, run times and 95% CL:
    mean_values_crude    = mean(values_crude);
    variances_crude      = var(values_crude);
    run_times_crude      = mean(times_crude);
    upperCL_crude   = mean_values_crude + 2.*sqrt(variances_crude);
    lowerCL_crude   = mean_values_crude - 2.*sqrt(variances_crude);

    % ------------------------------------------------------------------------ % 
    %               Antithetic variables + Moment Matching:
    % ------------------------------------------------------------------------ % 
    values_anti = NaN(M,lenN);
    times_anti  = NaN(M,lenN);

    for n = 1:lenN
        No_paths = N(n);

        for m = 1:M
            phi_anti   = randn(No_paths/2,1);
            phi_anti   = [phi_anti; -phi_anti];
            phi_anti   = 1/std(phi_anti).*phi_anti;

            tic;
            values_anti(m,n)   = DownAndOutCall2(No_paths, spot, vol, K, B, T, r, phi_anti);
            times_anti(m,n)    = toc;
        end
    end    
    % Calculate variances, run times and 95% CL:
    mean_values_anti    = mean(values_anti);
    variances_anti      = var(values_anti);
    run_times_anti      = mean(times_anti);
    upperCL_anti        = mean_values_anti + 2.*sqrt(variances_anti);
    lowerCL_anti        = mean_values_anti - 2.*sqrt(variances_anti);

    % ------------------------------------------------------------------------ % 
    %                       Quasi Monte Carlo:
    % ------------------------------------------------------------------------ % 
    values_quasi = NaN(M,lenN);
    times_quasi  = NaN(lenN,1);

    for n = 1:lenN
        No_paths = N(n);
        tic;
        phi_quasi    = Halton(No_paths,M);

        for m = 1:M
            phi = phi_quasi(:,m);
            values_quasi(m,n)   = DownAndOutCall2(No_paths, spot, vol, K, B, T, r, phi);
        end
        times_quasi(n,1) = toc/M;
    end

    mean_values_quasi    = mean(values_quasi);
    variances_quasi      = var(values_quasi);
    run_times_quasi      = times_quasi;
    upperCL_quasi        = mean_values_quasi + 2.*sqrt(variances_quasi);
    lowerCL_quasi        = mean_values_quasi - 2.*sqrt(variances_quasi);

    % Plot:
    figure(3)
    sgtitle('European down-and-out barrier call option', 'FontSize', ...
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
    loglog(N, variances_crude, 'k-', 'LineWidth', 1.5)
    hold on
    loglog(N, variances_anti, 'b-', 'LineWidth', 1.5)
    hold on
    loglog(N, variances_quasi, 'g-', 'LineWidth', 1.5)
    grid('on'); set(gcf,'color','w'); set(gca, 'FontSize', 14);
    legend('Crude Monte Carlo', 'Antithetic + MM', 'Quasi MC')
    xlabel('No. of paths'); ylabel('Variance'); 
    title('Variance vs No. of paths')  
    
    option_prices = [mean_values_crude(end), mean_values_anti(end),...
                     mean_values_quasi(end)];
    
end