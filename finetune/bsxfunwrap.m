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

function c = bsxfunwrap(func, a, b)

% only expand b

global usegpu;

if strcmp(usegpu, 'gpumat')
    
    if size(a,1) > 1 && size(b,1) == 1
        assert(size(a,2) == size(b,2), 'bsxfunwrap singleton dimensions');
        c = func(a, repmat(b, size(a,1), 1));
    elseif size(a,2) > 1 && size(b,2) == 1
        assert(size(a,1) == size(b,1), 'bsxfunwrap singleton dimensions dont agree case 4');
        c = func(a, repmat(b, 1, size(a,2)));

    elseif size(b,1) > 1 && size(a,1) == 1
        assert(size(b,2) == size(a,2), 'bsxfunwrap singleton dimensions');
        c = func(repmat(a, size(b, 1), 1), b);
    elseif size(b,2) > 1 && size(a,2) == 1
        assert(size(b,1) == size(a,1), 'bsxfunwrap singleton dimensions dont agree case 4');
        c = func(repmat(a, 1, size(b, 2)), b);
        
        
    else
        assert(size(a,1) == size(b,1), 'no bsxfun to do, bsxfunwrap dimensions dont agree');
        assert(size(a,2) == size(b,2), 'no bsxfun to do, bsxfunwrap dimensions dont agree');
        c = func(a, b);
    end
else
    c = bsxfun(func, a, b);
end

end
