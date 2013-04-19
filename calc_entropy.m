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