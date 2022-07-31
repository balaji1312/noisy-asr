function [output_feature_matrix] = QCN_RASTALP(input_feature_matrix, percentile)

%[output] = QCN_RASTALP(input_feature_matrix, percentile)
%
%Percentile: real number in the range of 0-49.
%Reads input feature matrix (rows - frames, columns - cepstral dimensions), estimates low and high histogram quantiles for each cepstral dimension,
%subtracts quantile mean, normalizes dynamic range, and returns normalized features in a matrix
%
%QCN-RASTALP stages: 
%(i)   Reads cepstral vectors
%(ii)  For each cepstral dimension, sorts cepstral samples in ascending order
%(iii) Estimates low and high quantiles q_j, q_(100 - j) of cepstral distributions for each cepstral dimension by picking cepstral samples with indexes round(j*L/100) and round((100 - j)*L/100) from sorted samples.
%(iv)  Subtracts quantile means [q_j + q_(100 - j)]/2 from all samples (dimension-wise). Paramter j is defined by the constant PERCENTILE.
%(v)   Normalizes dynamics of cepstral samples by dividing mean-normalized samples by q_(100-j) - q_j (dimension-wise).
%(vi) Performs low-pass temporal filtering (RASTALP) in each cepstral dimension.
%
%(c) Hynek Boril, Center for Robust Speech Systems (CRSS), The University of Dallas at Dallas, 2013.

%-------- Constants -------------------------
filter_prebuffer_length = 20; % the input feature vector will be extended for this many samples at its beginning (first feature segment is copied N-times so the RASTALP filter can 'settle down'); these extra frames will be omitted from the output matrix

% RASTALP coeffs - assume 10 ms frame rate
B = [0.104078356756097, 0.208156713512194, 0.104078356756097];
A = [1.,               -0.903419042858346, 0.319732469882734];
%----------

number_of_frames = size(input_feature_matrix, 1);
feature_vector_length = size(input_feature_matrix, 2);  % Number of cepstral dimensions
vect_percentile_mean = zeros(1, feature_vector_length);
vect_low_percentile = zeros(1, feature_vector_length);
vect_high_percentile = zeros(1, feature_vector_length);

% ----------------- Find Percentiles ----------------------- 
low_percentile_index = round(number_of_frames*percentile/100);
high_percentile_index = round(number_of_frames*(1 - percentile/100)) - 1;
input_feature_matrix_sorted = sort(input_feature_matrix);
vect_low_percentile = input_feature_matrix_sorted(low_percentile_index + 1, :);
vect_high_percentile = input_feature_matrix_sorted(high_percentile_index + 1, :);
vect_percentile_mean = (vect_low_percentile + vect_high_percentile)/2;

% -------------- QCN ------------------
% Subtract percentile mean, divide by dynamic range

for cepstral_coeff_index = 0:feature_vector_length - 1,    % forums suggest this is prefereable to bsxfun(@minus, b, a) speed-wise
	input_feature_matrix(:, cepstral_coeff_index + 1) =  (input_feature_matrix(:, cepstral_coeff_index + 1) - vect_percentile_mean(cepstral_coeff_index + 1))/(vect_high_percentile(cepstral_coeff_index + 1) - vect_low_percentile(cepstral_coeff_index + 1));
end

% -------------- RASTALP ---------------
% Take the first feature frame and extend the beginning of the feature matrix for this frame repeated N-times - will 'prebuffer' the RASTALP filter; discard the first N frames of the RASTALP output

first_frame_vector = input_feature_matrix(1, :);
prebuffer_vector = repmat(first_frame_vector, filter_prebuffer_length, 1);
input_feature_matrix = [prebuffer_vector; input_feature_matrix];
output_feature_matrix = zeros(size(input_feature_matrix));
for cepstral_coeff_index = 0:feature_vector_length - 1,    
	output_feature_matrix(:, cepstral_coeff_index + 1) = filter(B, A, input_feature_matrix(:, cepstral_coeff_index + 1)')';
end
output_feature_matrix = output_feature_matrix(filter_prebuffer_length + 1:filter_prebuffer_length + number_of_frames, :);