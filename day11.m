clc
clear all
% Load the EEG data
load('sampleEEGdata.mat');

% Define parameters
electrode_index = 5; % Index of the electrode you want to analyze
freq_range = [2, 30]; % Frequency range in Hz
num_freqs = 8; % Number of frequencies
num_trials = size(EEG.data, 3); % Number of trials

% Generate linearly spaced frequencies
frequencies = linspace(freq_range(1), freq_range(2), num_freqs);

% Sampling frequency
fs = EEG.srate; % Sampling rate in Hz

% Compute power using the Hilbert transform for each frequency
power_matrix = zeros(num_freqs, length(EEG.times), num_trials);

for freq_idx = 1:num_freqs
    % Compute the analytic signal using Hilbert transform for each trial
    for trial = 1:num_trials
        % Compute analytic signal using Hilbert transform
        analytic_signal = hilbert(squeeze(EEG.data(electrode_index, :, trial)));
        
        % Compute phase angle of the analytic signal
        phase_angle = angle(analytic_signal);
        
        % Compute instantaneous frequency as the derivative of the phase angle with respect to time
        instantaneous_frequency = (diff(unwrap(phase_angle)) / (2 * pi)) * fs;
        
        % Compute power at the selected frequency
        [~, nearest_index] = min(abs(instantaneous_frequency - frequencies(freq_idx)));
        
        % Ensure nearest_index is within valid range
        nearest_index = max(min(nearest_index, length(analytic_signal)), 1);
        
        % Compute power at the selected frequency
        power_matrix(freq_idx, :, trial) = abs(analytic_signal(nearest_index)).^2;
    end
end

% Average power across trials
mean_power = mean(power_matrix, 3);

% Plot the average power over time for each frequency
figure;
for freq_idx = 1:num_freqs
    subplot(ceil(num_freqs/2), 2, freq_idx);
    plot(EEG.times, mean_power(freq_idx, :));
    xlabel('Time (ms)');
    ylabel('Power');
    title(['Frequency: ' num2str(frequencies(freq_idx)) ' Hz']);
end

% Define baseline interval
baseline_start = -200; % Baseline start time in ms
baseline_end = 0; % Baseline end time in ms

% Convert baseline interval to indices
baseline_start_idx = find(EEG.times == baseline_start);
baseline_end_idx = find(EEG.times == baseline_end);

% Initialize arrays for baseline-normalized powers
baseline_normalized_Z = zeros(num_freqs, length(EEG.times), num_trials);
baseline_normalized_decibel = zeros(num_freqs, length(EEG.times), num_trials);

% Compute Z-transform and Decibel scaling
for freq_idx = 1:num_freqs
    for trial = 1:num_trials
        % Extract power for the current frequency and trial
        power_trial = power_matrix(freq_idx, :, trial);
        
        % Compute mean and standard deviation for the baseline interval
        baseline_mean = mean(power_trial(baseline_start_idx:baseline_end_idx));
        baseline_std = std(power_trial(baseline_start_idx:baseline_end_idx));
        
        % Z-transform
        baseline_normalized_Z(freq_idx, :, trial) = (power_trial - baseline_mean) / baseline_std;
        
        % Decibel scaling
        baseline_normalized_decibel(freq_idx, :, trial) = 10 * log10(power_trial);
    end
end

% Trial-averaged baseline-normalized powers
mean_baseline_normalized_Z = mean(baseline_normalized_Z, 3);
mean_baseline_normalized_decibel = mean(baseline_normalized_decibel, 3);

% Prepare topo-plots for specified time points
time_points = [-200, 150, 300, 600, 800]; % Time points in ms

% Convert time points to indices
time_point_indices = zeros(size(time_points));
for i = 1:length(time_points)
    [~, time_point_indices(i)] = min(abs(EEG.times - time_points(i)));
end

% Plot topo-plots for baseline-normalized powers and raw power
figure;
for i = 1:length(time_points)
    subplot(2, length(time_points), i);
    topoplot(mean_baseline_normalized_Z(:, time_point_indices(i)), EEG.chanlocs, 'maplimits', 'absmax');
    colorbar;
    title(['Z-transform: ' num2str(time_points(i)) ' ms']);
    
    subplot(2, length(time_points), length(time_points) + i);
    topoplot(mean_baseline_normalized_decibel(:, time_point_indices(i)), EEG.chanlocs, 'maplimits', 'absmax');
    colorbar;
    title(['Decibel scaling: ' num2str(time_points(i)) ' ms']);
end
