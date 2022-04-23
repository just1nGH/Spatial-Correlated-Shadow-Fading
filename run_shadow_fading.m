close all;
clear all;
addpath('./Functions');


nPixelsX = 64;
nPixelsY = 64;
resol = 1;
decorrDist = 5;
meanSfv = 2;
stdDevSfv = 6;

smf = genSfm2D(nPixelsX,nPixelsY,resol,decorrDist,meanSfv,stdDevSfv);
imagesc(smf);

% validate mean and variance through monta-calo simulation
nRels = 1000;
simMean = 0;
simStdDev = 0;
for i = 1: nRels
    smf = genSfm2D(nPixelsX,nPixelsY,resol,decorrDist,meanSfv,stdDevSfv);
    simMean = simMean + mean(smf(:))/nRels;
    simStdDev = simStdDev + sqrt(var(smf(:)))/nRels;
end

fprintf('real mean: %d, simulated mean: %.2f \n',meanSfv,simMean );
fprintf('real std dev: %d, simulated std dev: %.2f \n',stdDevSfv,simStdDev );

