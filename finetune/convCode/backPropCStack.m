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

function [outderv, stackgrad] = backPropCStack(X, imwidth, imheight, imch, stack, outderv, savedfprop, skipoutderv)

    % outderv is the output derivatives

    % Backpropagate the error gradients
    % with the option to used the savedfprop values
    
    % Ease for coding first, compute savedfprop and save it somewhere
    if ~exist('savedfprop', 'var') || isempty(savedfprop)
        [dummmy, savedfprop] = feedForwardCStack(X, imwidth, imheight, imch, stack);
    end
    
    if ~exist('skipoutderv', 'var') || isempty(skipoutderv)
        skipoutderv = false;
    end

    % Sanity Checks
    assert(imwidth == imheight);
    for d = 1:numel(stack)
        assert(stack{d}.fs == 1);
        assert(stack{d}.fx == stack{d}.fy);
        assert(stack{d}.px == stack{d}.ps);
        assert(stack{d}.py == stack{d}.ps);
    end
    assert(stack{1}.fch == imch);
    
    % X is a stack of images (with potentially multiple channels),
    % all of the same size
    % we convolve the filters in stack with X
    numcases = size(X,2);
    
    for d = numel(stack):-1:1
        
        if stack{d}.ps > 1
            % Backprop Through Pooling
            outderv = bpool(savedfprop{d}.act, savedfprop{d}.pool, outderv, stack{d}, ...
                savedfprop{d}.convw, savedfprop{d}.convh, savedfprop{d}.convch, ...
                savedfprop{d}.poolw, savedfprop{d}.poolh, savedfprop{d}.poolch);
        end
        
        % Backprop Through actfunc
        outderv = outderv .* stack{d}.actfuncg(savedfprop{d}.addb, savedfprop{d}.act);
        
        % Get the gradient for stack{d}.b
        if nargout > 1
            cw = savedfprop{d}.convw; ch = savedfprop{d}.convh; cch = savedfprop{d}.convch;
            bg = reshape(outderv, cw * ch, cch, numcases);
            bg = permute(bg, [1 3 2]); 
            bg = reshape(bg, cw * ch * numcases, cch);
            stackgrad{d}.b = sum(bg)'/numcases;
            if isfield(stack{d}, 'learned') && ~stack{d}.learned
                %fprintf('layer %d, not updating b\n', d);
                stackgrad{d}.b = stackgrad{d}.b * 0;
%             else
%                 stackgrad{d}.b = stackgrad{d}.b .* stack{d}.indices;
            end
        end
        
        % Backprop Through Conv
        if d > 1
            if stack{d-1}.ps > 1
                imw = savedfprop{d-1}.poolw; imh = savedfprop{d-1}.poolh; imc = savedfprop{d-1}.poolch;
                imgstack = savedfprop{d-1}.pool;
            else
                imw = savedfprop{d-1}.convw; imh = savedfprop{d-1}.convh; imc = savedfprop{d-1}.convch;
                imgstack = savedfprop{d-1}.act;
            end
        else
            imw = imwidth; imh = imheight; imc = imch;
            imgstack = X;
        end
        
        if nargout > 1
            if skipoutderv && d == 1
                [outderv, wgrad] = bconv(imgstack, outderv, stack{d}, imw, imh, imc, savedfprop{d}.convw, savedfprop{d}.convh, savedfprop{d}.convch, skipoutderv);
            else
                [outderv, wgrad] = bconv(imgstack, outderv, stack{d}, imw, imh, imc, savedfprop{d}.convw, savedfprop{d}.convh, savedfprop{d}.convch);
            end
            stackgrad{d}.w = wgrad;
            if isfield(stack{d}, 'learned') && ~stack{d}.learned
                %fprintf('layer %d, not updating w\n', d);
                stackgrad{d}.w = stackgrad{d}.w * 0;                            
            else
                if isfield(stack{d}, 'indices')
                    stackgrad{d}.w = stackgrad{d}.w .* stack{d}.indices;
                end
            end
        else
            outderv = bconv(imgstack, outderv, stack{d}, imw, imh, imc, savedfprop{d}.convw, savedfprop{d}.convh, savedfprop{d}.convch);
        end
                
    end

   
end
