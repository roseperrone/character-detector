function g = meanpoolg(x, y)

    global usegpu gpusingletype;

    % special handling
    if strcmp(usegpu, 'gpumat')
        g = (1/size(x, 1)) * ones(size(x), GPUsingle);
        return;
    end
    
    % generic handling
    g = (1/size(x, 1)) * ones(size(x));

    if strcmp(usegpu, 'gpumat')
        g = gpusingletype(g);
    elseif strcmp(usegpu, 'jacket')
        g = gsingle(g);
    end

end