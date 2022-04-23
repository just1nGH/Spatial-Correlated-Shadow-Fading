function sfm = genSfm2D(nPixelsX,nPixelsY,resol,decorrDist,meanSfv,stdDevSfv)
%% This function returns a one-dimensinal shadow fading map.
% @param nPixelsX: number of pixels in the horizental direction of the map
% @param nPixelsY: number of pixels in the vertical direction of the map
% @param resol: resolution of the map in meteres or meters per pixel
% @param decorrDist: the distance at which the PSD of the intended random
% process is reduced by half
% @param meanSfv: mean value of shadow fading corresponding the path loss
% at the location in dB
% @param stdDevSfv: standard derivation of shadow fading
% @return a 2-D space correlated shadowing fading map, nPixelsX-by-nPixelsY double

% @ References
% [1]Fraile,et al. "Mobile radio bi-dimensional large-scale fading modelling with site-to-site cross-correlation."
% [2]Dittrich, et al. "An efficient method for avoiding shadow fading maps in system level simulations." 
% [3]Vienna 5G System Level Simulator (https://www.nt.tuwien.ac.at/research/mobile-communications/vccs/vienna-5g-simulators/)

%% define auto-correlation function (acf) of the intended random process 
[distShiftX,distShiftY] = meshgrid( -nPixelsX:nPixelsX-1,-nPixelsY:nPixelsY-1);
distShift = sqrt((distShiftX.').^2 + (distShiftY.').^2);

acf = exp(- log(2)*distShift*resol/decorrDist);

%% compute PSD based on ACF of the random process
% shift to make it symmetry to guranteen the output of FFT is real in theory, 
% the outside real() function to avoid imperfection of numerical caculation
psd = real(fft2(fftshift(fftshift(acf,1),2))); 
psd(psd < 0 ) = 0; % guranteen that power spectrum density >= 0
psd = psd * (4* nPixelsX*nPixelsY)/ sum(psd(:)); % normlize it guanteen a unit fiter


%% Generate colored white gaussian in the frequency domain
% conjugate symetric about subcarrier N/2 to guranteen real values in the time (or space) domain.
ZLeft = sqrt(1/2)* complex(randn(2*nPixelsX,nPixelsY+1),randn(2*nPixelsX,nPixelsY+1));
ZRight = [ conj(ZLeft(1,nPixelsY:-1:2));conj(ZLeft(end:-1:2,nPixelsY:-1:2))];
whiteSfmFreq = [ZLeft,ZRight];

% replace (0,0),(0,nPixelsY),(nPixelsX,0),(nPixelsX,nPixelsY) with real
% values
whiteSfmFreq([1,1,nPixelsX+1,nPixelsX+1],[1,nPixelsY+1,1,nPixelsY+1]) = randn(4,4);

% make the first clonmn and middle colomn conj symetric
whiteSfmFreq(nPixelsX+2:end,1) = conj(whiteSfmFreq(nPixelsX:-1:2,1));
whiteSfmFreq(nPixelsX+2:end,nPixelsY+1) = conj(whiteSfmFreq(nPixelsX:-1:2,nPixelsY+1));



%% color it with the psd
sfmFreq =  sqrt(psd).* whiteSfmFreq;

%% Add euivalent std derivation in the frequency domin as E[Wx(Wx)^H] = 1/N
% E(xx^H), where W is IDFT matrix, N is DFT size
sfmFreq =  sqrt(4* nPixelsX*nPixelsY)*stdDevSfv*sfmFreq; 

%% Add equivalent MEAN in the frequency domain. 
% The mean(mu)in the time domain is equivalent to adding M*N*mu in the DC
% subcarrier. M*N is 2D-DFT size
sfmFreq(1,1) = sfmFreq(1,1) + (4* nPixelsX*nPixelsY)*meanSfv; 

%% perform inverse FFT to obtain time(space) domain random process
sfm = ifft2(sfmFreq);

sfm = sfm(1:nPixelsX,1:nPixelsY);

end

