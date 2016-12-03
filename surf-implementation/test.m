clearvars;
ref = rgb2gray(imread('hiro2.png'));
%ref = imresize(ref, 0.1);

%points = detectSURFFeatures(ref);

j_points = j_detectSURFFeatures(ref);