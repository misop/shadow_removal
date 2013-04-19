function [X,Y] = chromaticity1(R, G, B, h, w)
    GR = G ./ R;%X
    BR = B ./ R;%Y
    s = h*w;
    X = reshape(GR, 1, s);
    Y = reshape(BR, 1, s);
    X = double(X); Y = double(Y);
    X = arrayfun(@(x) log(x), X);
    Y = arrayfun(@(x) log(x), Y);
end