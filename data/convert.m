%%
v = VideoReader('~/Downloads/templateVid_480p.MOV');
f = 0;
frames_original = [];
while hasFrame(v)
    frames_original = cat(3, frames_original, rgb2gray(readFrame(v)));
    
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