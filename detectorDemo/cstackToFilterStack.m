function filterStack = cstackToFilterStack(params, netconfig, centroids, P, M, svmInputDim)

filterStack = cell(1, 2+length(netconfig.layersizes));

filters = reshape(centroids',8,8,1,[]);
filterStack{1} = struct('filters', filters, 'poolDim', 5, 'poolStride', 5, ...
			'bias', zeros(size(centroids,1),1), 'whiten', 1, 'P', P, 'M', M);

svmParams = params(1:(netconfig.xsize+1)*(netconfig.ysize));
convParams = params(1+(netconfig.xsize+1)*(netconfig.ysize):end);

stack = params2cstack(convParams, netconfig);
for i=1:length(stack)
  filters = reshape(stack{i}.w',stack{i}.fx,stack{i}.fy,stack{i}.fch,[]);
  filterStack{i+1} = struct('filters', filters, 'poolDim', stack{i}.px, 'poolStride', ...
			    stack{i}.ps, 'bias', stack{i}.b);
end

K = netconfig.ysize;
N = prod(svmInputDim);

theta = reshape(svmParams(1:N*K), K, N);
bias = reshape(svmParams(1+N*K:end), K, 1);

filters = reshape(theta', [svmInputDim, K]);
filterStack{end} = struct('filters', filters, 'poolDim', 1, 'poolStride', 1, 'bias', bias);
