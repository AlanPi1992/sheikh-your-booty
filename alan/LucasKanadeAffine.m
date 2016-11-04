function M = LucasKanadeAffine(It, It1)

% input - image at time t, image at t+1 
% output - M affine transformation matrix

It = double(It);
It1 = double(It1);

% Gradient
[Ix, Iy] = gradient(It);

% Jaccobian
% J = [x 0 y 0 1 0]
%     [0 x 0 y 0 0]

% Steepest Decent Images
[h, w] = size(It);
SDI = zeros(h, w, 6);
SDI(:, :, 1) = Ix.*repmat(1:w, [h,1]);
SDI(:, :, 2) = Iy.*repmat(1:w, [h,1]);
SDI(:, :, 3) = Ix.*repmat((1:h)', [1,w]);
SDI(:, :, 4) = Iy.*repmat((1:h)', [1,w]);
SDI(:, :, 5) = Ix; SDI(:, :, 6) = Iy;

% Inverse Hessian Matrix
H = zeros(6, 6);
for y = 1:h
    for x = 1:w
        H = H + reshape(SDI(y, x, :), [6, 1])*reshape(SDI(y, x, :), [1, 6]);
    end
end

p = zeros(6, 1);
M = [1+p(1) p(3) p(5); p(2) 1+p(4) p(6); 0 0 1];
while 1
    temp = zeros(6, 1);
    % Wrap I
    [Y, X] = meshgrid(1:h, 1:w);
    Yq = M(2,1)*X + M(2,2)*Y + M(2,3)*ones(size(Y));
    Xq = M(1,1)*X + M(1,2)*Y + M(1,3)*ones(size(Y));
    new = interp2(Y,X,It1(1:h, 1:w)',Yq,Xq)';
    for y = 1:h
        for x = 1:w
            if prod(round(M(1:2,:)*[x;y;1])<=[w-5; h-5]) && prod(round(M(1:2,:)*[x;y;1])>[5; 5])
                % Error image
                error = new(y, x) - It(y, x);
                temp = temp + reshape(SDI(y, x, :), [6, 1])*error;
            end
        end
    end    
    
    % Compute delta P (6 x 1 vector)
    dp = (H^(-1))*temp;
    
    % Update the wrap (p) and M
    dp_inv = [-dp(1)-dp(1)*dp(4)+dp(2)*dp(3); -dp(2); -dp(3);
              -dp(4)-dp(1)*dp(4)+dp(2)*dp(3); -dp(5)-dp(4)*dp(5)+dp(3)*dp(6);
              -dp(6)-dp(1)*dp(6)+dp(2)*dp(5)] / ((1+dp(4))*(1+dp(1))-dp(2)*dp(3));
    p = [p(1)+dp_inv(1)+p(1)*dp_inv(1)+p(3)*dp_inv(2);
         p(2)+dp_inv(2)+p(2)*dp_inv(1)+p(4)*dp_inv(2);
         p(3)+dp_inv(3)+p(1)*dp_inv(3)+p(3)*dp_inv(4);
         p(4)+dp_inv(4)+p(2)*dp_inv(3)+p(4)*dp_inv(4);
         p(5)+dp_inv(5)+p(1)*dp_inv(5)+p(3)*dp_inv(6);
         p(6)+dp_inv(6)+p(2)*dp_inv(5)+p(4)*dp_inv(6)];
    M = [1+p(1) p(3) p(5); p(2) 1+p(4) p(6); 0 0 1];
    
    % Stopping criterion
    norm(dp)
    if norm(dp) < 0.05
        break;
    end    
end
end
