clc;
load sampleEEGdata.mat;

eeg_data = EEG.data(32, :);
eeg_length = length(eeg_data);

% Define the convolution kernel
kernel_size = 3;
inverted_u_kernel = [1; 2; 1]; % Inverted U kernel

% Define the chunk size
chunk_size = 10000;

% Initialize array to store the convolution result
convolved_time_domain = zeros(size(eeg_data));

% Perform convolution in chunks
for i = 1:chunk_size:eeg_length
    % Get the chunk of EEG data
    chunk_data = eeg_data(i:min(i+chunk_size-1, eeg_length));
    
    % Zero pad the chunk to accommodate the kernel
    padded_chunk_data = [zeros(1, kernel_size - 1), chunk_data, zeros(1, kernel_size - 1)];
    
    % Compute the DTFT of the chunk of EEG data and the kernel
    dtft_chunk_data = fft(padded_chunk_data);
    dtft_kernel = fft(inverted_u_kernel, length(padded_chunk_data));
    
    % Perform convolution in the frequency domain
    convolved_chunk = ifft(dtft_chunk_data .* dtft_kernel);
    
    % Clip the edges to match the original EEG data length
    convolved_chunk = convolved_chunk(kernel_size:end - kernel_size + 1);
    
    % Determine the indices to assign the chunk to
    chunk_indices = i:min(i+length(chunk_data)+kernel_size-2, eeg_length);
    
    % Update the convolution result array
    convolved_time_domain(chunk_indices) = convolved_chunk(1:length(chunk_indices));
end

% Plotting
figure;

% Plot the EEG data
subplot(3, 1, 1);
plot(eeg_data);
title('EEG Data');

% Plot the Inverted U kernel
subplot(3, 1, 2);
stem(inverted_u_kernel, 'filled');
title('Inverted U Kernel');

% Plot the result of convolution
subplot(3, 1, 3);
plot(convolved_time_domain);
title('Convolution using DTFT and FFT');