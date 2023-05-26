% Joy Yeh Eigen Luminance Tail Beat Analysis
% redact_shuttle_and_pin_fish.m
%
% A combined function that:
% 1. Removes the shuttle bright strips with 2 black boxes
% 2. Pins the fish at a given coordinate (x = 220, y = 110) for Head == 'L'
%
% Runtime: 13.8s 
%
% Updated 04/02/2023

function redactShuttleAndPinFish(this_fish_dir, x_anchor, y_anchor)
tic()
close all;

% Open DLC file
% path = ['..\data\', this_fish_dir];
path = this_fish_dir; % [NEW] use this for population analysis
data_csv = dir(fullfile(path, '*.csv')); % This is the DLC-tracked data
file = fullfile(path, data_csv.name);
tracked_data = readtable(file);

% Extract shuttle DLC positions
shuttle_x = tracked_data{:, 5};
shuttle_y = tracked_data{:, 6};

% Extract fish x and y positions
x_data = tracked_data{:, 2};
y_data = tracked_data{:, 3};

videoFile = 'vid.avi';
v = VideoReader([path, videoFile]);

% Create the output video
outputVid = VideoWriter([path, 'vid_pre_processed.avi']);
outputVid.FrameRate = 25;
open(outputVid);

% Setting params for this video
for i = 1 : v.NumFrames
    set(gcf,'visible','off')
    I = read(v, i);
    I = rgb2gray(I);
    
    s_x = ceil(shuttle_x(i));
    s_y = ceil(shuttle_y(i));
    
    % Define rectangle specs
    stretch_L = 342;
    stretch_R = 28;
    stretch_y = 110;
    half_height = 7;
    
    % Create 2 black rectangle masks
    rect_mask = zeros(size(I, 1), size(I, 2));
    rect_mask(s_y - half_height : s_y + half_height, ...
        max(1, s_x - stretch_L) : min(640, s_x + stretch_R)) = 1;
    rect_mask(s_y + stretch_y - half_height : s_y + stretch_y + half_height, ...
        max(1, s_x - stretch_L) : min(640, s_x + stretch_R)) = 1;
    
    % Apply the mask to the image
    I(rect_mask == 1) = 0;
    
    % Apply colormap to figure
    map = gray(256);
    colormap(gray(256));
    
    % Pin fish by shifting
    x = ceil(x_data(i));
    y = ceil(y_data(i));
    I_shifted = imtranslate(I, [x_anchor - x, y_anchor - y]);
    
    % Write to outputVid
    frame = ind2rgb(I_shifted, map);
    writeVideo(outputVid, frame);
end

close(outputVid)
disp(['SUCCESS: ', path, 'vid_pre_processed.avi is saved. L']);
toc()
end
