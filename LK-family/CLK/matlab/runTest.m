%% read files
imageAll{1} = double(frames(:,:,2));
boxGTall{1} = [230,88,285,145];
% track one image
image = imageAll{1};
boxGT = boxGTall{1};

%% set parameters
params = setParams(imageAll,boxGT);

%% generate a random warp
while(true)
    pVec = genNoiseWarp(params);
    % make sure perturbed box doesn't fall out of image
    if(checkGoodPerturbedBox(params,pVec,image)) break; end
end

%% run the regressors
assert(params.pDim == size(Rall{1},1),'warp dimension mismatch.....');
[pVecAll,~] = performRegression(params,image,pVec,Rall,true);
