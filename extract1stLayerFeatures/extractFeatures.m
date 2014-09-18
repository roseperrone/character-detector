function feature_pool = extractFeatures(D,data,  m, inputsize)	
    [ nBases sz2 ] = size(D);
    szBase = floor(sqrt( sz2 ));
    szImg = floor(sqrt( inputsize ));
    nTiles = (szImg-szBase+1)^2; %sliding tiles
    imgIndex = 1;
    batchSize = 2000;
    lastImgIndex = min(m,imgIndex + batchSize-1);
    feature_pool = zeros(m,nBases);

    % 1. Forward Prop
    for batchIndex = 1:batchSize*nTiles:m*nTiles
        lastIndex=min(batchIndex+batchSize*nTiles-1, m*nTiles);
        features = triangleRect(D*data(batchIndex:lastIndex,:)')';     
        for j = 0:lastImgIndex-imgIndex
            feature_block = features(nTiles*j+1:nTiles*(j+1), :);
            
            % average pooling
            feature_pool(imgIndex+j,:) = sum(feature_block,1);        
        end
        imgIndex = imgIndex + batchSize;
        lastImgIndex = min(m,imgIndex + batchSize -1);
        disp('----')
    end
end

