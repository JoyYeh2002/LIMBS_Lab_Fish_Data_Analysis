% Calvin Yeh Eigen Luminance Tail Beat Analysis
% redactShuttleAndPinFishWithHeadDirection.m
%
% A combined function that:
% 1. Removes the shuttle bright strips with 2 black boxes
% 2. Pins the fish at a given coordinate (x = 220, y = 110) for Head == 'L'
%
% Runtime: 13.8s 
%
% Updated 07/04/2023

% function output_vid_name = redactShuttleAndPinFishWithHeadDirection...
%     (this_fish_dir, x_anchor, y_anchor, head_direction)
this_fish_dir = 'F:\LIMBS_Hard_Drive\trial01_il_2_1';
x_anchor = 220;
y_anchor = 110;
head_direction = '';

if this_fish_dir(end-1:end) == "-1"
    head_direction = 'L'
else 
    head_direction = 'R'
end

tic()
close all;

% Open DLC file
% path = ['..\data\', this_fish_dir];
path = this_fish_dir; % [NEW] use this for population analysis
data_csv = dir(fullfile(path, 'video*.csv'));
file = fullfile(path, data_csv.name);
tracked_data = readtable(file);

% Extract shuttle, fish x, and y positions from DLC
%if head_direction == 'L'
    shuttle_x = tracked_data{:, 5};
    shuttle_y = tracked_data{:, 6};
    x_data = tracked_data{:, 2};
    y_data = tracked_data{:, 3};
%{
else
    x_anchor = 640 - x_anchor;
    y_anchor = 640 - y_anchor;

    % new change::::::
    shuttle_x = 640 - tracked_data{:, 5};
    shuttle_y = 190 - tracked_data{:, 6};
    x_data = 640 - tracked_data{:, 2};
    y_data = 190 - tracked_data{:, 3};
end
%}
v = VideoReader([path, '/vid.avi']);

% Create the output video
outputVid = VideoWriter([path, '/vid_pre_processed.avi']);
outputVid.FrameRate = 25;
open(outputVid);

% Setting params for this video
for i = 1 %: v.NumFrames
    %set(gcf,'visible','off')
    I = read(v, i);
    I = rgb2gray(I);

    

    imshow(I);
    
    s_x = ceil(shuttle_x(i));
    s_y = ceil(shuttle_y(i));
    
    % Define rectangle specs
    %if head_direction == 'L'
        stretch_L = 342;
        stretch_R = 28;
    
    %{
    else
        stretch_L = 28;
        stretch_R = 342;
    %}
    %end

    stretch_y = 110;
    half_height = 7;
    
    % Create 2 black rectangle masks
    %if head_direction == 'L'
        rect_mask = zeros(size(I, 1), size(I, 2));
        rect_mask(1 : s_y + half_height, ...
            max(1, s_x - stretch_L) : min(640, s_x + stretch_R)) = 1;
        rect_mask(s_y + stretch_y - half_height : size(I, 1), ...
            max(1, s_x - stretch_L) : min(640, s_x + stretch_R)) = 1; 
    %{
    else
        rect_mask = zeros(size(I, 1), size(I, 2));
        rect_mask(s_y - half_height : s_y + half_height, ...
            max(1, s_x - stretch_L) : min(640, s_x + stretch_R)) = 1;
        rect_mask(s_y + stretch_y - half_height : s_y + stretch_y + half_height, ...
            max(1, s_x - stretch_L) : min(640, s_x + stretch_R)) = 1;
    %}
    %end
        

    
    % Apply the mask to the image
    I(rect_mask == 1) = 0;
    
    % Apply colormap to figure
    map = gray(256);
    colormap(gray(256));
    
    % Pin fish by shifting
    x = ceil(x_data(i));
    y = ceil(y_data(i));
    I_shifted = imtranslate(I, [x_anchor - x, y_anchor - y]);

    if head_direction == 'R'
        I_shifted = imrotate(I_shifted, 180);  % Rotate the frame by 180 degrees
    end
    imshow(I_shifted);

    
    
    % Write to outputVid
    frame = ind2rgb(I_shifted, map);
    writeVideo(outputVid, frame);
end

close(outputVid)
disp(['SUCCESS: ', path, 'vid_pre_processed.avi is saved']);
output_vid_name = [path, 'vid_pre_processed.avi'];
toc()
