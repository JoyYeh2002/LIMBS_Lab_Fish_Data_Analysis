% helper_tester.m
% Skeleton main driver code for various functions for fish tracker 3.0
% Updated 04/17/2023


%% 6 videos total (from dark to light)
% this_fish_dir = 'hope_low_trial03_il_1\';
% this_fish_dir = 'hope_trial04_il_2\';
% this_fish_dir = 'hope_low_trial27_il_5\';
% this_fish_dir = 'hope_low_trial22_il_6\';
% this_fish_dir = 'hope_trial08_il_5\';
% this_fish_dir = 'hope_trial06_il_7\';
% '

directories = {'hope_low_trial03_il_1\', ...
    'hope_trial04_il_2\', ...
    'hope_low_trial27_il_5\', ...
    'hope_low_trial22_il_6\', ...
    'hope_trial08_il_5\', ...
    'hope_trial06_il_7\'};

%% Control Panel

%% The MATLAB, computer-vision based fish tracking workflow
pin_shuttle = 0; % Step 1: pin the fish head to a certain location in the center
pre_segment = 0; % Step 2: Roughly track the fish at ~10 points and save coordinates
enhance_and_save_vid = 0; % Step 3: Use these points to create a custom enhancement mask for fish to pop out
track_and_save_skeleton = 1; % Step 4: Calculate a detailed, resampled, and evenly-spaced skeleton with coordinates
generate_snapshots = 1; % Preliminary visualization of time vs. pinned body location 

for file_idx = 3:numel(directories)
    this_fish_dir = directories{file_idx};
    %% [TESTED OK] 04/02/2023 10:39AM
    % Pre-process video
    input_dir = ['..\data\', this_fish_dir];
    x_origin = 220;
    y_origin = 110;
    
    if pin_shuttle == 1
        output_vid_name = redactShuttleAndPinFish(this_fish_dir, x_origin, y_origin);
    end
    
    %% [TESTED OK] 04/17/2023 02:44 AM
    % Pre-segmentation
    if pre_segment == 1
        x_min = 194;
        x_max = 464; % [OLD] x_max = 484;
        mid_range = 200;
    
        gap = 60;
        gap_small = 15;
    
        % Assuming we already have: input_vid_name = [input_dir, 'vid_pre_processed.avi'];
        [mat_name, csv_name] = segmentSkeleton(input_dir, ...
            x_origin, y_origin, ...
            x_min, x_max, mid_range, gap, gap_small);
    end
    
    %% [TESTED OK] 04/30/2023 09:36AM
    % Save radiant custom binary mask, generated from pre-tracking
    % constellation. Then, save the "vid_enhanced.avi" file.
    if enhance_and_save_vid == 1
        fishMaskEnhancement(this_fish_dir);
    end
    
    %% [TESTED OK] 05/01/2023 02:17PM
    % Track and save evenly-spaced skeleton points along the fish body
    if track_and_save_skeleton == 1
        labelAndSaveSkeleton(this_fish_dir, 0);
    end
    
    %% [TESTED OK] 05/19/2023 06:17AM 
    % Generate tail snapshots with the jet colormap: dir, frame_gaps
    if generate_snapshots == 1
        generateTailSnapshotsVideo(this_fish_dir, 20);
    end
end
    

