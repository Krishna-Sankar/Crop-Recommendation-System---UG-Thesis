clc;
clear all;
close all;

addpath('./Dataset')
addpath('./BTC')

% ---- options ------
determineM = 0; %uses already determined threshold parameter
%determineM = 1; %determines the best threshold

spectralOnly = 1; % spectral only classification with BTC
%spectralOnly = 0; %spatial - spectral classification (BTC-WLS)

%Note: for BTC-WLS, please donwload wlsFilter from http://www.cs.huji.ac.il/~danix/epd/


trainPercent = 10; %percentage of randomly selected train samples

M = 100; %threshold parameter

if spectralOnly == 1
    alpha = 1e-4; %optimum alpha in order to prevent ill-condioned matrix inverse
else
    alpha = 1e-10; %small alpha in order to prevent ill-condioned matrix inverse
end

imageName = 'IndianPines';



img = importdata([imageName,'.mat']);

GroundT = importdata([imageName,'_groundT.mat']);
no_classes = max(GroundT(:,2));

%%%% estimate the size of the input image
[no_lines, no_rows, no_bands] = size(img);

%%%% vectorization
img = ToVector(img);
img = img';

GroundT=GroundT';

%%%% construct training and test datasets

[indexes] = generateTrainIndexes(GroundT, trainPercent);



%%% get the training-test indexes
trainIndexes = GroundT(1,indexes);
trainLabels = GroundT(2,indexes);
groundIndexes = GroundT(1,:);
groundLabels = GroundT(2,:);
testIndexes = groundIndexes;
testLabels = groundLabels;
testIndexes(indexes) = [];
testLabels(indexes) = [];

%%% get the training-test samples
trainSamples = img(:, trainIndexes)';

testSamples = img(:, testIndexes)';



numLabel = [];
numTestLabel = [];
for jj =1 : no_classes
    numLabel = [numLabel; length(find(trainLabels==jj))];
    numTestLabel = [numTestLabel; length(find(testLabels==jj))];
end
disp(numLabel)
disp(numTestLabel)


img = img';
trainSamples = trainSamples';

trainSamples = normcol(trainSamples);

if determineM == 1
    disp('please wait ...')
    [avgBeta, bestM] = averageBeta(trainLabels, trainSamples, alpha);
    figure;
    plot(avgBeta);
    disp(bestM)
end

%%% BTC Classification
tic;
[BTCresult, errMatrix] = fxBtc(trainLabels, trainSamples, img', M, alpha);

elapsedTime =toc;
disp(['time = ',num2str(elapsedTime)]);


% evaluate the results
[BTCOA,BTCAA,BTCkappa,BTCCA]=confusion(testLabels, BTCresult(testIndexes)');
sprintf('%0.2f\n',BTCCA*100)
disp(['BTC OA = ',num2str(BTCOA*100),' AA = ',num2str(BTCAA*100),' K = ',num2str(BTCkappa*100)])


% display results of BTC
showMap(no_lines, no_rows, groundIndexes, BTCresult(groundIndexes), imageName);

mask = zeros(size(BTCresult));
mask(groundIndexes)=1;
BTCresult = mask.*BTCresult;
BTCresult = reshape(BTCresult,no_lines,no_rows);

if spectralOnly == 0
    
    % filter the results
    tic
    lambda = 0.4;  alphax = 0.9;
    EPFresult = BtcWls(img, BTCresult, errMatrix', lambda, alphax);
    toc;
    
    % display results after filtering
    EPFresult =reshape(EPFresult,[no_rows*no_lines 1]);
    [OA,AA,kappa,CA]=confusion(testLabels, EPFresult(testIndexes)');
    sprintf('%0.2f\n',CA*100)
    disp(['OA = ',num2str(OA*100),' AA = ',num2str(AA*100),' K = ',num2str(kappa*100)])
    
    % show filtered result map
    showMap(no_lines, no_rows, groundIndexes, EPFresult(groundIndexes), imageName);
    
    % show ground
    showMap(no_lines, no_rows, groundIndexes, groundLabels, imageName);
    
    % show train samples
    showMap(no_lines, no_rows, trainIndexes, trainLabels, imageName);
    
end
