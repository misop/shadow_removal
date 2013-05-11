function removeShadow2(I, mask, smoothEdges)
mask = double(mask);

labTransformation = makecform('srgb2lab');
lab = applycform(I,labTransformation);

[h, w, d] = size(I);
if(smoothEdges == true)
    Gaus = fspecial('gaussian',[7 7]);
    mask = imfilter(mask, Gaus, 'same');    
end;
%figure;imshow(mask);

G = double(rgb2gray(I));
%figure;imshow(G);

L = watershed(G);
maxi = max(max(L));

% urobi kktinu ak je viac ako 20 susedov
max_susedov = 20;
table = zeros(max_susedov, maxi);

for i=1:maxi
    a = (L == i);
    table(1, i) = mean(G(a));
    table(2, i) = max(mask(a));
    [r, c] = find(a);
    
    % zisti kolko ma susedov
    set(0,'RecursionLimit',1000);
    [result, zoznam] = GetAllNValues(L, r(1), c(1), i, [-1, -1, 1], 1);
    % odstran 0 a seba sameho
    result = result(result~=0);
    result = result(result~=i);    
    result = unique(result);
    result = sort(result);
    table(3, i) = max(size(result));
    maxxi = min(table(3, i), (max_susedov - 3));
    % a zapis prvych maxinalne (max_susedov - 3) susedov
    for j = 1:maxxi
        table(j+3, i) = result(j);
    end;
end;

table2 = zeros(3, maxi);
table2(2,:) = table(2,:) > 0;

% nemame nic svetle
if(min(table2(2,:)) > 0)
    display('nemame nic svetle');
    return;
end;

while(max(table2(2,:)) > 0)
    % zapis kolko svetlych susedov maju tienove oblasti
    table2 = CountBrightN(table, table2);
    % zober tie s najvecsim poctom svetlych susedov
    pocet_sus = max(table2(3, :));
    table2(3,:) = (table2(3,:) == pocet_sus);
    % spocitaj rozdiel so svetlymi susedmi
    [table, table2] = ComputeDifference(table, table2);
end;

LL = uint8(zeros(h,w));
for i = 1:h
    for j = 1:w
        idx = L(i,j);
        if(idx > 0)
            val = double(table2(1, idx));
        else
            vals = Get8N(L, i, j);
            vals = vals(vals > 0);
            [ww,hh] = size(vals);
            vals2 = double(zeros(1, hh));
            for l=1:hh
                vals2(l) = double(table2(1, vals(l)));
            end;
            val = mean(vals2);
        end;
        perc = double(mask(i,j));
%         val = abs(val * perc);
%         LL(i, j) = uint8(floor(val));
%         nasob = (G(i,j) + val) / G(i,j);
%         I(i, j, :) = uint8(I(i, j, :) * nasob);
        val = uint8(floor(abs(val * perc)));
        LL(i, j) = val;
        lab(i, j, 1) = lab(i, j, 1) + val;
    end;
end;

labTransformation = makecform('lab2srgb');
I = applycform(lab,labTransformation);

figure; imshow(LL);
figure; imshow(I);

% koniec hlavneho scriptu a zaciatok pomocnych

function result = Get8N(I, i, j)
[h, w] = size(I);
result = zeros(1, 8);
idx = 1;
for ii = (i-1) : (i+1)
    for jj = (j-1) : (j+1)
        if((ii == i) && (jj == j))
            continue;
        end;
        if((ii > 0) && (ii <= h) && (jj > 0) && (jj <= w))
            result(idx) =  I(ii, jj);  
        end;
        idx = idx + 1;
    end;
end;

function [result,zoznam] = GetAllNValues(I, i, j, val, zoznam, steps)
result = 0;
[h, w] = size(zoznam);
uz_mam = false;

% prejdem zoznam a pozrem ci tam uz nie som
for l = 1:h
    if((zoznam(l,1) == i) && (zoznam(l,2) == j))
        if((zoznam(l,3) == 0) && (steps == 1))
            zoznam(l,3) = 1;
            uz_mam = true;
            break;
        else
            return;
        end;
    end;
end;

if(uz_mam == false)
    zoznam = [zoznam; [i, j, steps]];
end;

result = I(i,j);


if((result ~= 0) && (result ~= val))
    return;
end;
[h, w] = size(I);

% v nule nejdem viac ako raz
if(steps == 0)
    return;
end;

if(result == 0)
    steps = 0;
end;

for ii = (i-1) : (i+1)
    for jj = (j-1) : (j+1)
        if((ii == i) && (jj == j))
            continue;
        end;
        if((ii > 0) && (ii <= h) && (jj > 0) && (jj <= w))
            [result2, zoznam] = GetAllNValues(I, ii, jj, val, zoznam, steps);
            result = [result; result2];
        end;
    end;
end;
return;

function table2 = CountBrightN(table, table2)
[h, w] = size(table2);
table2(3, :) = zeros(1, w);
% pre vsetky prvky z tabulky
for i = 1:w
    % ak je v tieni
    if(table2(2,i) == 1)
        pocet = 0;
        % pre vsetkych jeho susedov
        for j=1:table(3,i)
            % ak su v tieni
            idx = table(3+j,i);
            if(table2(2,idx) == 0)
                pocet = pocet + 1;
            end;
        end;
        table2(3, i) = pocet;
    end;
end;
return;

function [table, table2] = ComputeDifference(table, table2)
[h, w] = size(table2);
% pre vsetky prvky z tabulky
for i = 1:w
    % ak ho zosvetlujeme, pocet susedov > 0
    if(table2(3,i) > 0)
        
        pocet = [];
        % pre vsetkych jeho susedov
        for j=1:table(3,i)
            % ak su svetli
            idx = table(3+j,i);
            if(table2(2,idx) == 0)
                pocet = [pocet, table(1, idx)];
            end;
        end;
        svetlost = mean(pocet);
        table2(3, i) = 0;   % zmaz susedov
        table2(2, i) = 0;   % zmaz svetlost
        table2(1, i) = abs(svetlost - table(1, i));  % nastav rozdiel
        table(1, i) = max(svetlost, table(1, i)); % prepis povodnu hodnotu
    end;
end;
return;