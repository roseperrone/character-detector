function [params, netconfig] = svmConvSetup(cstack, imwidth, imheight, imchannels, numlabels)

    netconfig = cstack2netconfig(cstack);

    % compute the output size 
    cw = imwidth; ch = imheight;
    for d = 1:numel(cstack)
        cw = cw - cstack{d}.fx + 1;
        ch = ch - cstack{d}.fy + 1;
        cw = ceil((cw - cstack{d}.px) / cstack{d}.ps) + 1;
        ch = ceil((ch - cstack{d}.py) / cstack{d}.ps) + 1;
    end
    
    netconfig.xsize = size(cstack{end}.w,1) * cw * ch;
    netconfig.ysize = numlabels;

    svmW = 0.1 * tanhInitRand(netconfig.xsize, numlabels);
    svmB = zeros(numlabels, 1);
    
    params = [ svmW(:) ; svmB(:) ; double(cstack2params(cstack)) ];
    
    netconfig.imwidth = imwidth;
    netconfig.imheight = imheight;
    netconfig.imch = imchannels;
    netconfig.type = 'conv';
    
end