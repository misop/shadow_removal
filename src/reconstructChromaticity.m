function [ intr ] = reconstructChromaticity(I, maxBP, bestProj)

[h, w, ~] = size(I);
bestProj = bestProj ./ maxBP;
bestProj = bestProj .* 255;
bestProj = reshape(bestProj, h, w);
intr = uint8(bestProj);
return;

end

