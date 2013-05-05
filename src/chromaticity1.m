function [X,Y] = chromaticity1(R, G, B)
    GR = G ./ R; %X
    BR = B ./ R; %Y
    s = size(R,1) * size(R,2);
    X = reshape(GR, 1, s);
    Y = reshape(BR, 1, s);
    X = double(X); Y = double(Y);
    X = arrayfun(@(x) log(x), X);
    Y = arrayfun(@(x) log(x), Y);
end