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


function [X, savedfprop] = feedForwardCStack(X, imwidth, imheight, imch, stack)

    % Sanity Checks
    assert(imwidth == imheight);
    for d = 1:numel(stack)
        assert(stack{d}.fs == 1);
        assert(stack{d}.fx == stack{d}.fy);
        assert(stack{d}.px == stack{d}.ps);
        assert(stack{d}.py == stack{d}.ps);
    end
    assert(stack{1}.fch == imch);
    
    % Save
    if nargout > 1
        savedfprop = cell(numel(stack), 1);
    end
    
    % X is a stack of images (with potentially multiple channels),
    % all of the same size
    % we convolve the filters in stack with X

    numcases = size(X,2);
    
    % Current Width/Height
    cw = imwidth; ch = imheight; cch = imch;
    for d = 1:numel(stack)
        
        % Feed Forward Conv
        [X, cw, ch, cch] = fconv(X, stack{d}, cw, ch, cch);
        
        % Save!
        if nargout > 1
            % savedfprop{d}.conv = X;  % no one uses this?
            savedfprop{d}.convw = cw;
            savedfprop{d}.convh = ch;
            savedfprop{d}.convch = cch;
        end
        
        % Reshape and Add Bias (check!)
        X = reshape(X, cw * ch, cch, numcases);
        X = permute(X, [1 3 2]); X = reshape(X, cw * ch * numcases, cch);
        X = bsxfunwrap(@plus, X, stack{d}.b');
        X = reshape(X, cw * ch, numcases, cch); X = permute(X, [1 3 2]);
        X = reshape(X, cw * ch * cch, numcases);

        % Save!
        if nargout > 1
            savedfprop{d}.addb = X;
        end

        % Activate
        X = stack{d}.actfunc(X);
        
        % Save!
        if nargout > 1
            savedfprop{d}.act = X;
        end
        
        if stack{d}.px > 1
            % Pool if ps > 1
            [X, cw, ch, cch] = fpool(X, stack{d}, cw, ch, cch);

            % Save?
            if nargout > 1
                savedfprop{d}.pool = X;
                savedfprop{d}.poolw = cw;
                savedfprop{d}.poolh = ch;
                savedfprop{d}.poolch = cch;
            end
        end
        
    end
    
    X = reshape(X, cch*cw*ch, numcases);
    
end
