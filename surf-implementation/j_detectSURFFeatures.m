function [points] = j_detectSURFFeatures(gray)
    
    Integral_Image = integralImage(gray);
    
    octaves = [1];% 2 3];
    filter_sizes = [ 9, 15, 21, 27 ;...
                    15, 27, 39, 51 ;...
                    27, 51, 75, 99 ];%, { 51, 99, 147, 195 }
    points = [0 0];
    for i = 1:length(octaves)
        octave_points =...
          detectOctavePoints(filter_sizes(i,:), Integral_Image);
        points = vertcat(points, octave_points);        
    end
    points = SURFPoints(points(2:100, :));
end