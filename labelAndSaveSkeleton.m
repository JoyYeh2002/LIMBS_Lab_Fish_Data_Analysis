% Joy Yeh Eigen Luminance Tail Motion Analysis
% Helper: labelAndSaveSkeleton.m
%
% After getting vid_enhanced.avi with fishMaskEnhancement(), use the
% (almost) binary fish video frames to label the centerline points along
% the body
%
% 1) Load related .avi and .mat files
% 2) Draw vertical lines and identify body center points with convolution
% 3) Delete outliers such as points that are too far from the fish, as well
% as points that are too dark
% 4) Polyfit(x, y, 3)
% 5) interparc() for equally-spaced points
% 4) Save the spline for each frame into a .mat and .csv file
%
% [05/01] Runtime: ~30s

function labelAndSaveSkeleton(this_fish_dir, save_video)
close all;
tic;

%% Control Panel
% this_fish_dir = 'hope_trial06_il_7\';
% save_video = 0;

% Open "v_enhanced" for tracking, "v_raw" for final output video
v = VideoReader(['..\data\', this_fish_dir, 'vid_enhanced.avi']);
v_raw = VideoReader(['..\data\', this_fish_dir, 'vid_pre_processed.avi']);

% re-define the x anchors
x_outputs = [194 220 254 280 314 345 374 410 435 460 475 485 490];

% Create a VideoWriter
if save_video == 1
    vid_filename = ['..\data\', this_fish_dir, 'vid_tracked.avi'];
    vOut = VideoWriter(vid_filename);
    vOut.FrameRate = 25;
    open(vOut);
end

% Set up the y-tracked points. At the end, we combine all 3 parts
y_part01 = zeros(v.NumFrames, 1); % head and mouth
y_part02 = ones(v.NumFrames, 1) * 110; % head center (pinned)
y_part03 = zeros(v.NumFrames, length(x_outputs)-2); % rest of the body

% Define the kernal
kernel_size = 5;
kernel = ones(kernel_size, 1);

% Data container for the tracked points
n = v.NumFrames;
num_points = 15;

x_tracked = zeros(n, num_points);
y_tracked = zeros(n, num_points);

for frame_num = 1 : n
    % Get frames
    I_raw = rgb2gray(read(v_raw, frame_num));
    I = rgb2gray(read(v, frame_num));

    % Track fish center y-values with convolution. Start with the head
    img_strip = I(:, x_outputs(1));
    conv_result = conv(img_strip,kernel,'valid');
    [~, target] = max(conv_result);
    center_idx = target+2;
    y_part01(frame_num, 1) = center_idx;

    % Track rest of the body
    for idx = 1:length(x_outputs)-2
        x = x_outputs(idx + 2);
        img_strip = I(:, x);
        conv_result = conv(img_strip,kernel,'valid');
        [~, target] = max(conv_result);
        center_idx = target+2;
        y_part03(frame_num, idx) = center_idx;
    end

    % Combine 3 parts of the y matrix
    y_all = [y_part01 y_part02 y_part03];

    % Interpolate spline
    x = x_outputs;
    y = y_all(frame_num, :);

    handle_error = 1;
    if handle_error == 1
        % Error handling for y-outliers.
        index = [];
        new_array = y;
        new_anchors = x;

        % If distances are too far, tracking was incorrect.
        i = 3;
        while i <= length(y)
            if abs(y(i) - y(i-1)) > 25
                new_array(i) = NaN;
                new_anchors(i) = NaN;
                % Oranize the new array
                x(i) = NaN;
                y(i) = NaN;
                x = x(~isnan(x));
                y = y(~isnan(y));
            end
            i = i + 1;
        end

        % Oranize the new array, then fit polynomial
        new_anchors = new_anchors(~isnan(new_anchors));
        new_array = new_array(~isnan(new_array));

        % If the observed region is too dark, tracking was incorrect
        for i = length(y) - 4 : length(y)
            if y(i) < 10 || y(i) > 180
                new_array(i) = NaN;
                new_anchors(i) = NaN;
            end

            % Extract the 3x3 patch and threshold average intensity
            patch = I(max(1, y(i)-1) : y(i)+1, x(i)-1:x(i)+1);
            if mean(patch(:)) < 20
                new_array(i) = NaN;
                new_anchors(i) = NaN;
            end
        end

        % Oranize the new array, then fit polynomial
        new_anchors = new_anchors(~isnan(new_anchors));
        new_array = new_array(~isnan(new_array));

        y = new_array;
        x = new_anchors;
    end

    % Evaluate polynomial fit over a fine grid
    p = polyfit(x, y, 3);
    xfine = linspace(x_outputs(1), x_outputs(end), 30);
    yfit = polyval(p, xfine);

    % Interparc() creates evenly spaced landmarks on the polyfit
    interp_pts = interparc(num_points, xfine, yfit, 'spline');
    x_out = interp_pts(:, 1);
    y_out = interp_pts(:, 2);

    % If need to save video, start plotting
    if save_video == 1
        fig = figure();
        set(fig, 'visible', 'off');

        imshow(I_raw);
        hold on
        cmap = autumn(length(x_out));
        
        % Plot the original and interpolated curves
        % scatter(x, y, 'filled', 'MarkerFaceColor', 'm','SizeData', 15);
        % plot(x_out, y_out, '-', 'Color','g','LineWidth',1.5);

        scatter(x_out, y_out, [], cmap,'filled','SizeData', 15);

        % title(['Frame ', num2str(frame_num)])

        % Write to video file
        frame = getframe(fig);
        writeVideo(vOut, frame);
    end

    % Save this frame's tracked point coordinates
    x_tracked(frame_num, :) = x_out';
    y_tracked(frame_num, :) = y_out';

end

% Save tracked data into .csv and .mat
% writematrix(x_tracked, ['..\data\', this_fish_dir, 'tracked_data_x.csv']);
% writematrix(y_tracked, ['..\data\', this_fish_dir, 'tracked_data_y.csv']);
save(['..\data\', this_fish_dir, 'tracked_data.mat'], 'x_tracked', 'y_tracked');

% Output messages to console
if save_video == 1
    try
        close(vOut);
        if ~isvalid(vOut)
            disp('FAILURE: Video object closed successfully');
        else
            disp(['SUCCESS: ', vid_filename, ' is saved.']);
        end
    catch ME
        disp(['Error: ' ME.message]);
    end
end
% 
% disp(['SUCCESS: ', this_fish_dir, 'tracked_data_x.csv is saved.']);
% disp(['SUCCESS: ', this_fish_dir, 'tracked_data_y.csv is saved.']);
disp(['SUCCESS: ', this_fish_dir, 'tracked_data.mat is saved.']);

% End timer
toc;
end