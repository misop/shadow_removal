function removeShadow(I, mask)

comp = bwconncomp(mask,8);
%odstranime kazdy tien (jeden spojity komponent binarnej masky)
for i=1:comp.NumObjects
    %maska pre jeden tien
    maskTmp = zeros(size(mask));
    for j=1:size(comp.PixelIdxList{i},1)
        maskTmp(comp.PixelIdxList{i}(j)) = 1;
    end
    %obrysy tiena
    B = bwboundaries(maskTmp,8,'noholes');
    n = length(B{1});
    x = B{1}(:,1);
    y = B{1}(:,2);
    t = zeros(n,2);
    
    %dotycnice
    for j=1:n
        x0 = x(j);
        y0 = y(j);
        sx = 0; sy = 0;
        for ix=max(x0-3, 1):min(x0+3, size(I,2))
            for iy=max(y0-3, 1):min(y0+3, size(I,1))
                if maskTmp(iy, ix)
                    dx = ix-x0; dy = iy-y0;
                    if dx<0
                        dx=-dx; dy=-dy;
                    end
                    if dx==0 && dy<0
                        dx=-dx; dy=-dy;
                    end
                    sx=sx+dx; sy=sy+dy;
                end
            end
        end
        t(j) = atan2(sy, sx);
    end
    
    I = remove(I, maskTmp, x, y, t);
end

end




function ImgOut = remove(ImgIn, mask, x, y, t)

ps = 8;
Id = double(ImgIn) ./ 255;
%mc = edge(mask, 'canny');
%figure; imshow(mc);
%[x, y, t] = extractBoundary(mc);
[h, w] = size(mask);
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
        if (mask(i, j) == 1)
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
        if (mask(i, j) == 1)
            for ch = 1:3
               sl(i, j, ch) = (chs(ch)+1) * ImgIn(i, j, ch); 
            end
        else
           sl(i, j, :) = ImgIn(i, j, :); 
        end
    end
end
sl = uint8(sl);
figure; imshow(sl);
ImgOut = sl;
end

