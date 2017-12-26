#include <mex.h>
#include "SLICMask.h"
#include <assert.h>
#include <set>
#include <omp.h>

// corresponding usage 1
void mexGenerateSuperPixelUsage1(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
    

    enum INPUT  {IMG=0, SPNUM, COMPACTNESS, MASK};
    enum OUTPUT {LABELS=0};

    typedef double CommonCImgType;

    CImg<CommonCImgType> image;
    int          spNum;
    double       compactness = 10.0;
    CImg<unsigned> maskImg;

    // make sure the input image is in the range [0,255]
    if(mexCheckType<uint8>( prhs[IMG] )){
        image = CImg<CommonCImgType>(prhs[IMG], true);
    } else if (mexCheckType<double>( prhs[IMG] )) {
        image = CImg<CommonCImgType>(prhs[IMG], true) * 255;
    }

    spNum  = (int)mxGetScalar( prhs[SPNUM] );
    if ( nrhs >= 3 )
        compactness = mxGetScalar( prhs[COMPACTNESS] );
    if ( nrhs == 4 ) 
        maskImg     = CImg<unsigned>(prhs[MASK], true);

    int width  = image.width();
    int height = image.height();
    int* labels = new int[width*height];
    CImg<uint> imgBits = loadMatImgBits<CommonCImgType , uint>(image);

    // check the validility
    if (nrhs == 4) {
        if (maskImg.spectrum()!=1)
            mexErrMsgTxt("The input mask must be single channel!");
        if (maskImg.width() != width ||
            maskImg.height()!= height)
            mexErrMsgTxt("Size of mask must be agree with the original image!");
    }

    int numLabels(0);
    SLICMask slicMask;
    slicMask.SetMask(maskImg);

    slicMask.DoSuperpixelSegmentation_ForGivenNumberOfSuperpixels(imgBits._data, width, height, labels, numLabels, spNum, compactness);
    
    mxArray* lbs  = vec2MxArray(labels, height, width);
    plhs[LABELS] = lbs;

    delete[] labels;
}

// corresponding usage 2
void mexGenerateSuperPixelUsage2(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
    enum INPUT  {IMG=0, NUMARRAY, COMPACTARRAY};
    enum OUTPUT {LABELS=0};
    typedef double CommonCImgType;

    CImg<CommonCImgType> image;
    double*              pyNumArray;
    double*              compactnessArray;
    int                  numOfPy;

    // make sure the input image is in the range [0,255]
    if(mexCheckType<uint8>( prhs[IMG] )){
        image = CImg<CommonCImgType>(prhs[IMG], true);
    } else if (mexCheckType<double>( prhs[IMG] )) {
        image = CImg<CommonCImgType>(prhs[IMG], true) * 255;
    }

    pyNumArray  = mxGetPr( prhs[NUMARRAY] );
    numOfPy     = (int)mxGetNumberOfElements( prhs[NUMARRAY] );
    assert(numOfPy > 0);

    if ( nrhs == 3 )
        compactnessArray = mxGetPr( prhs[COMPACTARRAY] );
    else{

        // not provide the compactnessArray, initial it
        compactnessArray = new double[numOfPy];
        for (int i = 0; i < numOfPy; i++) {
            compactnessArray[i] = 10.0;
        }
    }

    int width  = image.width();
    int height = image.height();
    int* labels = new int[width*height*numOfPy];
    CImg<uint> imgBits = loadMatImgBits<CommonCImgType , uint>(image);

    int numLabels(0);
    SLICMask slicMask;

    slicMask.GenerateSuperpixelPyramid(imgBits._data, width, height, labels, numLabels, pyNumArray, compactnessArray, numOfPy);

    mxArray* lbs  = vec2MxArray(labels, height, width, numOfPy);
    plhs[LABELS] = lbs;

    delete[] labels;
    
    if (nrhs < 3) {
        delete[] compactnessArray;
    }
}

// corresponding usage 3
void mexGenerateSuperPixelUsage3(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
    enum INPUT  {IMG=0, DUMMY, PYNUM, COMPACTNESS};
    enum OUTPUT {LABELS=0};
}

// corresponding usage 4
void mexGenerateSuperPixelUsage4(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
    enum INPUT  {IMG=0, DUMMY, MASK, NUMFOREACHLABEL, COMPATNESSARRAY};
    enum OUTPUT {LABELS=0, TRUENUMOFLABELS};

    typedef double CommonCImgType;
    CImg<CommonCImgType> image(prhs[IMG]);
    CImg<uint> maskImg(prhs[MASK]);
    CImg<CommonCImgType> spNumsForSeg(prhs[NUMFOREACHLABEL]);
    double *compactnessArray = 0;

    
    int totalSpNum = static_cast<int>(maskImg.max() + 1);
    int width  = image.width();
    int height = image.height();

    CImg<uint> imgBits = loadMatImgBits<CommonCImgType , uint>(image);

    if(nrhs == 5)
        compactnessArray = mxGetPr(prhs[COMPATNESSARRAY]);
    else {
        compactnessArray = new double[totalSpNum];
        for (int i = 0; i < totalSpNum; i++) compactnessArray[i]=10.0;
    }

    if (spNumsForSeg.width()*spNumsForSeg.height() != totalSpNum)
        mexErrMsgTxt("spNum != maskImg.max() + 1");
    if (maskImg.spectrum()!=1)
        mexErrMsgTxt("The input mask must be single channel!");
    if (maskImg.width() != width || maskImg.height()!= height)
        mexErrMsgTxt("Size of mask must be agree with the original image!");

    int numLabels(0);
    int labelNum = 0;


    int* finalLabels = new int[width*height];
    memset(finalLabels, 0xFF, sizeof(int)*width*height);

    int maxSize = width*height;
    
    
#pragma omp parallel for num_threads(8)
    for (int i = 0; i < totalSpNum; i++) {
        if (spNumsForSeg(i) > 1) {
            double spNumForThisSeg = spNumsForSeg(i);
            
            int* labels = new int[width*height];
            memset(labels, 0, sizeof(int)*width*height);

            // m is the binary valued mask than indicating the region we are interested in
            CImg<uint> m(width, height, 1, 1, 0);

            for (int t = 0; t < width*height; t++) {
                m(t) = maskImg(t) == i;
            }

            int* tmp = new int[maxSize];
            memset(tmp, 0xFF, sizeof(int)*maxSize);

            double area = m.sum();
            int spNumForWholeImg = int(spNumForThisSeg*width*height/area);
            SLICMask slicMask;
            slicMask.SetMask(m);
            slicMask.DoSuperpixelSegmentation_ForGivenNumberOfSuperpixels(imgBits._data, width, height, labels, numLabels, spNumForWholeImg, compactnessArray[i]);
            
            for (int s = 0; s < width*height; s++) {
                if (m[s]) {
                    if (tmp[labels[s]] == -1)
                        tmp[labels[s]] = labelNum++;
                    
                    finalLabels[s] = tmp[labels[s]];
                }
            }
            
            delete[] tmp;
            delete[] labels;
        }
    }

    int* tmp = new int[maxSize];
    memset(tmp, 0xFF, sizeof(int)*maxSize);
    for (int s = 0; s < width*height; s++)
        if(finalLabels[s] == -1) {
            if (tmp[maskImg(s)] == -1) {
                tmp[maskImg(s)] = labelNum++;
            }
            finalLabels[s] = tmp[maskImg(s)];
        }
    delete[] tmp;

    mxArray* outputLabel = vec2MxArray(finalLabels, height, width);

    plhs[LABELS] = outputLabel;
    if (nlhs == 2) {
        int *nums = new int[totalSpNum];
        
        SLICMask slicMask;
        slicMask.SetMask(maskImg);
        slicMask.GetLabelNumsInEachSeg(finalLabels, nums);
        mxArray* outputNums = vec2MxArray(nums, totalSpNum, 1);
        plhs[TRUENUMOFLABELS] = outputNums;
        delete[] nums;
    }

    if (nrhs < COMPATNESSARRAY + 1) delete[] compactnessArray;
}


//Usage:
// Usage 1:
//
// mexGenerateSuperPixel(img, superpixelNum, [ compactness ], [ mask ]): calculate the super pixel for the masked 
//                                                            region, given the superpixelNum as the desired num
// img          : an image
// superpixelNum: a scalar
// compactness  : a scalar
// mask         : an image indicating different super pixel regions
// 
// Usage 2:
// mexGenerateSuperPixel(img, superPixelNumArray[], [ compactnessArray[] ] ): calc the super pixel array
// for the given superpixelNumArray and compactnessArray.
// img                  : an image
// superPixelNumArray[] : an array indicating each level
// compactnessArray[]   : an array indicating the compactness for each level
//
// Usage 3:
// mexGenerateSuperPixel(img, [], superPixelPyNum, [ compactnessArray[] ]): calc the super pixel pyramid
//                                                                      given the pyramid num and each level
// img                  : an image
// superPixelPyNum      : a scalar, indicating the pyramid num
// compactnessArray     : an array indicating the compactness used in each level of pyramid
//
// Usage 4:
// mexGenerateSuperPixel(img, [], mask, numForEachLabel, [ compactnessArray[] ]): calc the super pixel pyramid
//                                                                      given the pyramid num and each level
// img                  : an image
// mask                 : an image indicating different super pixel regions, 0 based
// numForEachLabel      : an array whose length is max(mask) + 1 indicating each segments num 
// compactnessArray[]   : length=max(mask) + 1 indicating each segments compatness
//
// Output: 
// the super pixels.
//
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
        typedef unsigned char uchar;
        typedef unsigned int  uint;
        
        enum {SECONDINPUT = 1, THIRDINPUT};
        
        if (nrhs < 2 ) {
            
            mexErrMsgTxt("Not enough input!");

        } else if (nrhs > 5) {
            
            mexErrMsgTxt("Two much input!");

        } else if ( mxIsEmpty( prhs[SECONDINPUT] ) ) {  // belongs to the 3rd usage
            
            if (mxGetNumberOfElements(prhs[THIRDINPUT]) == 1)
                mexGenerateSuperPixelUsage3(nlhs, plhs, nrhs, prhs);
            else
                mexGenerateSuperPixelUsage4(nlhs, plhs, nrhs, prhs);

        } else if ( mxGetNumberOfElements(prhs[SECONDINPUT])!= 1 ) { // belongs to the 2nd usage
            
            mexGenerateSuperPixelUsage2(nlhs, plhs, nrhs, prhs);

        } else { // belongs to the 1st usage

            mexGenerateSuperPixelUsage1(nlhs, plhs, nrhs, prhs);

        }
}
