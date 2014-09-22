function [ on_pill ] = patch_is_on_pill( patch )
%PATCH_IS_ON_PILL Returns false if > 80% of the patch is not close to black
%   The input patch must have values from 0 to 1.
ON_PILL_PERCENTAGE = 0.8;
on_pill = 1 - (size(find(patch < 0.06), 1) / (32*32)) > ON_PILL_PERCENTAGE;

end
