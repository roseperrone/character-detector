function responses = fullImageForwardProp(img, filterStack, usegpu, batchDim, winSize)

% filterStack params per layer:
%   filters
%   poolDim
%   poolStride
%   bias
%   (optional) whiten, P, M - will normalize and whiten

if ~exist('usegpu')
  usegpu = 0;
end

if ~exist('batchDim')
  batchDim = 500;
end

if ~exist('winSize')
  winSize = 32;
end

dim = size(img);
responses = zeros(dim(1)-winSize+1, dim(2)-winSize+1, length(filterStack{3}.bias));

for i=1:batchDim-winSize+1:size(responses,1)
  for j=1:batchDim-winSize+1:size(responses,2)
    iEnd = min(i+batchDim-1, dim(1));
    jEnd = min(j+batchDim-1, dim(2));

    responses(i:iEnd-winSize+1, j:jEnd-winSize+1,:) = ...
	fullImageForwardPropHelper(img(i:iEnd,j:jEnd), filterStack, usegpu);
  end
end
