function intrinsic( )
%INTRINSIC Summary of this function goes here
%   Detailed explanation goes here
chromaChoice = 1;
I = imread('1.png');
I = im2double(I);
myfilter = fspecial('gaussian',[3 3], 0.5);
I = imfilter(I, myfilter, 'replicate');

% odstran nuly koli logu a deleniu
I(I==0)=1;

[h, w, dim] = size(I);
R = I(:, :, 1);
G = I(:, :, 2);
B = I(:, :, 3);
    
% spocitaj si chromaticitu
if (chromaChoice == 1)
    [X, Y] = chromaticity1(R, G, B, h, w);
else
    [X, Y] = chromaticity2(R, G, B, h, w);
end
vec = [X; Y];
%scatter(X,Y, 1);

% udaje ziskane z entropie
bestTheta = 1;
bestEntropy = 9999;
bestProj = [];

% premenne pre cyklus
idx = 1;
[qwertyu, num] = size(vec);
l_start = 1; l_end = 180; l_step = 5;

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
%plot(entropy);

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

intr = [];
if (chromaChoice == 1)
    intr = reconstructChromacity1(I, bestTheta, minBP, maxBP);
else
    intr = reconstructChromacity2(I, vec, bestTheta);
end
intr = uint8(intr);
figure; imshow(intr);
%figure; imshow(edge(intr, 'canny'));
%imag = intr;
end
