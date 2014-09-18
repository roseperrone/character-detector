% Code written by Tao Wang (http://cs.stanford.edu/people/twangcat/)
function newy = ascii2label(y)
newy = zeros(size(y));
for i = 1:length(y)
    if(y(i)>=97) %lowercase 27-52
        newy(i) = y(i)-70;
    end
    if(y(i)>=65 && y(i)<=90)%upper case 1-26
        newy(i) = y(i)-64;
    end
    if(y(i)>=48 && y(i)<=57)%numbers 53-62
        newy(i) = y(i)+5;
    end
end


end
