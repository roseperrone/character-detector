function D = run_projection_kmeans(X, k, iterations)
% Run dot-product variant of kmeans.
% Usage: D = run_projection_kmeans(X, k, iterations)
% X is a set of training patches, where each row is a patch
% k is the number of filters to train
% iterations is the number of iters to run kmeans.
% D is the set of trained filters. each row is a filter.

  % randomly initialize centroids
  D = randn(k,size(X,2));
  BATCH_SIZE=1000;
  %normalize all centroids 
  D = bsxfun(@rdivide, D, sqrt(sum(D.*D , 2)));
  for itr = 1:iterations
    fprintf('K-means iteration %d / %d\n', itr, iterations);

    summation = zeros(k, size(X,2));
    counts = zeros(k, 1); 
    for i=1:BATCH_SIZE:size(X,1)
      lastIndex=min(i+BATCH_SIZE-1, size(X,1));
      m = lastIndex - i + 1;
      projection = D*X(i:lastIndex,:)';
      [val,labels] = max(abs(projection));
      S = projection.*(sparse(1:m,labels,1,m,k,m))';
      summation = summation + S*X(i:lastIndex,:);
      counts = counts + sum(S,2);
    end
    
    %normalize all centroids 

    D = bsxfun(@rdivide, summation, sqrt(sum(summation.*summation , 2)));
    % just zap empty D so they don't introduce NaNs everywhere.
    badIndex = find(counts == 0);
    D(badIndex, :) = 0;
  end
