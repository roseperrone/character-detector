function responses = firstLayerFeaturesHelper(X, filters)

[H,W,N] = size(X);
X = reshape(X, H*W, N);
X2 = X.^2;

avgFilter = filters;
avgFilter.w = repmat(ones(1, filters.fy*filters.fx) / (filters.fx*filters.fy), [16, 1]);

nFilters = size(filters.w, 1);

filters.w = filters.w * filters.P;

meanX = fconv(X, avgFilter, H, W, 1);
meanX2 = fconv(X2, avgFilter, H, W, 1);
[filtX, cw, ch, cch] = fconv(X, filters, H, W, 1);

meanX = repmat(double(meanX), [nFilters/16, 1]);
meanX2 = repmat(double(meanX2), [nFilters/16, 1]);
filtX = double(filtX);

stdX = sqrt(meanX2 - meanX.^2 + 10);
dim = (H-filters.fy+1) * (W-filters.fx+1);

filtMean = zeros(dim*nFilters, 1);
whitening = zeros(dim*nFilters, 1);
for i=1:nFilters
  filter = double(filters.w(i,:));
  filtMean((i-1)*dim+1:i*dim) = sum(filter);
  whitening((i-1)*dim+1:i*dim) = filter*filters.M';
end

rawValues = bsxfun(@minus, (filtX-bsxfun(@times, meanX, filtMean)) ./ stdX, whitening);
activated = triangleRect(rawValues);

responses = double(fpool(activated, filters, cw, ch, cch));
