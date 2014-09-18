function g = maxpoolg(x, y)

    global usegpu gpusingletype;

    [dummy,idx] = max(single(x)); % single cast since GPUmat does not support
    
    % This version was slightly slower
    % g = full(sparse(idx,1:size(x,2),1,size(x,1),size(x,2)));

    if strcmp(usegpu, 'gpumat')
        g = zeros(size(x), GPUsingle);
    else
        g = zeros(size(x));
        if usegpu
            g = gpusingletype(g);
        end
    end

    onesubs = sub2ind(size(x),idx,1:size(x,2));
    g(onesubs) = 1;
    
end