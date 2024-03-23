%% Step06_body_data_cleanup_part01.m
% Updated 03.23.2024
% LIMBS Lab
% Author: Huanying (Joy) Yeh

% Experiment Name: Eigenmannia Virescens Luminance + Locomotion Comparisons
%
% Content:
% - From visual inspection from step05_body_data_inspect.m, manually record
% trials and reps with tracking loss
% - Create a helper_bad_tags_head.mat to store these information
% - For only keeping valid data about body bending

%% 1. Load the big struct
parent_dir = fullfile(pwd, '..', '..');
abs_path = fullfile(parent_dir, 'data_structures\');
out_path = fullfile(parent_dir, 'data_structures\helper_structs\');
if ~exist(out_path, 'dir')
    mkdir(out_path);
end

all_fish = load(fullfile(abs_path, 'data_clean_body.mat'), 'all_fish').all_fish; 

fishNames = {'Hope', 'Len', 'Doris', 'Finn', 'Ruby'}; % consistent with SICB
numIls = [14, 9, 11, 9, 9];
numFish = 5;
numPoints = 12;

body_bad_tags = struct();

%% 2. From visual inspection, record the bad trials with tracking losses
% HOPE STARTS HERE ---------------------------------
% This means il = 1, trial 3, rep 3
bad_trials_Hope = [1, 3, 3;
    1, 33, 3;
    1, 38, 3;
    1, 40, 2;
    1, 40, 3;
    2, 15, 3;
    2, 19, 1;
    2, 28, 3;
    3, 4, 2;
    3, 11, 2;
    3, 11, 3;
    3, 17, 1;
    3, 17, 3;
    3, 26, 3;
    3, 32, 3;
    4, 26, 1;
    4, 26, 3;
    6, 25, 1;
    6, 25, 2;
    7, 27, 3;
    8, 22, 2;
    9, 5, 3;
    10, 23, 1;
    10, 30, 2;
    10, 30, 3;
    10, 31, 1;
    10, 31, 2;];

body_bad_tags(1).name = 'Hope';
body_bad_tags(1).tags = bad_trials_Hope;

% LEN STARTS HERE ---------------------------------
bad_trials_Len = [3, 26, 2;
    3, 26, 3;
    3, 35, 3;
    4, 12, 1;
    4, 12, 2;
    6, 22, 1;
    6, 22, 2;
    8, 19, 3;];

body_bad_tags(2).name = 'Len';
body_bad_tags(2).tags = bad_trials_Len;

% DORIS STARTS HERE ---------------------------------
bad_trials_Doris = [
    1, 6, 3;
    1, 17, 2;
    1, 31, 2;
    1, 25, 2;
    2, 14, 3;
    2, 51, 2;
    2, 51, 3;
    3, 43, 1;
    3, 43, 3;
    4, 9, 2;
    6, 7, 3;
    7, 28, 2;
    7, 28, 3;
    8, 30, 3;
    9, 20, 2;];

body_bad_tags(3).name = 'Doris';
body_bad_tags(3).tags = bad_trials_Doris;

% FINN STARTS HERE ---------------------------------
bad_trials_Finn = [1, 23, 1;
    1, 23, 2;
    1, 23, 3;
    1, 33, 1;
    1, 33, 2;
    1, 33, 3;
    2, 9, 3;
    2, 27, 2;
    2, 28, 1;
    2, 28, 3;
    2, 36, 3;
    2, 47, 2;
    3, 21, 3;
    3, 35, 2;
    3, 39, 2;
    3, 39, 3;
    4, 31, 1;
    5, 4, 3;
    5, 17, 3;
    6, 43, 1;
    6, 43, 2;
    6, 43, 3;];

body_bad_tags(4).name = 'Finn';
body_bad_tags(4).tags = bad_trials_Finn;

% RUBY STARTS HERE --------------------------------
bad_trials_Ruby = [1, 23, 2;
    1, 33, 2;
    1, 40, 3;
    2, 28, 1;
    2, 28, 3;
    4, 12, 2;
    4, 12, 3;
    4, 31, 3;
    6, 43, 2;
    9, 7, 1;];

body_bad_tags(5).name = 'Ruby';
body_bad_tags(5).tags = bad_trials_Ruby;

%% 3. Save to the "body_bad_tags.mat" file for comparing with "clean_data_head_point.mat"
save([out_path, 'helper_bad_tags_body.mat'], 'body_bad_tags');
disp("SUCCESS: \data_structures\helper_structs\helper_bad_tags_head.mat is saved.")


