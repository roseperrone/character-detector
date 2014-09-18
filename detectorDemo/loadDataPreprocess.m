function [trainX, trainY, testX, testY] = loadDataPreprocess(trainDataFile, cvDataFile, centroids, P, M)

load(trainDataFile);
trainData = double(e.img);
trainY = e.class;

load(cvDataFile);
testData = double(e.img);
testY = e.class;

filters = struct('w', centroids, 'fx', 8, 'fy', 8, 'fs', 1, 'fch', 1, 'P', P, 'M', M, ...
		 'px', 5, 'py', 5, 'ps', 5, 'poolfunc', @meanpool);

trainResponses = firstLayerFeatures(trainData, filters, 1000);
testResponses = firstLayerFeatures(testData, filters, 1000);

nFilters = size(centroids, 1);

N = size(trainResponses, 2);
trainX = zeros(5, 5, nFilters, N);
for i=1:N
  trainX(:,:,:,i) = reshape(trainResponses(:,i), 5, 5, nFilters);
end

N = size(testResponses, 2);
testX = zeros(5, 5, nFilters, N);
for i=1:N
  testX(:,:,:,i) = reshape(testResponses(:,i), 5, 5, nFilters);
end
