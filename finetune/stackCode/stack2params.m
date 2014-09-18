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

% This code is written by Jiquan Ngiam (http://cs.stanford.edu/~jngiam/)

function params = stack2params(stack)

fulllen = double(0);
for d = 1:numel(stack)
    if iscell(stack{d})
        for c = 1:numel(stack{d})
            wlen = double(numel(stack{d}{c}.w));
            blen = double(numel(stack{d}{c}.b));
            fulllen = fulllen + wlen + blen ;
        end
    else
        wlen = double(numel(stack{d}.w));
        blen = double(numel(stack{d}.b));
        fulllen = fulllen + wlen + blen ;
    end
end

% Map the gradients back into a single vector
if (iscell (stack{1}) && isa (stack{1}{1}.w, 'GPUsingle')) || ...
   (~iscell (stack{1}) && isa (stack{1}.w, 'GPUsingle'))
    params = zeros(fulllen, 1, GPUsingle);
else
    params = zeros(fulllen, 1);
end

curpos = double(1);
for d = 1:numel(stack)
    if iscell(stack{d})
        for c = 1:numel(stack{d})
            wlen = double(numel(stack{d}{c}.w));
            blen = double(numel(stack{d}{c}.b));
            params(curpos:curpos+wlen-1) = stack{d}{c}.w(:);
            curpos = curpos + wlen;
            blen = numel(stack{d}{c}.b);
            params(curpos:curpos+blen-1) = stack{d}{c}.b(:);
            curpos = curpos + blen;
        end
    else
        wlen = double(numel(stack{d}.w));
        params(curpos:curpos+wlen-1) = stack{d}.w(:);
        curpos = curpos + wlen;
        blen = double(numel(stack{d}.b));
        params(curpos:curpos+blen-1) = stack{d}.b(:);
        curpos = curpos + blen;
    end
end

end
