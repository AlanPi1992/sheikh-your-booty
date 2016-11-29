% By Xidong Pi, 11/29/2016

clear
clc

% Create the face detector object
faceDetector = vision.CascadeObjectDetector();

% Create the point tracker object
pointTracker = vision.PointTracker('MaxBidirectionalError', 2);

% Create the webcam object
cam = webcam();

% Capture one frame to get its size
videoFrame = snapshot(cam);
frameSize = size(videoFrame);
outputView = imref2d(frameSize);

% Create the video player object
videoPlayer = vision.VideoPlayer('Position', [5 5 [frameSize(2), frameSize(1)]+5]);

% Create the alpha blender object
alpha = vision.AlphaBlender('Operation', 'Binary mask', 'MaskSource', 'Input port');

% Read the image to be blended into vedio
mickey = imread('emoji.png');
% mickey = imread('baoman.png');
if (size(mickey, 3) == 1)
    mickey = repmat(mickey, [1,1,3]);
end
boxMickey = [1, 1; size(mickey, 2), 1; ...
    size(mickey, 2), size(mickey, 1); 1, size(mickey, 1)];

% Intialization
runLoop = true;
numPts = 0;
frameCount = 0;
trackingTrans = 0;

% Begin detection and tracking
while runLoop && frameCount < 1e6

    % Get the next frame
    videoFrame = snapshot(cam);
    videoFrameGray = rgb2gray(videoFrame);
    frameCount = frameCount + 1;

    if numPts < 50
        % Detection mode
        bbox = faceDetector.step(videoFrameGray);

        if ~isempty(bbox)
            % Find corner points inside the detected region
            points = detectMinEigenFeatures(videoFrameGray, 'ROI', bbox(1, :));

            % Re-initialize the point tracker
            xyPoints = points.Location;
            numPts = size(xyPoints,1);
            release(pointTracker);
            initialize(pointTracker, xyPoints, videoFrameGray);

            % Save a copy of the points
            oldPoints = xyPoints;

            % Convert the rectangle represented as [x, y, w, h] into an
            % M-by-2 matrix of [x,y] coordinates of the four corners
            bboxPoints = bbox2points(bbox(1, :));
                 
            % Get the initial tranformation matrix everytime after
            % detection using 4 corner correspondences
            [refTrans, inlierRefPts, inlierCamPts] = ...
            estimateGeometricTransform(boxMickey, ...
                bboxPoints, 'similarity');
            trackingTrans = refTrans;

            % Convert the box corners into the [x1 y1 x2 y2 x3 y3 x4 y4]
            % format required by insertShape
%             bboxPolygon = reshape(bboxPoints', 1, []);

            % Display a bounding box around the detected face
%             videoFrame = insertShape(videoFrame, 'Polygon', bboxPolygon, 'LineWidth', 3);

            % Display detected corners
%             videoFrame = insertMarker(videoFrame, xyPoints, '+', 'Color', 'white');
        end

    else
        % Tracking mode
        [xyPoints, isFound] = step(pointTracker, videoFrameGray);
        visiblePoints = xyPoints(isFound, :);
        oldInliers = oldPoints(isFound, :);

        numPts = size(visiblePoints, 1);

        if numPts >= 50
            % Estimate the geometric transformation between the old points
            % and the new points
            [xform, oldInliers, visiblePoints] = estimateGeometricTransform(...
                oldInliers, visiblePoints, 'affine', 'MaxDistance', 4);
            trackingTrans.T = trackingTrans.T * xform.T;

            % Apply the transformation to the bounding box
            bboxPoints = transformPointsForward(xform, bboxPoints);

            % Convert the box corners into the [x1 y1 x2 y2 x3 y3 x4 y4]
            % format required by insertShape
%             bboxPolygon = reshape(bboxPoints', 1, []);

            % Display a bounding box around the face being tracked.
%             videoFrame = insertShape(videoFrame, 'Polygon', bboxPolygon, 'LineWidth', 3);

            % Display tracked points
%             videoFrame = insertMarker(videoFrame, visiblePoints, '+', 'Color', 'white');

            % Reset the points
            oldPoints = visiblePoints;
            setPoints(pointTracker, oldPoints);
        end

    end
    
    % Wrap and then blend the image to the video
    mickeyWrap = imwarp(mickey, trackingTrans, 'OutputView', outputView);
    mask = rgb2gray(mickeyWrap) > 0;
    videoFrame = step(alpha, videoFrame, mickeyWrap, mask);

    % Display the annotated video frame using the video player object
    step(videoPlayer, videoFrame);

    % Check whether the video player window has been closed
    runLoop = isOpen(videoPlayer);
end

% Clean up
clear cam;
release(videoPlayer);
release(pointTracker);
release(faceDetector);