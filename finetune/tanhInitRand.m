function w = tanhInitRand(sx,sy)
b = sqrt(6) / sqrt(sx+sy+1);
w = rand(sx,sy) * 2 * b - b;
end