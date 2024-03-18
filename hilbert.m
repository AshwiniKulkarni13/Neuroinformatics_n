clc
% Load EEG data
load sampleEEGdata

% Select electrode
chan2use = 'fcz';

% Frequency of interest
freq_of_interest = 10; % For example, 10 Hz

% Bandpass filter parameters
fs = EEG.srate; % Sampling frequency
low_freq = freq_of_interest - 1; % Example lower frequency bound
high_freq = freq_of_interest + 1; % Example upper frequency bound
filter_order = 4; % Example filter order

% Design the bandpass filter
[b, a] = butter(filter_order, [low_freq/(fs/2), high_freq/(fs/2)], 'bandpass');

% Select EEG data for the specified channel and convert to double
chanidx = strcmpi(chan2use, {EEG.chanlocs.labels});
eeg_data_chan = double(squeeze(EEG.data(chanidx,:,:))); % Convert to double

% Apply bandpass filter using filtfilt
filtered_eeg = filtfilt(b, a, eeg_data_chan);

% Compute the Hilbert transform
hilbert_transform = hilbert(filtered_eeg);

% Compute instantaneous power
instantaneous_power = abs(hilbert_transform).^2;

% Compute mean power across trials
mean_power_over_trials = mean(instantaneous_power, 2);

% Plotting
time_axis = EEG.times;
figure;
subplot(2,1,1);
imagesc(time_axis, 1:size(mean_power_over_trials, 1), mean_power_over_trials');
xlabel('Time (ms)');
ylabel('Trial');
title(sprintf('Instantaneous Power over Time at %s electrode, %d Hz', chan2use, freq_of_interest));
colorbar;

subplot(2,1,2);
plot(time_axis, mean_power_over_trials, 'b');
xlabel('Time (ms)');
ylabel('Mean Power');
title(sprintf('Mean Power over Time at %s electrode, %d Hz', chan2use, freq_of_interest));
