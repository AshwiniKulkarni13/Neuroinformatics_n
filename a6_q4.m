clc;
load sampleEEGdata.mat;

eeg_data = EEG.data(32, :);
eeg_length = length(eeg_data);


kernel_size = 3;
inverted_u_kernel = [1; 2; 1]; 


chunk_size = 10000;


convolved_time_domain = zeros(size(eeg_data));


for i = 1:chunk_size:eeg_length
   
    chunk_data = eeg_data(i:min(i+chunk_size-1, eeg_length));
    
   
    padded_chunk_data = [zeros(1, kernel_size - 1), chunk_data, zeros(1, kernel_size - 1)];
    
   
    dtft_chunk_data = fft(padded_chunk_data);
    dtft_kernel = fft(inverted_u_kernel, length(padded_chunk_data));
    
    
    convolved_chunk = ifft(dtft_chunk_data .* dtft_kernel);
    
   
    convolved_chunk = convolved_chunk(kernel_size:end - kernel_size + 1);
    
   
    chunk_indices = i:min(i+length(chunk_data)+kernel_size-2, eeg_length);
    
    
    convolved_time_domain(chunk_indices) = convolved_chunk(1:length(chunk_indices));
end

% Plotting
figure;


subplot(3, 1, 1);
plot(eeg_data);
title('EEG Data');


subplot(3, 1, 2);
stem(inverted_u_kernel, 'filled');
title('Inverted U Kernel');


subplot(3, 1, 3);
plot(convolved_time_domain);
title('Convolution using DTFT and FFT');
