function [ClassMap] = BtcWls(img, ClassMap, errorMatrix, lambda, alpha)

[r, c]=size(ClassMap);
bands=size(img,2);
img=reshape(img,[r,c,bands]);
numClasses = size(errorMatrix, 2);
errorCube = reshape(errorMatrix,[r,c,numClasses]);

[guidanceImage] = ApplyPca(img, 1);

figure;
imshow(guidanceImage);

mx = max(max(max(errorCube)));
mn = min(min(min(errorCube)));

errorCube = (errorCube - mn)./(mx - mn);

for i=1:numClasses
    slice = errorCube(:,:,i); 
    slice(ClassMap ~=i) = 1;

    slice = wlsFilter(slice, lambda, alpha, guidanceImage);
    
    errorCube(:,:,i) = slice;
end


[~, ClassMap] = min(errorCube,[],3);


end