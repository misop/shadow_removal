function [intrinsic, bestTheta] = getIntrinsic(I, chromaticityType, entropyBias, showChromaticity, showEntropy)

if (size(I,3) ~= 3)
   error('Image is not RGB!'); 
end

% gaussovsky filter
I = im2double(I);
myfilter = fspecial('gaussian',[3 3], 0.5);
I = imfilter(I, myfilter, 'replicate');

% odstran nuly kvoli logu a deleniu
I(I==0) = 1;

R = I(:, :, 1);
G = I(:, :, 2);
B = I(:, :, 3);
    
% spocitame chromaticitu
if (chromaticityType == 1)
    [X, Y] = chromaticity1(R, G, B);
else
    [X, Y] = chromaticity2(R, G, B);
end
chromaticityVec = [X; Y];
if showChromaticity
    figure; scatter(X,Y,1);
end

% udaje ziskane z entropie
bestTheta = 1;
bestEntropy = inf;
bestProj = [];
% premenne pre cyklus
idx = 1;
[tmp, num] = size(chromaticityVec);
l_start = 1; l_end = 180; l_step = 5;

% entropia, ktoru potom zobrazim v plote
entropy = zeros(1, uint16((l_end-l_start) / l_step));
for theta = l_start:l_step:l_end
    x = cos(theta * pi / 180);
    y = sin(theta * pi / 180);
    u = [x; y];
    proj = zeros(1,num);
    for i = 1:num
       proj(i) = dot(chromaticityVec(:,i), u);
    end
    entropy(idx) = getEntropy(proj, entropyBias);
    if(entropy(idx) < bestEntropy)
       bestTheta = theta;
       bestEntropy = entropy(idx);
       bestProj = proj;
    end
    idx = idx + 1;
end
if showEntropy
    figure; plot(linspace(l_start,l_end,length(entropy)), entropy);
end

minBestProj = abs(min(bestProj));
bestProj = bestProj + minBestProj;
maxBestProj = max(bestProj);

intrinsic = reconstructChromaticity(I, maxBestProj, bestProj);
intrinsic = uint8(intrinsic);

end
