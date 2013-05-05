function [ intr ] = reconstructChromaticity(I, maxBP, bestProj)

[h, w, ~] = size(I);
bestProj = bestProj ./ maxBP;
A = sort(bestProj, 'descend');
bestProj = bestProj .* 255;
bestProj = reshape(bestProj, h, w);
intr = uint8(bestProj);

% add energy of 1% brightest pixels
G = rgb2gray(I);
B = sort(reshape(G, 1, h*w), 'descend');
siz = int32(h * w * 0.01);  % 1% brightest pixels
C = B(1:siz) - A(1:siz);
dif = int32(mean(C) * 255);

if (dif < 0)
    intr = intr - uint8(-dif);
else
    intr = intr + uint8(dif);
end
%imshow(intr);
%imshow(G);
end

