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

function [Oall, Owidth, Oheight, Ochannels] = fconv(imgstack, onestack, imwidth, imheight, imchannels)

% Convolves a stack of images with multiple channels with
% a stack of filters with multiple channels
% AND summing over the channels 

% output = #output-images x #filters x each out image size

numcases = size(imgstack, 2);

% Create output variables
Owidth    = imwidth  - onestack.fx + 1;
Oheight   = imheight - onestack.fy + 1;
Ochannels = size(onestack.w, 1);
Oall      = zeros(Owidth * Oheight * size(onestack.w, 1), numcases);

%     imgstack = reshape(imgstack, imheight, imwidth, imchannels, numcases);    
%     Oall     = reshape(Oall, Owidth * Oheight, size(onestack.w, 1),numcases);    
%     % Naive CPU Implementation (used to double check the other (GPU)
%     % versions
%     % ============= Conv2 Method ================
%     F = reshape(onestack.w', onestack.fx, onestack.fy, onestack.fch, Ochannels);
%     
%     % Do Convolution Per Input Channel
%     for chan = 1:imchannels
%         for im = 1:numcases
%             % Convolve
%             A = squeeze(imgstack(:,:,chan,im));
%             for filt = 1:Ochannels
%                 B = squeeze(F(:,:,chan,filt));
%                 B = fliplr(flipud(B));
%                 O = conv2(A, B, 'valid');
%                 % Sum over the channels
%                 Oall(:, filt, im) = Oall(:, filt, im) + O(:);
%             end
%         end
%     end
%          Oall = reshape(Oall, Owidth * Oheight * Ochannels, numcases);
%          
         
         
         
% alternative implementation. Does not loop through the depth/data/kernels
% More efficient when num of channels/data much bigger than image sizes.
imgstack = reshape(imgstack, imheight, imwidth, imchannels, 1, numcases);
F = reshape(onestack.w', onestack.fx, onestack.fy, onestack.fch, Ochannels);
Oall     = reshape(Oall,[ Oheight, Owidth, size(onestack.w, 1),numcases]);
% do convolution by sliding window
for xx = 1:Owidth
    for yy = 1:Oheight
        imblock = imgstack(yy:(yy+onestack.fy-1), xx:(xx+onestack.fx-1), :,:,:); % a block of feature map
        O = bsxfun(@times, F, imblock); % one dot product in convolution
        Oall(yy,xx,:,:) = squeeze(sum(sum(sum(O,1),2),3));
    end
end
Oall = reshape(Oall, Owidth * Oheight * Ochannels, numcases);

% % alternative implementation. Does not loop through the depth and number of
% %kernels. More efficient when num of channels much bigger than image sizes.
%     imgstack = reshape(imgstack, imheight, imwidth, imchannels, numcases);
%     F = reshape(onestack.w', onestack.fx, onestack.fy, onestack.fch, Ochannels);
%     %Oall     = reshape(Oall,[ Oheight, Owidth, size(onestack.w, 1),numcases]); 
%     for im = 1:numcases
%         disp(im)
%         A = squeeze(imgstack(:,:,:,im)); % 3-d feature map of a single image
%         % do convolution by sliding window
%         tempO = zeros(Oheight, Owidth, Ochannels);
%         for xx = 1:Owidth
%             for yy = 1:Oheight
%                 imblock = A(yy:(yy+onestack.fy-1), xx:(xx+onestack.fx-1), :); % a block of feature map
%                 O = bsxfun(@times, F, imblock); % one dot product in convolution
%                 tempO(yy,xx,:) = squeeze(sum(sum(sum(O,1),2),3));
%             end
%         end
%         Oall(:, im) = tempO(:);
%     end
        
 
end

