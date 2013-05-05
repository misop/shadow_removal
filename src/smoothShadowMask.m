function [ smoothMask ] = smoothShadowMask( mask )

s = size(mask,1) * size(mask,2);
smallObjectsSizePercents = 5;
P = round(s*smallObjectsSizePercents/100);
mask = bwareaopen(mask, P);
maskInv = imcomplement(mask);
maskInv = bwareaopen(maskInv, P);
smoothMask = imcomplement(maskInv);

end

