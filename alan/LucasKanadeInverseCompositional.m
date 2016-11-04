function [u,v] = LucasKanadeInverseCompositional(It, It1, rect)

% input - image at time t, image at t+1, rectangle (top left, bot right coordinates)
% output - movement vector, [u,v] in the x- and y-directions.
It = double(It);
It1 = double(It1);
T = It(rect(2):rect(4), rect(1):rect(3));
[Ix, Iy] = gradient(T);

H = zeros(2, 2);
H(1,1) = sum(sum(Ix.^2));
H(1,2) = sum(sum(Ix.*Iy));
H(2,1) = H(1,2);
H(2,2) = sum(sum(Iy.^2));

u = double(0); v = double(0);
while 1
    y1 = rect(2)+v; y2 = rect(4)+v; x1 = rect(1)+u; x2 = rect(3)+u;
    ly = floor(y1); hy = ceil(y2); lx = floor(x1); hx = ceil(x2);
    [Y, X] = meshgrid(ly:hy, lx:hx);
    [Yq, Xq] = meshgrid(y1:y2, x1:x2);

    new = interp2(Y,X,It1(ly:hy, lx:hx)',Yq,Xq)';
    error = new - T;
    temp = [sum(sum(error.*Ix)); sum(sum(error.*Iy))];
    deltap = (H^(-1))*temp;
    u = u - deltap(1);
    v = v - deltap(2);
    if norm(deltap) < 0.001
        break;
    end    
end
end