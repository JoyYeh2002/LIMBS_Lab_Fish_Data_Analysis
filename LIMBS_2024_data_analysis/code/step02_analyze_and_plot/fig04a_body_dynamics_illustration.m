%% fig04a_body_dynamics_illustration.m
% Updated 04.06.2024
% LIMBS Lab
% Author: Huanying (Joy) Yeh

% Experiment Name: Eigenmannia Virescens Luminance + Locomotion Comparisons
%
% Content:
% - Load 5 sample images and videos from "data/media/" folder
% - Overlay the rainbow scatters with video frames
% - Save most frames to "figures_archive"
%
% Output (for archive):
% "fig04a01_body_bending_vs_illuminance.png", with video frames overlaying the rainbow colors.
% "fig04a02_body_bending_timeline.png", it's the right panel with rainbow
% color timelines
% "fig04a03" and "fig04a04", same panels but for a different trial.

%% 1. Specify folder paths
parent_dir = fullfile(pwd, '..', '..');
abs_path = fullfile(parent_dir, 'data_structures\');

out_data_path = fullfile(parent_dir, 'data\media\');
if ~exist(out_data_path, 'dir')
    mkdir(out_data_path);
end

out_path = fullfile(parent_dir, 'figures\');
out_pdf_path = fullfile(parent_dir, 'figures_pdf\');

out_archive_path = fullfile(parent_dir, 'figures_archive\fig04a_body_dynamics\');
if ~exist(out_archive_path, 'dir')
    mkdir(out_archive_path);
end

pdf_path = fullfile(parent_dir, 'figures_pdf\');

close all

num_body_pts = 12;

%% 2. Load Video Frames

% doris il = 1, trial = 52, rep = 3 (dark, 0.2 lux) [1, 1, 1]
% hope il = 10, trial = 7, rep = 2 (mid, ??? lux) [1, 1, 1]
% ruby il = 9, trial = 10, rep = 3 (light, 210 lux) [0, 1, 1]

% Check validity
all_fish = load(fullfile(abs_path, 'data_clean_body.mat'), 'all_fish').all_fish;

fishNames = {'Hope', 'Len', 'Doris', 'Finn', 'Ruby'}; % consistent with SICB

p2m = 0.0004;
num_frames = 500;

%% 3. [FIRST TIME RUN] Copy the dedicated videos to the "data/media/" folder
copy_videos_switch = 0; % already copied; turn this off
if copy_videos_switch == 1
    base_path = 'C:\Users\joy20\Folder\SP_2024\data\body_bending\';

    dest_path01 = copy_videos(base_path, out_data_path, 'doris', 1, '52'); %3
    dest_path02 = copy_videos(base_path, out_data_path, 'hope', 10, '07'); %2
    dest_path03 = copy_videos(base_path, out_data_path, 'ruby', 9, '10');  %3
end

%% 4. Loop through and plot
for img_num = 1 : 3
    if img_num == 1

        fish_idx = 3;
        fish_name = 'doris';
        il = 1;
        trial_number = 52;
        dest_path = dest_path01;
        rep = 3;
        letter = 'a';

    elseif img_num == 2
        fish_idx = 1;
        fish_name = 'hope';
        il = 10;
        trial_number = 7;
        dest_path = dest_path02;
        rep = 2;
        letter = 'b';

    else
        fish_idx = 5;
        fish_name = 'ruby';
        il = 9;
        trial_number = 10;
        dest_path = dest_path03;
        rep = 3;
        letter = 'c';
    end


    % Get video frames
    frame_idx = 251 + rep * 500;
    frame = display_vid_frame(dest_path, frame_idx); % TODO; replace this with original frame, not processed

    %% 5. Save the video frame
    out_frame_filename = ['fig04a0', num2str(img_num), '_vid_frame_', fish_name, '_il_', num2str(il), ...
        '_trial_', num2str(trial_number), '_rep_', num2str(rep), '_frame_', num2str(frame_idx), '.png'];
    imwrite(frame, [out_path, out_frame_filename]);
    disp(["SUCCESS: ", out_frame_filename, " is saved."]);

    % Get the target data
    myColorMap = jet(num_body_pts);
    trial_idx = findFieldIdx(all_fish(fish_idx).luminance(il).data, trial_number);

    field_name_x = ['x_rot_rep', num2str(rep)];
    field_name_y = ['y_rot_rep', num2str(rep)];

    xData = all_fish(fish_idx).luminance(il).data(trial_idx).(field_name_x);
    yData = all_fish(fish_idx).luminance(il).data(trial_idx).(field_name_y);

    %% 6. Plot and save rainbow scatterplot
    title_text = ['Rainbow Scatterplot: ', fish_name, ' Il = ', num2str(il), ' Trial = ', num2str(trial_number), ' Rep = ', num2str(rep)];
    out_rainbow_fig = plotScatterWithColorbar(xData, yData, myColorMap, title_text);

    out_rainbow_filename = ['fig04a0', num2str(img_num), '_rainbow_', fish_name, '_il_', num2str(il), ...
        '_trial_', num2str(trial_number), '_rep_', num2str(rep), '.png'];
    saveas(out_rainbow_fig, [out_path, out_rainbow_filename]);
    disp(['SUCCESS: ', out_rainbow_filename, ' is saved.']);


    %% 7. Plot and save timeline plot
    time = 0:0.04:19.96;
    title_text = ['Timeline: ', fish_name, ' Il = ', num2str(il), ' Trial = ', num2str(trial_number), ' Rep = ', num2str(rep)];

    out_timeline_fig = plotTailPointTimeDomainScatterWithColorbar(time, yData, myColorMap, title_text);

    out_time_filename = ['fig04a0', num2str(img_num), '_timeline_', fish_name, '_il_', num2str(il), ...
        '_trial_', num2str(trial_number), '_rep_', num2str(rep), '.png'];
    saveas(out_timeline_fig, [out_path, out_time_filename]);
    disp(['SUCCESS: ', out_time_filename, ' is saved.']);


end

%% Helper: copy videos to the data/media path
function destination_path = copy_videos(base_path, out_data_path, fish_name, il, trial_number)
path = [base_path, fish_name, '\', num2str(il), '\trial', trial_number, '*'];
match = dir(path);

source_path = fullfile(match.folder, match.name, "\vid_pre_processed.avi");
destination_path = [out_data_path, 'il_', num2str(il), fish_name, '_trial_', trial_number, '.avi'];
copyfile(source_path, destination_path);
disp("SUCCESS: Video is copied.");
end

%% Helper: display the given video frame from the input path
function frame = display_vid_frame(file_path, frame_idx)
vidReader = VideoReader(file_path);
frame = read(vidReader, frame_idx);
end

%% Helpers: given struct and the exp trial number, find its field index in the struct
function target_idx = findFieldIdx(input_struct, target_trial_idx)
leftmost_col = struct2cell(input_struct); %.trial_idx];
leftmost_col = cell2mat(squeeze(leftmost_col(1, :, :)));
target_idx = find(leftmost_col == target_trial_idx, 1);
end

%% Helper: Given x data, y data and color scheme, plot the scatter plot of all the body locations in the trial
function fig = plotScatterWithColorbar(xData, yData, myColorMap, title_text)
numPoints = size(xData, 2);

fig = figure('Position', [100, 100, 640, 190]);
set(gcf, 'Visible', 'off');

hold on;
for col = 1:numPoints
    scatter(xData(:, col), yData(:, col), 10, myColorMap(col, :), 'filled');
end
hold off;

colormap(myColorMap);

h = colorbar;
custom_ticks = [0, 0.5, 1];
custom_labels = {'Head', 'FMiddle', 'Tail'};

title(h, 'Fish');
set(h, 'XTick', custom_ticks);
set(h, 'XTickLabel', custom_labels);

xticks([]);
yticks([]);

xlim([0, 640]);
ylim([-50, 250]);

title(title_text);
end

%% Helper: tail point t-d movement on the 20-second timeline
function fig = plotTailPointTimeDomainScatterWithColorbar(time, yData, myColorMap, titleText)

fig = figure('Position', [100, 100, 640, 190]);
set(gcf, 'Visible', 'off');
numPoints = size(yData, 2); % Use all 12 points

% Plot all columns with the jet colormap
hold on;
for col = 1:numPoints
    plot(time, yData(:, col), 'Color', myColorMap(col, :), 'LineWidth', 2);
end
hold off;
colormap(myColorMap);

% Custom color bar
h = colorbar; 
custom_ticks = [0, 0.5, 1];
custom_labels = {'Head', 'FMiddle', 'Tail'};

title(h, 'Fish');
set(h, 'XTick', custom_ticks);
set(h, 'XTickLabel', custom_labels);

xlim([0, 20]); % timeline x-axis is out of 20 seconds
ylim([-50, 250]);

xlabel("Time(s)")
ylabel("Y-Pos (pixel)")

title(titleText);

grid on;
end







