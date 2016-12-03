%%
v = VideoReader('templateVid_480p.MOV');
f = 0;
frames_original = [];
limit = 360;
l = 0;
while hasFrame(v)
    l = l + 1;
    if l > limit
        break;
    end
    frames_original = cat(4, frames_original, readFrame(v));    
    f = f + 1;
    disp(f);
    whos frames_orginal
end

%%
frames = [];
for i = 1 : size(frames_original, 3)
    if mod(i,2) == 1
        frames = cat(3, frames, frames_original(:,:,i));
    end
end

%save('~/Downloads/frames.mat', 'frames');