function [ intr ] = reconstructChromacity2( I, vec, bestTheta )
%RECONSTRUCTCHROMACITY2 Summary of this function goes here
%   Detailed explanation goes here
[h, w, dim] = size(I);
s = h*w;
v1 = [1/sqrt(2);-1/sqrt(2); 0]';
v2 = [1/sqrt(6); 1/sqrt(6);-2/sqrt(6)]';
U = [v1; v2];
    
OO = [cos(bestTheta * pi / 180); sin(bestTheta * pi / 180)];
P_o = OO*OO';
P = double(zeros(3,s));
for i = 1:s
    P(:,i) = U' * (P_o * vec(:,i));
end;
c = exp(P);

%intr = uint8(zeros(h, w));
intr = I;
idx = 1;
for i = 1:h
    for j = 1:w
        r = c(:,idx);
        suma = sum(r);
        n = r/suma;
        %n = n * 255;
        intr(i,j,1) = 255 * n(1);
        intr(i,j,2) = 255 * n(2);
        intr(i,j,3) = 255 * n(3);                
        idx = idx + 1;
    end
end
end

