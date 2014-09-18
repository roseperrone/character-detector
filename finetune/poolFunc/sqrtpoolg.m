function g = sqrtpoolg(x, y)

    if ~exist('y', 'var') || isempty(y)
        y = sqrtpool(x);
    end
    
    g = (1/size(x, 1)) * ones(size(x));
    
    global usegpu gpusingletype;
    if usegpu
        g = gpusingletype(g);
    end
    g = bsxfunwrap(@times, g, 0.5 * 1./y);

end
