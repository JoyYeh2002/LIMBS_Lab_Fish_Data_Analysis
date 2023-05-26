% Joy Yeh Eigen Luminance Tail Motion Analysis
% trackerFullProcess.m
%
% Adopted from helper.m, given an input directory, starts from vid.avi and
% then go through trimming, pre-track, mask creation, precise track, and
% data saving
%
% [05/22] Runtime:

%% Control Panel

%% The MATLAB, computer-vision based fish tracking workflow
function trackerFullProcess(fish_dir, head_direction)
    x_origin = 220;
    y_origin = 110;

    % Step01: Pin Fish
    if head_direction == 'L'
        redactShuttleAndPinFish(fish_dir, x_origin, y_origin);
    else % if head points R
        redactShuttleAndPinFishHeadRight(fish_dir, x_origin, y_origin); 
    end

    % Step02: segment skeleton
    x_min = 194;
    x_max = 464; % [OLD] x_max = 484;
    mid_range = 200;

    gap = 60;
    gap_small = 15;

    % Assuming we already have: input_vid_name = [input_dir, 'vid_pre_processed.avi'];
    segmentSkeleton(fish_dir, x_origin, y_origin, ...
        x_min, x_max, mid_range, gap, gap_small);

    % Step03: save radiant custom binary mask, generated from pre-tracking
    fishMaskEnhancement(fish_dir);

    % Step04: save precise skeleton to the folder [New version with head
    % direction] Console message included
    labelAndSaveSkeleton(fish_dir, 0);
   
    % Step05: save snapshot to the folder with frame gap of 20
    % Message included
    generateTailSnapshotsVideo(fish_dir, 20);
  
end
    