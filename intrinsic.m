function [ ] = intrinsic( )
%INTRINSIC Summary of this function goes here
%   Detailed explanation goes here
I = imread('6.png');
[h, w, dim] = size(I);
R = double(I(:, :, 1));
G = double(I(:, :, 2));
B = double(I(:, :, 3));
for i = 1:h
    for j = 1:w
        if R(i,j) == 0
            R(i,j) = 1;
        end
        if G(i,j) == 0
            G(i,j) = 1;
        end
        if B(i,j) == 0
            B(i,j) = 1;
        end
    end
end
GR = G ./ R;%X
BR = B ./ R;%Y
s = h*w;
X = reshape(GR, 1, s);
Y = reshape(BR, 1, s);
X = double(X); Y = double(Y);
X = arrayfun(@(x) log(x), X);
Y = arrayfun(@(x) log(x), Y);
%scatter(X,Y, 1);
vec = [X; Y];
[~, num] = size(vec);
bestTheta = 1;
bestEntropy = 0;
bestProj = [];
first = true;
for theta = 1:1:180
    x = cos(theta * pi / 180);
    y = sin(theta * pi / 180);
    u = [x; y];
    proj = [];
    for i = 1:num
        if i == 5670
           v = vec(:,i); 
        end
       proj(i) = dot(vec(:,i), u);
    end
    entropy = calc_entropy(proj);
    if (first || entropy < bestEntropy)
       bestTheta = theta;
       bestEntropy = entropy;
       bestProj = proj;
       first = false;
    end
end

bestTheta
minBP = abs(min(bestProj));
bestProj = bestProj + minBP;
maxBP = max(bestProj);

u = [cos(bestTheta * pi / 180); sin(bestTheta * pi / 180)];
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
figure; imshow(intr);
figure; imshow(edge(intr, 'canny'));
%imag = intr;
end

function [ entropy ] = calc_entropy( proj )
binSize = 100;
[c, x] = hist(proj, binSize);
normalized = c/trapz(x,c);
logNormalized = arrayfun(@(x) log(x), normalized);
[~, num] = size(normalized);
ind = 1;
normalized2 = [];
logNormalized2 = [];
for i = 1:num
    if normalized(i) > 0
       normalized2(ind) = normalized(i);
       logNormalized2(ind) = logNormalized(i);
       ind = ind + 1;
    end
end
entropyH = normalized2 .* logNormalized2;
entropy = -sum(entropyH);
end

