%Usage
% Usage 1
%
% [sp] = mexGenerateSuperPixel(img, superpixelNum, [ compactness ], [ mask ]) calculate the super pixel for the masked 
%                                                            region, given the superpixelNum as the desired num
% img		         : an image
% superpixelNum          : a scalar
% compactness            : a scalar
% mask                   : an image indicating different super pixel regions
% 
% Usage 2
% [sp] = mexGenerateSuperPixel(img, superPixelNumArray[], [ compactnessArray[] ] ) calc the super pixel array
% for the given superpixelNumArray and compactnessArray.
% img                   : an image
% superPixelNumArray[]  : an array indicating each level
% compactnessArray[]    : an array indicating the compactness for each level
%
% Usage 3  !!!NOT IMPLEMENT YET
% [sp] = mexGenerateSuperPixel(img, [], superPixelPyNum, [ compactnessArray[] ]) calc the super pixel pyramid
%                                                                      given the pyramid num and each level
% img                   : an image
% superPixelPyNum       : a scalar, indicating the pyramid num
% compactnessArray      : an array indicating the compactness used in each level of pyramid
%
% Usage 4
% [sp, [trueNumForEachLabel[] ] ] = mexGenerateSuperPixel(img, [], mask, numForEachLabel, [ compactnessArray[] ]) calc the super pixel pyramid
%                                                                      given the pyramid num and each level
% img                   : an image
% mask                  : an image indicating different super pixel regions, 0 based
% numForEachLabel       : an array whose length is max(mask) + 1 indicating each segments num 
% compactnessArray[]    : length=max(mask) + 1 indicating each segments compatness
% trueNumForEachLabel[] : actual num of superpixels in each segments in mask

