% Test LK tracking
% by Xidong Pi  11/03/2016

% clearvars
% clc

% Lucas-Kanade
load('../data/frames_480p_fps30.mat');
[~, ~, n] = size(frames);
% for i=1:5
%     figure
%     imshow(frames(:,:,20*i));
% end    

% 4 Points defines the quadrangle(TL->TR->BR->BL)
tic;
rect = zeros(8, n);
rect(:, 1) = [228; 87; 287; 87; 287; 146; 228; 146];
j = 0;
interval = 1; 
num = 100;
for i = (1+interval):interval:(1+num*interval)
    i
    j = j+1;
    minx = min([rect(1, j), rect(3, j), rect(5, j), rect(7, j)]);
    maxx = max([rect(1, j), rect(3, j), rect(5, j), rect(7, j)]);
    miny = min([rect(2, j), rect(4, j), rect(6, j), rect(8, j)]);
    maxy = max([rect(2, j), rect(4, j), rect(6, j), rect(8, j)]);
    M = LucasKanadeAffine(frames(miny:maxy,minx:maxx,i-interval), frames(miny:maxy,minx:maxx,i));
    rect(:, j+1) = [round(M(1:2,:)*[rect(1:2, j); 1]); round(M(1:2,:)*[rect(3:4, j); 1]); ...
        round(M(1:2,:)*[rect(5:6, j); 1]); round(M(1:2,:)*[rect(7:8, j); 1])];
end    
toc

% rects = rect';
% save('LK.mat', 'rects');

% load('LK.mat');
% % Plot
% frame_num = [1, (1+interval):interval*10:(1+num*interval)];
% for i = 2:numel(frame_num)
%     RGB = insertShape(frames(:, :, frame_num(i)), 'Polygon', ...
%         rects(2+(i-2)*10, :),'LineWidth',2,'Color','green');
%     figure 
%     imshow(RGB);
%     str = sprintf('Frame: %d, Second: %fs', frame_num(i), frame_num(i)/30);
%     title(str);
% end    
