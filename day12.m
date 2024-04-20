clc
clear all
% Load the dataset
load('sampleEEGdata.mat')

% Select three electrode channels
electrode_channels = [1, 15, 32];

%% Part-a

% Select five time-points
time_points = [100, 200, 300, 400, 500];

% Get the data for the selected electrodes and time-points
data_subset = EEG.data(electrode_channels, time_points, :);

% Calculate the phase angles
phase_angles = angle(data_subset);

% Create a figure with subplots
figure;

for i = 1:numel(electrode_channels)
    for j = 1:numel(time_points)
        subplot(numel(electrode_channels), numel(time_points), (i-1)*numel(time_points)+j)
        
        % Plot the distribution of phases for the current electrode and time-point
        histogram(phase_angles(i, j, :), 36, 'Normalization', 'pdf')
        title(sprintf('Electrode %d, Time %d ms', electrode_channels(i), EEG.times(time_points(j))))
    end
end

%% Part-b

% Define frequency limits
freqlim = [2 50];  % Change as needed
frequencies = freqlim(1):freqlim(end);

% Loop over the selected electrodes
for i = 1:numel(electrode_channels)
    % Extract the data for the current electrode
    data = squeeze(EEG.data(electrode_channels(i), :, :));
    
    % Compute time-frequency decomposition
    itpc = zeros(length(frequencies), EEG.pnts);
    pow = zeros(length(frequencies), EEG.pnts);
    for f = 1:length(frequencies)
        % Normalize the cutoff frequencies
        wn = frequencies(f) / (EEG.srate/2);
        
        % Bandpass filter the data
        [b, a] = butter(4, [wn - (1/EEG.srate), wn + (1/EEG.srate)], 'bandpass');
        filtered_data = filter(b, a, data')';
        
        % Compute the Hilbert transform for each trial
        hilbert_data = zeros(size(filtered_data));
        for t = 1:EEG.trials
            hilbert_data(:, t) = hilbert(filtered_data(:, t));
        end
        
        % Compute ITPC and power
        itpc(f, :) = abs(mean(exp(1j * angle(hilbert_data)), 2));
        pow(f, :) = 10 * log10(mean(abs(hilbert_data).^2, 2));
    end
    
    % Create a figure for the current electrode
    figure;
    
    % Plot ITPC
    subplot(1, 2, 1)
    contourf(EEG.times, frequencies, itpc, 40, 'linecolor', 'none')
    set(gca, 'YDir', 'normal')
    title(sprintf('ITPC for Electrode %d', electrode_channels(i)))
    xlabel('Time (s)')
    ylabel('Frequency (Hz)')
    colorbar
    
    % Plot power
    subplot(1, 2, 2)
    contourf(EEG.times, frequencies, pow, 40, 'linecolor', 'none')
    set(gca, 'YDir', 'normal')
    title(sprintf('Power for Electrode %d', electrode_channels(i)))
    xlabel('Time (s)')
    ylabel('Frequency (Hz)')
    colorbar
end