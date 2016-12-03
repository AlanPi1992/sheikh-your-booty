function [points] = detectOctavePoints(filter_sizes, I)

    pyr = generatePyramid(filter_sizes, I);
%     temp = pyr(:,:,1);
%     temp = temp/max(max(temp));
%     imshow(temp);
    regmax = imregionalmax(pyr);
    %imshow(regmax(:,:,1));
%     imshow(regmax(:,:,2));
    [row, col] = find(regmax);
    points = horzcat(row,col);
    
    

end