function [ intr ] = reconstructChromacity1( I, theta, minBP, maxBP )
%RECONSTRUCTCHROMACITY1 Summary of this function goes here
%   Detailed explanation goes here
[h, w, dim] = size(I);
u = [cos(theta * pi / 180); sin(theta * pi / 180)];
intr = uint8(zeros(h, w));
for i = 1:h
    for j = 1:w
        R = double(I(i, j, 1));
        G = double(I(i, j, 2));
        B = double(I(i, j, 3));
        GR = G / R;
        BR = B / R;
        v = [log(GR); log(BR)];
        n = dot(u, v);
        n = n + minBP;
        n = n / maxBP;
        n = n * 255;
        intr(i,j) = uint8(n);
    end
end
end

