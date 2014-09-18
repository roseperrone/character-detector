function responses = fullImageForwardPropHelper(img, filterStack, usegpu)
if usegpu
  addpath('/afs/cs.stanford.edu/package/jacket/2.0-20111221/jacket/engine');
end

img = double(img);
responses = img;
poolStride = 1;

for i=1:length(filterStack)
  [H, W, D] = size(responses);

  filters = filterStack{i}.filters;
  assert(size(filters, 3) == D, 'Filter channels must match image channels!');

  filterDim = size(filters, 1);
  poolDim = filterStack{i}.poolDim;

  nFilters = size(filters, 4);

  filterKernelDim = (filterDim-1)*poolStride+1;
  poolKernelDim = (poolDim-1)*poolStride+1;
  newResponses = zeros(H-filterKernelDim-poolKernelDim+2, W-filterKernelDim-poolKernelDim+2, nFilters);

  poolRegion = zeros(poolStride);
  poolRegion(1,1) = 1;

  if usegpu
    responses = gdouble(responses);
    newResponses = gdouble(newResponses);
    poolRegion = gdouble(poolRegion);
    filters = gdouble(filters);
  end
  
  if i==1 && isfield(filterStack{i}, 'whiten') && filterStack{i}.whiten
    whiten = 1;
    avgFilter = ones(filterDim)/(filterDim*filterDim);

    meanPatch = filter2(avgFilter, responses, 'valid');
    stdPatch = sqrt(filter2(avgFilter, responses.^2, 'valid')-meanPatch.^2+10);

    if usegpu
      filterStack{i}.P = gdouble(filterStack{i}.P);
      filterStack{i}.M = gdouble(filterStack{i}.M);
    end
  else 
    whiten = 0;
  end

  for j=1:nFilters
    response = zeros(H-filterKernelDim+1, W-filterKernelDim+1);
    if usegpu
      response = gdouble(response);
    end

    % Convolve along each channel
    for k=1:D
      filter = filters(:,:,k,j);
      if i==1 && whiten
        filterCol = filter(:)'*filterStack{i}.P;
      	filter = reshape(filterCol, filterDim, filterDim);
      end

      filter = kron(filter, poolRegion);
      filter = filter(1:end-poolStride+1, 1:end-poolStride+1);

      if i==1 && whiten
        convResponse = (filter2(filter, responses(:,:,k), 'valid')-sum(filterCol)*meanPatch) ./ ...
            stdPatch-filterCol*filterStack{i}.M';
      else
        convResponse = filter2(filter, responses(:,:,k), 'valid');
      end
      response = response + convResponse;
    end

    % Add a bias
    response = response + filterStack{i}.bias(j);

    % Apply activation to all except output layer
    if i < length(filterStack)
      response = triangleRect(response);
    end

    % Average pooling
    poolFilt = kron(ones(poolDim)/(poolDim*poolDim), poolRegion);
    poolFilt = poolFilt(1:end-poolStride+1, 1:end-poolStride+1);
    newResponses(:,:,j) = filter2(poolFilt, response, 'valid');
  end

  responses = newResponses;

  poolStride = poolStride*filterStack{i}.poolStride;
end

responses = double(responses);
