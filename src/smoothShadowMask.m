function [ smoothMask ] = smoothShadowMask( mask )

s = size(mask,1) * size(mask,2);
smallObjectsSizePercents = 5;
P = round(s*smallObjectsSizePercents/100);
mask = bwareaopen(mask, P);
mask = imcomplement(mask);
mask = bwareaopen(mask, P);
mask = imcomplement(mask);
smoothMask = imclose(mask, strel('disk',3));
end

