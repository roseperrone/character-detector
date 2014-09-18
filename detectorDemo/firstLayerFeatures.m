function responses = firstLayerFeatures(X, filters, batchSize, nPools)

if ~exist('batchSize')
  batchSize = 500;
end

if ~exist('nPools')
  nPools = 25;
end

N = size(X, 3);
nBatches = ceil(N / batchSize);

responses = zeros(nPools*size(filters.w, 1), N);
for i=1:nBatches
  t = tic;
  if batchSize*i > N
    batch = batchSize*(i-1)+1:N;
  else
    batch = batchSize*(i-1)+1:batchSize*i;
  end

  responses(:, batch) = firstLayerFeaturesHelper(X(:,:,batch), filters);
  fprintf('Batch %d/%d finished in %.4f s\n', i, nBatches, toc(t));
end
