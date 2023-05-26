% Joy Yeh Eigen Luminance Tail Beat Analysis
% Helper: labelRawSkeleton.m
%
% After initial tracking (might have outliers at the tail), we plot the raw
% skeleton on the video
% 
% Runtime: 
% Updated 04/02/2023

% Load video
tic()
close all;

input_dir = '..\data\hope_low_trial03_il_1\';
mat_name = [input_dir, 'body_tracked_data.mat'];
load(mat_name);

% 1777 x 15
data = all_outputs;

% Create a VideoWriter object to write the frames to a video file
vOut = VideoWriter([input_dir, 'raw_skeleton.avi']);
vOut.FrameRate = 25;
open(vOut);

% Loop through frames
for i = 1 : 500% : v.NumFrames
    
    I = read(v, i);
    set(gcf, 'Visible', 'off');
    %I = im2gray(I);
    imshow(I);
    
    % Plot the points
    % Define 12 points as a 12x2 matrix
    points = horzcat(x_outputs', data(i, :)');
    
    % Plot the points on the image using red circles
    %hold on; % Make sure the image is not cleared when plotting the points
    %plot(points(:,1), points(:,2), 'ro-');
    
    % Define the center and radius of the circle
    for idx = 1:15
        center = points(idx, :);
        radius = 4;
        
        % Apply hollow red circle mask
        [X,Y] = meshgrid(1:size(I,2), 1:size(I,1));
        dist = sqrt((X-center(1)).^2 + (Y-center(2)).^2);
        mask_red = (dist >= radius-0.3) & (dist <= radius+0.8);
        red_channel = I(:,:,1);
        red_channel(mask_red) = 255;
        I(:,:,1) = red_channel;
        
    end
    
    frame = I;
    writeVideo(vOut, frame);
    
    
end
close(vOut);
disp('vid is saved!')
toc()


