function [] = pokus()
%POKUS Summary of this function goes here
%   Detailed explanation goes here

ps = 8;
I = imread('tien.png');
Id = double(I) ./ 255;
M = imread('mask.png');
M = rgb2gray(M) > 250;
mc = edge(M, 'canny');
[x, y, t]=bdry_extract_3(mc);
[h, w] = size(double(mc));
npt = length(x);
aCh = double([0.0, 0.0, 0.0]);
aChs = double([0, 0, 0]);
for n = 1:npt   
    x0 = x(n); y0 = y(n); t0 = t(n);
    x1 = round(x0 + 1.5*ps*cos(t0+pi/2));
    y1 = round(y0 + 1.5*ps*sin(t0+pi/2));
    x2 = round(x0 + 1.5*ps*cos(t0-pi/2));
    y2 = round(y0 + 1.5*ps*sin(t0-pi/2));
    if (x1 < 1 || x1 > h || x2 < 1 || x2 > h || y1 < 1 || y1 > w || y2 < 1 || y2 > w)
        continue;
    end
    x1 = uint32(x1);
    y1 = uint32(y1);
    x2 = uint32(x2);
    y2 = uint32(y2);
    for i = 1:3
        v1 = Id(x1, y1, i);
        v2 = Id(x2, y2, i);
        maxv = max([v1, v2]);
        minv = min([v1, v2]);
        aCh(i) = aCh(i) + maxv;
        aChs(i) = aChs(i) + minv;
    end
end
aCh = aCh ./ npt;
npt = 0;
for i = 1:h
    for j = 1:w
        if (M(i, j) == 1)
            for ch = 1:3
               aChs(ch) = aChs(ch) + Id(i, j, ch);
            end
            npt = npt + 1;
        end
    end
end
aChs = aChs ./ npt;
sl = zeros(h, w, 3);
chs = aCh ./ aChs;
for i = 1:h
    for j = 1:w
        if (M(i, j) == 1)
            for ch = 1:3
               sl(i, j, ch) = (chs(ch)+1) * I(i, j, ch); 
            end
        else
           sl(i, j, :) = I(i, j, :); 
        end
    end
end
sl = uint8(sl);
imshow(sl);
end

