function [ smoothMask contoursImg ] = smoothShadowMask( I, mask )

s = size(mask,1) * size(mask,2);
smallObjectsSizePercents = 5;
P = round(s*smallObjectsSizePercents/100);
mask = bwareaopen(mask, P);
mask = imcomplement(mask);
mask = bwareaopen(mask, P);
mask = imcomplement(mask);
smoothMask = imclose(mask, strel('disk',5));

contoursImg = I;
B = bwboundaries(smoothMask,8,'holes');
for i=1:length(B)
   for j=1:length(B{i})
       contoursImg(B{i}(j,1),B{i}(j,2),1) = 255;
       contoursImg(B{i}(j,1),B{i}(j,2),2) = 0;
       contoursImg(B{i}(j,1),B{i}(j,2),3) = 0;
   end
end

end

