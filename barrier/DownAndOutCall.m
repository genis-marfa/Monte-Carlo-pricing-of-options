function price = DownAndOutCall(vol, spot, B, K, T, r, N, M)
    dt      = T/M;      % Time increment.
    Value   = NaN(N,1);
    St      = NaN(N,M);
    St(:,1) = spot; 
    
    for n = 1:N
        t = NaN(M,1);
        t(1,1) = 0;

        for m  = 2:M
            t(m,1)  = m*dt;
            St(n,m) = St(n,m-1) * exp((r-0.5*vol^2)*dt + sqrt(dt)*vol*phi(n,m));

            % If stock falls below barrier, set option value to zero and break.
            if St(n,m) <= B
                Value(n,1) = 0;
                break
            end
        end

        % If option hit barrier (m < M) move to next iteration:
        if m < M
            continue
        else
            Value(n,1) = max(St(n,M)-K,0);
        end
    end
    price = exp(-r*T)*mean(Value);

end
