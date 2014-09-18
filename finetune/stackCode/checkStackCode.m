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

function [] = checkStackCode

stack = cell(1,1);
stack{1}.w = tanhInitRand(6, 4);
stack{1}.b = randn(size(stack{1}.w,1),1);

stack{2}.w = tanhInitRand(5, 6);
stack{2}.b = randn(size(stack{2}.w,1),1);

data = randn(4, 5);
netconfig = stack2netconfig(stack);

params = [stack2params(stack)];
rconfig.actFunc = @tact;
rconfig.actFuncg = @tactg;

[loss, grad] = simpleLoss(params, rconfig, netconfig, data);
numgrad = computeNumericalGradient(@(p) simpleLoss(p, rconfig, netconfig, data), params);

disp([grad numgrad]);

diff = norm(numgrad-grad)/norm(numgrad+grad);
disp(diff);


end

function [loss, grad] = simpleLoss(params, rconfig, netconfig, data)

stack = params2stack(params, netconfig);

[h, savedfprop] = feedForwardStackR(rconfig, stack, data);

loss = sum(sum(h.^2 + h));
outderv = 2*h + 1;
stackgrad = backPropStackR(rconfig, stack, data, outderv, savedfprop);

grad = stack2params(stackgrad);


end
