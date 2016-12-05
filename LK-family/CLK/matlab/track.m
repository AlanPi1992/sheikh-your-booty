boxGT = [230,88,285,145]; % frame 1
image_prev = frames360(:,:,:,1);    
W = params.ImW;
H = params.ImH;
ImBox = [-W/2,-W/2,W/2,W/2,-W/2;
         -H/2,H/2,H/2,-H/2,-H/2];
ImBox = [ImBox;[1,1,1,1,1]];

for i = 1 : 360
    image_cur = frames(:,:,:,i);    
    params = setParams({frames360(:,:,:,i)}, boxGT);
    
    layerN = length(Rall);    
    for l = 1:layerN
        % crop out the warped frame
        %=====================================
        imageWarp = double(image_cur);        
        %=====================================
        
        feat = extractFeature(imageWarp,params);
        featVec = feat(:);
        % apply regression and try to warp back image (use pre-trained model)
        dpVec = Rall{l}*[featVec;1];
        dpMtrx = warpVec2Mtrx(params,dpVec);
        
        % update warp
        %pVec = composeWarp(pVec,dpVec,params,true);
        
        % visualization
    
        %warpImBox = dpMtrx\ImBox;
        warpImBox = inv(dpMtrx)*ImBox;
        warpImBox(1,:) = warpImBox(1,:)./warpImBox(3,:);
        warpImBox(2,:) = warpImBox(2,:)./warpImBox(3,:);
        warpImBox(3,:) = 1;
         
        Imbox = warpImBox;
        
        warpImageBox = params.Im2imageAffine*warpImBox;
        
        imageBox = params.Im2imageAffine*ImBox;
        imageBox(3,:) = [];
        
        boxGT = [min(imageBox(1,:)), min(imageBox(2,:)), max(imageBox(1,:)), max(imageBox(2,:))];
        
        warpHandle = [];
        % plot the box
        if(isempty(warpHandle))
            % create new plot
            figure(1),imshow(uint8(image_cur)); hold on;
            %plot(imageBox(1,:),imageBox(2,:),'color',[1,0.3,0.3],'linewidth',4);
            warpHandle = plot(warpImageBox(1,:),warpImageBox(2,:),'color',[0.3,1,0.3],'linewidth',2);
        else
            % just update the warped box
            set(warpHandle,'XData',warpImageBox(1,:));
            set(warpHandle,'YData',warpImageBox(2,:));
        end
        drawnow;
    end

    pause;
    disp(i);            
    
end

