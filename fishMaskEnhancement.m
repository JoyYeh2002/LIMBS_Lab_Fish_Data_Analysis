% Joy Yeh Eigen Luminance Tail Motion Analysis
% Helper: fishMaskEnhancement.m
%
% After getting pre_tracking_y.csv with segmentSkeleton(), we create a
% grayscale mask that radiates from bright to dark, originating from the
% fish centerline
%
% 1) Load related .csv and .mat files
% 2) Create binary mask polygon and the gradient gray value mask
% 3) Multiply the mask with the frame image
% 4) Contrast enhancement with imadjust()
% 5) Save the new video in the data folder
%
% [04/17] Runtime: 6.8s
% [04/30] Without GPU: 14.8s??

function fishMaskEnhancement(this_fish_dir)
close all;

tic;

% Load files
filename = ['..\data\',this_fish_dir, 'pre_tracking_body.mat'];
load(filename, 'v', 'x_outputs', 'all_outputs');

% Create a VideoWriter
vid_filename = ['..\data\', this_fish_dir, 'vid_enhanced.avi'];
vOut = VideoWriter(vid_filename);
vOut.FrameRate = 25;
open(vOut);

% Loop through frames
for frame_num = 1 : v.NumFrames
    x = x_outputs; 
    y = all_outputs(frame_num, :); % The anchor y coords of this frame
    
    % Set the distance for top and bottom y ranges
    d = [12, 19, 9, 9, 7, 7, 7, 7, 8];
    y_top = y - d;
    y_bottom = y + d;
    
    % Create the binary mask
    anchor_head_x = 180;
    anchor_head_y = 110;
    anchor_tail_x = 550;
    x_interpolate_shift_amount = 70;
    
    % Perform linear regression 
    if abs(y(end) - y(end-1)) < 40 % If tail tracking is correct
        tail_fit = polyfit(x(end-4:end), y(end-4:end), 1);
    else % If tail outlier
        tail_fit = polyfit(x(end-4:end-1), y(end-4:end-1), 1);
    end

    % Calculate fitted y coordinates
    anchor_tail_y01 = round(polyval(tail_fit, anchor_tail_x - x_interpolate_shift_amount));
    anchor_tail_y02 = round(polyval(tail_fit, anchor_tail_x)); 
    
    % Create masks accordingly
    if abs(y(end) - y(end-1)) < 40
        outline_x = [x, anchor_tail_x, fliplr(x), anchor_head_x];
        outline_y = [y_top, anchor_tail_y02, fliplr(y_bottom), anchor_head_y];
    else % If tail outlier
        outline_x = [x, anchor_tail_x, fliplr(x), anchor_head_x];
        outline_y = [y_top(1:end-1), anchor_tail_y01 - 8, anchor_tail_y02, ...
            anchor_tail_y01 + 8, fliplr(y_bottom(1:end-1)), anchor_head_y];
    end
    
    % Create binary mask
    mask = poly2mask(outline_x, outline_y, 190,640);
    uint8_mask = im2uint8(mask);
    mask = uint8_mask * 255;
   
    % Blur the mask
    kernel_size = 8;
    sigma = 10;
    gaussian_kernel = fspecial('gaussian', kernel_size, sigma);
    blurred_mask = imfilter(mask, gaussian_kernel, 'same');
    
    % Get the original frame, then call imadjust()
    I = rgb2gray(read(v, frame_num));
    I_adp = uint8(double(I) .* im2double(blurred_mask));
    A = imadjust(I_adp, [0.2 0.3], [0 1]);
    writeVideo(vOut, A);
end

% Close the VideoWriter object
close(vOut);
disp(['SUCCESS: ', vid_filename, ' is saved.']);
toc;

end


