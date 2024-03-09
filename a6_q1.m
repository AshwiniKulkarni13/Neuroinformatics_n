clc
kernel_size = 7;
mid_point = (kernel_size + 1) / 2;
inverted_u = zeros(kernel_size);
inverted_u(1:mid_point, :) = 1;
inverted_u(:, mid_point) = 1;

inverted_u = inverted_u/sum(inverted_u(:));

[X,Y] = meshgrid(1:kernel_size, 1:kernel_size);
distance = sqrt((X- mid_point).^2+ (Y - mid_point).^2);
decay_kernel = 1./(1+distance);

decay_kernel = decay_kernel / sum(decay_kernel(:));

% Display the kernels
disp("Inverted U kernel:");
disp(inverted_u);
disp("Decay function kernel:");
disp(decay_kernel);



