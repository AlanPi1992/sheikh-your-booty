% by Xidong Pi

clear
clc

% ref = rgb2gray(imread('../surf-implementation/hiro3.png'));
% ref = rgb2gray(imread('../surf-implementation/hiro2.png'));
ref = rgb2gray(imread('../data/hiro1.png'));
% ref = imresize(ref, 0.1);
referencePoints = detectSURFFeatures(ref);
referenceFeatures = extractFeatures(ref, referencePoints);

mickey = imresize(rgb2gray(imread('../surf-implementation/mickey1.png')),3);
mickey = imresize(mickey, 0.2);
% load('../data/frames_480p_fps30.mat');
% camera = frames(:,:,100);
% v = vision.VideoFileReader('../surf-implementation/clip.mp4', ...
%     'VideoOutputDataType', 'uint8');
v = vision.VideoFileReader('../data/templateVid_480p.MOV', ...
    'VideoOutputDataType', 'uint8');
p = vision.VideoPlayer;
camera = rgb2gray(step(v));

pointTracker = vision.PointTracker('MaxBidirectionalError', 2);

% alpha = vision.AlphaBlender('Operation', 'Binary mask', ...
% 	'MaskSource', 'Input port');
alpha = vision.AlphaBlender('Operation', 'Blend', ...
	'OpacitySource', 'Property');

outputView = imref2d(size(camera));
vidTrans = imwarp(mickey, affine2d(), 'OutputView', outputView);
mask = vidTrans > 0;

recognized = 0;
counter = 0;
lag = 1;
for i = 1:600
    camera = rgb2gray(step(v));
    if(~recognized)
        if(mod(counter,3) ~= 0)
            counter = counter + 1;
            step(p, camera);
        end
        counter = counter+1;
        cameraPoints = detectSURFFeatures(camera);
        cameraFeatures = extractFeatures(camera, cameraPoints);
        
        idxPairs = matchFeatures(cameraFeatures, referenceFeatures);
        
        if(length(idxPairs) < 4)
            if(mod(lag,3) ~= 0)
%                 camera = step(alpha, camera, vidTrans, mask);
                camera = step(alpha, camera, vidTrans);
                lag = lag+1;
            else
                lag = 0;
            end
            step(p, camera);
            continue
        end
        lag = 1;
        recognized = 1;
        matchedCameraPts = cameraPoints(idxPairs(:, 1));
        matchedRefPts = referencePoints(idxPairs(:, 2));  
        [refTrans, inlierRefPts, inlierCamPts] = ...
            estimateGeometricTransform(matchedRefPts, ...
                matchedCameraPts, 'similarity');
        initialize(pointTracker, inlierCamPts.Location, camera);
         
        trackingTrans = refTrans;
    else %already recognized
        [trackedPoints, isValid] = step(pointTracker, camera);
       
        newLoc = trackedPoints(isValid, :);
        oldLoc = inlierCamPts.Location(isValid, :);
        if(nnz(isValid) < 6)
            recognized = 0;
            release(pointTracker);
%             camera = step(alpha, camera, vidTrans, mask);
            camera = step(alpha, camera, vidTrans);
            step(p, camera);
            continue;
        end
             
        [trackingTrans, oldInLoc, newInLoc] = ...
            estimateGeometricTransform(...
            oldLoc, newLoc, 'similarity');
        setPoints(pointTracker, newLoc);
        trackingTrans.T = refTrans.T * trackingTrans.T;
    end 
    
    vidTrans = imwarp(mickey, trackingTrans, ...
        'OutputView', outputView);
    mask = vidTrans>0;
%     camera = step(alpha, camera, vidTrans, mask);
    camera = step(alpha, camera, vidTrans);
 
    step(p, camera);
end
% figure;
% imshow(camera), hold on;
% plot(cameraPoints);

% Clean up
release(v);
release(p);
release(pointTracker);


