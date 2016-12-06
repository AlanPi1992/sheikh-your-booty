%%
v = VideoReader('templateVid_480p.MOV');
f = 0;
frames_original = [];
limit = 360;
l = 0;

% original is 60 fps
while hasFrame(v)
    l = l + 1;
    if l > limit
        break;
    end
    frames_original = cat(3, frames_original, rgb2gray(readFrame(v)));    
    f = f + 1;
    disp(f);
    whos frames_orginal
end

%%
% we use 30 fps version for final poster, so [2 22 42 62] is taken from here
frames = [];
for i = 1 : size(frames_original, 3)
    if mod(i,2) == 1
        frames = cat(3, frames, frames_original(:,:,i));
    end
end

%save('~/Downloads/frames.mat', 'frames');
