%load('../images/frames100.mat');
boxGTall{1} = [230,88,285,145];
boxGT = boxGTall{1};
pVec = boxGT;

for i = 1 : length(frames100)  
    imageAll{1} = frames100(:,:,:,i);
    params = setParams(imageAll,boxGT); 
    
    while(true)
    pVec = genNoiseWarp(params);
    % make sure perturbed box doesn't fall out of image
    if(checkGoodPerturbedBox(params,pVec,image)) break; end
    end
    
    assert(params.pDim == size(Rall{1},1),'warp dimension mismatch.....');
    [pVecAll,~] = performRegression(params,image,pVec,Rall,true);
    
    %imshow(frames100(:,:,:,i));
    drawnow;
    pause;
    disp(i);            
    
end
