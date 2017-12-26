img  = imread('frame10.png');
mask = imread('mask.png');
sp  = mexGenerateSuperPixel(img, 50);

nums = ones(max(sp(:))+1, 1);
compact = ones(max(sp(:))+1, 1)*20;
% nums = zeros(max(sp(:))+1, 1);
nums(1) = 10;
nums(2) = 30;
tic
[sp5, numsInEachSeg]= mexGenerateSuperPixel(img, [], sp, nums, compact);
toc
segToImg(sp5);title('sp5');


sp2 = mexGenerateSuperPixel(img, 200, 10, mask);
spPyramid  = mexGenerateSuperPixel(img, [20, 100, 500]);
spPyramid2 = mexGenerateSuperPixel(img, [20, 100, 500], [10, 20, 30]);


% the returned label starts from 0
sp = sp+1;
sp2 = sp2+1;
spPyramid = spPyramid +1;
spPyramid2 = spPyramid2 +1;

segToImg(sp);
segToImg(sp2);

segToImg(spPyramid(:,:,1));
segToImg(spPyramid(:,:,2));
segToImg(spPyramid(:,:,3));

segToImg(spPyramid2(:,:,1));
segToImg(spPyramid2(:,:,2));
segToImg(spPyramid2(:,:,3));