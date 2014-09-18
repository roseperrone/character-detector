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

function [stack,curpos] = params2cstack(params, netconfig)

% Map the params (a vector into a stack of weights)
depth = numel(netconfig.layersizes);
stack = cell(depth,1);
curpos = double(1);

for d = 1:depth
    
    filtersize = netconfig.stackinfo{d}.fch * netconfig.stackinfo{d}.fx * netconfig.stackinfo{d}.fy;
    
    stack{d} = struct;
    wlen = double(netconfig.layersizes{d} * filtersize);
    stack{d}.w = reshape(params(curpos:curpos+wlen-1), netconfig.layersizes{d}, filtersize);
    curpos = curpos+wlen;
    blen = double(netconfig.layersizes{d});
    stack{d}.b = reshape(params(curpos:curpos+blen-1), netconfig.layersizes{d}, 1);
    curpos = curpos+blen;
    
    % copy out stackinfo
    fns = fieldnames(netconfig.stackinfo{d});
    for n = 1:numel(fns)
        fn = fns(n); fn = fn{1};
        stack{d}.(fn) = netconfig.stackinfo{d}.(fn);
    end

    
end

end
