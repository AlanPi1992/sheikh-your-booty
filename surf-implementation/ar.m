% Written by John Ryan - johnryan@cmu.edu


ref = rgb2gray(imread('../data/hiro.png'));

referencePoints = detectSURFFeatures(ref);

referenceFeatures = extractFeatures(ref, referencePoints);

figure;
imshow(ref), hold on;
plot(referencePoints.selectStrongest(50));