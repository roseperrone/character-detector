%Copyright (c) 2012, Stanford University
%All rights reserved.
%
%Redistribution and use in source and binary forms, with or without
%modification, are permitted provided that the following conditions are met:
%    * Redistributions of source code must retain the above copyright
%      notice, this list of conditions and the following disclaimer.
%    * Redistributions in binary form must reproduce the above copyright
%      notice, this list of conditions and the following disclaimer in the
%      documentation and/or other materials provided with the distribution.
%    * Neither the name of the <organization> nor the
%      names of its contributors may be used to endorse or promote products
%      derived from this software without specific prior written permission.
%
%THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
%ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
%WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
%DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
%DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
%(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
%LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
%ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
%(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
%SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

% This code is written by Jiquan Ngiam (http://cs.stanford.edu/~jngiam/) and
% modified by Tao Wang


function [Oall, Owidth, Oheight, Ochannels] = fpool(imgstack, onestack, imwidth, imheight, imchannels)

% Pools over the image (strictly non-overlapping pooling)
% output = #output-images x #filters x pooled size

numcases = size(imgstack, 2);
Ochannels = imchannels;

% We now have new data X, pool it
Owidth  = ceil(imwidth/onestack.ps);
Oheight = ceil(imheight/onestack.ps);

% Do Pooling per Filter
imgstack = reshape(imgstack, imwidth*imheight, imchannels, numcases);
Oall     = zeros(Owidth * Oheight * imchannels, numcases);

B = zeros(onestack.ps * onestack.ps, Owidth * Oheight * numcases);


%     imgstack = reshape(imgstack, imwidth, imheight, imchannels, numcases);
%     Oall     = reshape(Oall,  Owidth*Oheight, imchannels, numcases);
%     for f = 1:imchannels
%         for im = 1:numcases
%             B = im2col(squeeze(imgstack(:,:,f,im)),[onestack.ps onestack.ps], 'distinct');
%             % Do Actual Pooling
%             Oall(:,f,im) = onestack.poolfunc(B);
%         end
%     end
    
    
    % vectorized along channels and numcases, much much faster than looping!
    imgstack = reshape(imgstack, imheight, imwidth, imchannels, numcases);
    Oall     = reshape(Oall,[ Oheight, Owidth, imchannels,numcases]);
    % do subsampling by sliding window
    xx2 =1 ; 
    for xx = 1:onestack.ps: (imwidth-onestack.ps+1)
        yy2 = 1;
        for yy = 1:onestack.ps: (imheight-onestack.ps+1)
            imblock = imgstack(yy:(yy+onestack.ps-1), xx:(xx+onestack.ps-1), :,:); % a block of feature map
            Oall(yy2,xx2,:,:) = squeeze(mean(mean(imblock,1),2)); % hard coded for mean pooling!
            yy2 = yy2+1;
        end
        xx2 = xx2+1;
    end

Oall = reshape(Oall, imchannels * Owidth * Oheight, numcases);
