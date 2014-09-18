function [patches M P] = normalizeAndZCA(patches,M,P)
	% normalize for contrast
	patches = bsxfun(@rdivide, bsxfun(@minus, patches, mean(patches,2)), sqrt(var(patches,[],2)+10));
	if(~exist('P') || ~exist('M'))
		% whiten
		disp('whitening');
		C = cov(patches);
		M = mean(patches);
		[V,D] = eig(C);
		P = V * diag(sqrt(1./(diag(D) + 0.1))) * V';
	end
	patches = bsxfun(@minus, patches, M) * P;
end
