%% Set up camera
webcamlist;
cam = webcam;
%% Preview
preview(cam);

%% Loop
for idx = 1:100
   % Acquire a single image.
   rgbImage = snapshot(cam);

   % Convert RGB to grayscale.
   grayImage = rgb2gray(rgbImage);

   % Find circles.
   [centers, radii] = imfindcircles(grayImage, [60 80]);

   % Display the image.
   imshow(rgbImage);
   hold on;
   viscircles(centers, radii);
   drawnow
end


%% Quit
clear('cam');
