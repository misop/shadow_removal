function intrinsic( )
%INTRINSIC Summary of this function goes here
%   Detailed explanation goes here
I = imread('1s.jpg');
I = im2double(I);
myfilter = fspecial('gaussian',[3 3], 0.5);
I = imfilter(I, myfilter, 'replicate');

[h, w, dim] = size(I);
R = I(:, :, 1);
G = I(:, :, 2);
B = I(:, :, 3);

% odstran nuly koli logu a deleniu
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
    
% spocitaj si chromaticitu
[X, Y] = chromaticity2(R, G, B, h, w);
vec = [X; Y];
%scatter(X,Y, 1);

% udaje ziskane z entropie
bestTheta = 1;
bestEntropy = 9999;
bestProj = [];

% premenne pre cyklus
idx = 1;
[qwertyu, num] = size(vec);
l_start = 1; l_end = 180; l_step = 1;

% entropia ktoru potom zobrazim v plote
entropy = zeros(1,((l_end-l_start) / l_step) + 1);
for theta = l_start:l_step:l_end
    x = cos(theta * pi / 180);
    y = sin(theta * pi / 180);
    u = [x; y];
    proj = zeros(1,num);
    for i = 1:num
       proj(i) = dot(vec(:,i), u);
    end
    entropy(idx) = calc_entropy(proj);
    if(entropy(idx) < bestEntropy)
       bestTheta = theta;
       bestEntropy = entropy(idx);
       bestProj = proj;
    end
    idx = idx + 1;
end
plot(entropy);

bestTheta

% OO = [cos(bestTheta * pi / 180); sin(bestTheta * pi / 180)];
% P_o = OO*OO';
% P = double(zeros(3,s));
% for i = 1:s
%     P(:,i) = U' * (P_o * vec(:,i));
% end;
% c = exp(P);
% 
% %intr = uint8(zeros(h, w, 3));
% intr = I;
% idx = 1;
% for i = 1:h
%     for j = 1:w
%         r = c(:,idx);
%         suma = sum(r);
%         n = r/suma;
%         %n = n * 255;
%         intr(i,j,1) = 255 * n(1);
%         intr(i,j,2) = 255 * n(2);
%         intr(i,j,3) = 255 * n(3);                
%         idx = idx + 1;
%     end
% end
% figure; imshow(intr);

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
%figure; imshow(edge(intr, 'canny'));
%imag = intr;
end

function [ entropy ] = calc_entropy( proj )
% bereme iba 90% strednych dat
[muhat,sigmahat,muci,sigmaci] = normfit(proj,0.1);
[dafuq, N] = size(proj);
proj2 = [];
for i = 1:N
    if((proj(i) >= (muhat - sigmaci(1))) && (proj(i) <= (muhat + sigmaci(2))))
        proj2 = [proj2, proj(i)];
    end;
end;
proj = proj2;

% Scott's Rule
[dafuq, N] = size(proj);
binSize = (3.5 * std(proj)) / (nthroot(N,3));
binNum = ceil(abs((max(proj) - min(proj)) / binSize));

% pocitanie histogramu
[c, x] = hist(proj, binNum);

% normalizacia histogramu
normalized = c/trapz(x,c);
normalized = normalized / sum(normalized);
logNormalized = arrayfun(@(x) log(x), normalized);

% vyskrtnem hodnoty ktore nesplnaju bias, koli velkym cislam pri logu
[qwerty, num] = size(normalized);
ind = 1;
Bias = 0.00001;
normalized2 = zeros(1,sum(normalized > Bias));
logNormalized2 = zeros(1,sum(normalized > Bias));
for i = 1:num
    if normalized(i) > Bias % Bias
       normalized2(ind) = normalized(i);
       logNormalized2(ind) = logNormalized(i);
       ind = ind + 1;
    end
end

% finalna entropia
entropyH = normalized2 .* logNormalized2;
entropy = -sum(entropyH);
end

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

function [X,Y] = chromaticity2(R, G, B, h, w)
    TT = R .* G .* B;
    TT = nthroot(TT, 3);
    R = R ./ TT;
    G = G ./ TT;
    B = B ./ TT;
    s = h*w;
    RR = reshape(R, 1, s);
    GG = reshape(G, 1, s);
    BB = reshape(B, 1, s);
    RR = arrayfun(@(x) log(x), RR);
    GG = arrayfun(@(x) log(x), GG);
    BB = arrayfun(@(x) log(x), BB);
    v1 = [1/sqrt(2);-1/sqrt(2); 0]';
    v2 = [1/sqrt(6); 1/sqrt(6);-2/sqrt(6)]';
    U = [v1; v2];
    O = [RR; GG; BB];
    RES = double(zeros(2,s));
    for i = 1:s
    RES(:,i) = U * O(:,i);
    end;

    X = RES(1,:);
    Y = RES(2,:);
end
