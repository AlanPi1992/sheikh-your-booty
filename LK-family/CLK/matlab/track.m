boxGT = [230,88,285,145]; % frame 1
image_prev = frames360(:,:,:,1);    

for i = 3 : length(frames360)  
    image_cur = frames360(:,:,:,i);    
    
    layerN = length(Rall);    
    for l = 1:layerN
        % crop out the warped frame
        %=====================================
        image = double(rgb2gray(image_cur));
        pMtrx = warpVec2Mtrx(params,pVec);
        % map to Im coordinate, perform warp, then map back to image coordinate
        % forward warping the box --> inverse warping the image
        transMtrx = params.Im2imageAffine*(pMtrx\params.image2ImAffine);
        % apply warp to image
        tform = projective2d(transMtrx');
        imageWarp = imwarp(image,tform,'cubic','outputview',params.imref2d);
        %=====================================
        
        feat = extractFeature(imageWarp,params);
        featVec = feat(:);
        % apply regression and try to warp back image
        dpVec = Rall{l}*[featVec;1];
        
        % update warp
        pVec = composeWarp(pVec,dpVec,params,true);
        
        % visualization
        if(visualize)
            warpHandle = visualizeWarp(image,pVec,params,warpHandle);        
            drawnow;
            if(params.visualizeTestPause) pause; end
        end        
    end
    
    drawnow;
    pause;
    disp(i);            
    
end

