function predictions = detect_char( filename )
%DETECT_CHAR Detects characters
%   Returns an array of structs, where each struct has these fields:
%     filename: the input filename
%     x, y: the top left corner of the detected char
%     scale: the image scale at which the character was detected


% The window size is always 32x32
% The possible scales, and the window step sizes at each scale
% 1024  16
% 512   16
% 256   8
% 128   8
% 64    8
%
% So roughly 6.4k windows are computed. Let's see if this is too slow...

scales = [1024, 512, 256, 128, 64];
step_sizes = [16, 16, 8, 8, 8];

predictions = [];

predictions = [predictions; struct('filename', 'just/testing', ...
                                   'x', 3, ...
                                   'y', 4, ...
                                   'scale', 1.7203)];

end

