% Written by John Ryan - johnryan@cmu.edu
clearvars;
tic 
ref = rgb2gray(imread('../data/hiro1.png'));
%ref = imresize(ref, 0.1);

referencePoints = detectSURFFeatures(ref);
referenceFeatures = extractFeatures(ref, referencePoints);


mickey = imresize(rgb2gray(imread('../data/square.png')),0.3);
% load('../data/frames_480p_fps30.mat');
% camera = frames(:,:,100);

v = vision.VideoFileReader('../data/templateVid_original.mov', ...
    'VideoOutputDataType', 'uint8');
p = vision.VideoPlayer;

pointTracker = vision.PointTracker('MaxBidirectionalError', 2);



alpha = vision.AlphaBlender('Operation','Binary mask',...
	'MaskSource','Input port');
recognized = 0;
camera = rgb2gray(step(v));
outputView = imref2d(size(camera));
counter=0;
lag = 1;


for i = 1:123
    if(i==122)
        figure;
        imshow(camera);
        title('Frame 62');
    end
    camera = rgb2gray(step(v));
    if(~recognized)
        if(mod(counter,3)~=0)
            counter = counter+1;
            step(p, camera);
        end
        counter = counter+1;
        cameraPoints = detectSURFFeatures(camera);
        cameraFeatures = extractFeatures(camera, cameraPoints);
        
        idxPairs = matchFeatures(cameraFeatures, referenceFeatures);
        
        if(length(idxPairs)<5)
            if(mod(lag,3)~=0)
                camera = step(alpha, camera, vidTrans, mask);
                lag = lag+1;
            else
                lag = 0;
            end
            step(p, camera);
            continue
        end
        lag = 1;
        recognized = 1;
        matchedCameraPts = cameraPoints(idxPairs(:,1));
        matchedRefPts = referencePoints(idxPairs(:,2));  
        [refTrans, inlierRefPts, inlierCamPts] = ...
            estimateGeometricTransform(matchedRefPts, ...
                matchedCameraPts, 'affine');
        initialize(pointTracker,inlierCamPts.Location, camera);
         
        trackingTrans = refTrans;
    else
        [trackedPoints, isValid] = step(pointTracker, camera);
        newLoc = trackedPoints(isValid,:);
        oldLoc = inlierCamPts.Location(isValid,:);
        if(nnz(isValid)<5)
            recognized = 0;
            release(pointTracker);
            camera = step(alpha, camera, vidTrans, mask);
            step(p, camera);
            continue
        end
        
        
       
        [trackingTrans, oldInLoc, newInLoc] = ...
            estimateGeometricTransform(...
            oldLoc,newLoc,'affine');
        setPoints(pointTracker,newLoc);
        trackingTrans.T = refTrans.T * trackingTrans.T;
    end 
    
    vidTrans = imwarp(mickey, trackingTrans, ...
        'OutputView', outputView);
    mask = vidTrans>0;
    camera = step(alpha, camera, vidTrans, mask);
%     
   % step(p, camera);
end
toc
% figure;
% imshow(camera), hold on;
% plot(cameraPoints);



