function [ entropy ] = getEntropy( proj, bias )

% berieme iba 90% strednych dat
[muhat, ~, ~, sigmaci] = normfit(proj, 0.1);
[~, N] = size(proj);
proj2 = [];
for i = 1:N
    if proj(i) >= muhat-sigmaci(1) && proj(i) <= muhat+sigmaci(2)
        proj2 = [proj2, proj(i)];
    end;
end;
proj = proj2;

% Scott's Rule
[~, N] = size(proj);
binSize = (3.5 * std(proj)) / (nthroot(N,3));
binNum = ceil(abs((max(proj) - min(proj)) / binSize));

% pocitanie histogramu
[c, x] = hist(proj, binNum);

% normalizacia histogramu
normalized = c/trapz(x,c);
normalized = normalized / sum(normalized);
logNormalized = arrayfun(@(x) log(x), normalized);

% vyskrtnem hodnoty ktore nesplnaju bias, koli velkym cislam pri logu
[~, num] = size(normalized);
idx = 1;
normalized2 = zeros(1,sum(normalized > bias));
logNormalized2 = zeros(1,sum(normalized > bias));
for i = 1:num
    if normalized(i) > bias
       normalized2(idx) = normalized(i);
       logNormalized2(idx) = logNormalized(i);
       idx = idx + 1;
    end
end

% finalna entropia
entropyH = normalized2 .* logNormalized2;
entropy = -sum(entropyH);

end
