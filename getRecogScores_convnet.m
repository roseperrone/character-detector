% Code written by Tao Wang (http://cs.stanford.edu/people/twangcat/)

function scores =  getRecogScores_convnet(img, D1, M1, P1, mu,sig, params, netconfig)
% compute sliding window classifier scores on a cropped line segment using 
% the character classifier model provided.

    height0 = 32;
    if size(img,3)>1
    img = rgb2gray(img);
    end
    img0 = imresize(img, [height0, NaN]);
    img0 = [uint8(ones(height0,15)*mean(img0(:,1))), img0, uint8(ones(height0,16)*mean(img0(:,end)))]; % pad both sides by half window size
    width0 = size(img0, 2);
    fs1 = 8; % first layer filter size
    depth1 = size(D1,1);
    win_total = width0-height0+1;
    %first layer feed-forward
    height1 = height0-fs1+1;
    width1 = width0-fs1+1;
    X1 = double(im2col(img0, [fs1, fs1], 'sliding')');
    [X1 M1 P1] = normalizeAndZCA(X1,M1,P1);
    X1 = triangleRect(D1*X1');
    X1 = reshape(X1, [depth1, height1, width1]);
    X1 = permute(X1, [2,3,1]); % fisrt layer feature maps before pooling
    %pool 1st layer
    X1_pooled = zeros(win_total, 25*depth1);
    for w = 1: win_total
        w_start = w;
        w_end = w-1+25;
        win1 = X1(:, w_start:w_end,:); % current window on 1st layer feature map
        temp = cat(1, sum(win1(1:5,:,:),1), sum(win1(6:10,:,:),1), sum(win1(11:15,:,:),1), sum(win1(16:20,:,:),1), sum(win1(21:25,:,:),1));
        win2 = cat(2, sum(temp(:,1:5,:),2), sum(temp(:,6:10,:),2), sum(temp(:,11:15,:),2), sum(temp(:,16:20,:),2), sum(temp(:,21:25,:),2));
        win2 = permute(win2, [3,2,1]);
        X1_pooled(w,:) = win2(:)';
    end
    
fprintf('sphereing data\n'); % subtract mean and divide by std (of the training data)
X1_pooled = bsxfun(@rdivide, bsxfun(@minus, X1_pooled, mu), sig)';
imh = 5; imw = 5; [imd_full imm]=size(X1_pooled);
imd = imd_full/(imh*imw);
data = reshape(X1_pooled, [imd, imw, imh, imm]); 
data = permute(data, [3,2,1,4]); % 4 dims are ordered as: height, width, depth, sliding-window num
scores = svmConvPredict(params, netconfig, data, 1000);
    
end
    
