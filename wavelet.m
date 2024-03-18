clc
% Load EEG data
load sampleEEGdata

% Select electrode
chan2use = 'fcz';

% Frequency of interest
freq_of_interest = 10; % For example, 10 Hz

% Wavelet parameters
time = -1:1/EEG.srate:1;
s = 7 / (2*pi*freq_of_interest); % Choose "7" for the number of wavelet cycles

% Wavelet and data sizes
n_wavelet = length(time);
n_data = EEG.pnts * EEG.trials;
n_convolution = n_wavelet + n_data - 1;
n_conv_pow2 = pow2(nextpow2(n_convolution));
half_of_wavelet_size = (n_wavelet - 1) / 2;

% Get FFT of the data for the selected channel
chanidx = strcmpi(chan2use, {EEG.chanlocs.labels});
eegfft = fft(reshape(EEG.data(chanidx,:,:), 1, EEG.pnts*EEG.trials), n_conv_pow2);

% Create the wavelet
wavelet = fft(sqrt(1/(s*sqrt(pi))) .* exp(2*1i*pi*freq_of_interest*time) .* exp(-time.^2./(2*s^2)), n_conv_pow2);

% Perform convolution
eegconv = ifft(wavelet.*eegfft);
eegconv = eegconv(1:n_convolution);
eegconv = eegconv(half_of_wavelet_size+1:end-half_of_wavelet_size);

% Reshape and compute power
eegpower_time = abs(reshape(eegconv, EEG.pnts, EEG.trials)).^2;
mean_power = mean(eegpower_time, 2);


figure
subplot(211)
plot(EEG.times, eegpower_time);
xlabel('Time (ms)');
ylabel('Power (dB)');
title(sprintf('Power over time at %s electrode, %d Hz', chan2use, freq_of_interest));
xlim([EEG.times(1), EEG.times(end)]);

subplot(212)
plot(EEG.times, mean_power);
xlabel('Time (ms)');
ylabel('Power (uV^2)'); % Adjust the unit based on your data
title(sprintf('Trial-Averaged Power at %d Hz for Electrode %s', freq_of_interest, chan2use));
xlim([EEG.times(1), EEG.times(end)]); % Adjust the x-axis limits to the EEG time range
