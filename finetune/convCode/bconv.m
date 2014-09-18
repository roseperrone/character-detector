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


function [outderv, wgrad] = bconv(imgstack, inderv, onestack, imwidth, imheight, imchannels, cwidth, cheight, cchannels, skipoutderv)

% we always compute outderv and wgrad optionally

if ~exist('skipoutderv', 'var') || isempty(skipoutderv)
    skipoutderv = false;
end

% ====== OUTDERV ====== 
% to compute outderv, use cuCopyInto and cuConv to simulate a full conv
% between inderv and the filters

numcases = size(imgstack, 2);

% Create output variables
outderv = zeros(imwidth * imheight * imchannels, numcases);

    
    if ~skipoutderv
        inderv   = reshape(inderv, cheight,cwidth,  cchannels, numcases);
        outderv  = reshape(outderv, imwidth * imheight, imchannels, numcases);

        % Naive CPU Implementation (used to double check the other (GPU)
        % versions
        % ============= Conv2 Method ================
        F = reshape(onestack.w', onestack.fx, onestack.fy, onestack.fch, cchannels);

        % !!! this is still very slow! TODO: vectorize just as I did for normal
        % convolution
        % Do Convolution Per Input Channel
        for filt = 1:cchannels
            for im = 1:numcases
                A = squeeze(inderv(:,:,filt,im)); 
                for chan = 1:imchannels
                    % Convolve
                    B = squeeze(F(:,:,chan,filt)); % remove singleton dimensions
                    %B = fliplr(flipud(B)); %====> Not really sure why we do
                    % not need to flip here ... but the gradients work out if
                    % we do not
                    %B = rot90(rot90(B));
                    O = conv2(A, B, 'full');
                    % Sum over the channels
                    outderv(:, chan, im) = outderv(:, chan, im) + O(:);
                end
            end
        end
    end


% Reshape nicely
outderv = reshape(outderv, imwidth * imheight * imchannels, numcases);

% ======  WGRAD  ====== 
% to compute wgrad, use a valid conv between inderv and the imgstack

if nargout <= 1
    return
end
% Create output variables
wgrad = zeros(size(onestack.w));
    
%     imgstack = reshape(imgstack, imwidth, imheight, imchannels, numcases);
%     inderv   = reshape(inderv, cheight, cwidth,  cchannels, numcases);
%     wgrad    = reshape(wgrad, onestack.fx * onestack.fy, onestack.fch, cchannels);
%     if strcmp(usegpu, 'jacket')
%         imgstack = gsingle(imgstack);
%         inderv = gsingle(inderv);
%         wgrad = gsingle(wgrad);
%     end
%     % Naive CPU Implementation (used to double check the other (GPU)
%     % versions
%     % ============= Conv2 Method ================
%     % Do Convolution Per Input Channel
%     for filt = 1:cchannels
%         for im = 1:numcases
%             A = squeeze(inderv(:,:,filt,im));
%             A = flipud(fliplr(A));
%             for chan = 1:imchannels
%                 % Convolve
%                 B = squeeze(imgstack(:,:,chan,im));
%                 O = conv2(B, A, 'valid');
%                 % Sum over the channels
%                 wgrad(:, chan, filt) = wgrad(:, chan, filt)  + O(:);
%             end
%         end
%     end
%     wgrad = wgrad / numcases;
    
    
    
    
    % alternative implementation. Does not loop through the depth/kernels/data
    % nice vectorized version :)
    % More efficient when num of channels/data is much bigger than image sizes.
    imgstack = reshape(imgstack, imheight, imwidth, 1, imchannels, numcases);
    imgstack = permute(imgstack, [1,2,5,3,4]);
    inderv   = reshape(inderv, cheight, cwidth,  cchannels, numcases);
    inderv = permute(inderv, [1,2,4,3] );
    
    wgrad    = reshape(wgrad, [onestack.fy, onestack.fy, onestack.fch, cchannels]);
    % do convolution by sliding window

    Owidth = imwidth - cwidth +1;
    Oheight = imheight - cheight +1;
    for xx = 1:Owidth
        for yy = 1:Oheight
            imblock = imgstack(yy:(yy+cheight-1), xx:(xx+cwidth-1), :, :, :); % a block of feature map
            O = bsxfun(@times, inderv, imblock); % one dot product in convolution
            wgrad(yy,xx,:,:) = permute(squeeze(sum(sum(sum(O,1),2),3)), [2,1]);
        end
    end
    wgrad = wgrad / numcases;
    

wgrad = reshape(wgrad, onestack.fx*onestack.fy*onestack.fch, cchannels);
wgrad = wgrad';

end
