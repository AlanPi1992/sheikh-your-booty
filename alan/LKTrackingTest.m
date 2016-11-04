% Test LK tracking
% by Xidong Pi  11/03/2016

% clearvars
% clc

% Lucas-Kanade
% load('../data/frames_480p_fps30.mat');
[~, ~, n] = size(frames);
n

% 4 Points defines the quadrangle(TL->TR->BR->BL)
rect = zeros(8, n);
rect(:, 1) = [228; 87; 146; 152];
% height = 152 - 117;
% width = 146 - 60;
% for i = 2:n
%     i
%     M = LucasKanadeAffine(frames(:,:,i-1), frames(:,:,i), rect(:, i-1));
%     rect(:, i) = [round(rect(1, i-1)+u); round(rect(2, i-1)+v); round(rect(3, i-1)+u); round(rect(4, i-1)+v)];
% end    

new = round(M(1:2,:)*[x;y;1]);

% rects = rect';
% save('carseqrects.mat', 'rects');

% Plot
frame_num = [1, 100, 200, 300, 400];
for i = 1:1
    RGB = insertShape(frames(:, :, frame_num(i)), 'Rectangle', ...
        [228 87 59 59],'LineWidth',2,'Color','gree');
    figure 
    imshow(RGB);
end    
