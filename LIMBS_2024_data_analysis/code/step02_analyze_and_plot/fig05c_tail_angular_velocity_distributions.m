%% fig05c_tail_angular_velocity_distributions.m
%% fig05c_tail_RMS_and_ngular_velocity_struct_build.m
% Updated 04.09.2024
% LIMBS Lab
% Author: Huanying (Joy) Yeh

% Experiment Name: Eigenmannia Virescens Luminance + Locomotion Comparisons
%
% Content:
% - Calculate the tail rms (fig5a) and angular velocities (fig5c) and save in "result_tail_rms_and_angular_velocity.mat."
% - Plot the following in "\figures"
% 
% - Distribution of angular velocities, tail point 12, then histogram
% - Then fit the Gaussian distribution, save sigma and peak
% - Then plot the Gaussian sigma situations + angular velocity
%
% - "fig05c01_tail_angular_velocity_hist_3e_hope.png"
%
% - These in "\figures_archive\fig05c_tail_velocity_distributions\"
% - All fish 3d histograms
% - All fish sigma trends
% 
% - Save the struct to 
% "result_tail_rms_and_angular_velocity.mat"

close all;
addpath 'helper_functions'

%% 1. Specify folder paths
parent_dir = fullfile(pwd, '..', '..');
abs_path = fullfile(parent_dir, 'data_structures\');
out_path = fullfile(parent_dir, 'figures\');
pdf_path = fullfile(parent_dir, 'figures_pdf\');
outfile_name = 'result_tail_rms_and_angular_velocity.mat';

close all

%% 2. Load the full body struct and tail FFT struct
all_fish = load(fullfile(abs_path, 'data_clean_body.mat'), 'all_fish').all_fish;
fishNames = {'Hope', 'Len', 'Doris', 'Finn', 'Ruby'}; % consistent with SICB
numFish = 5;
num_body_pts = 12;

%% 2. Use the "result" struct to store outputs at rep and luminance abstraction levels
res = struct();

for i = 1 : numFish
    res(i).name = fishNames{i};

    num_il_levels = numel(all_fish(i).luminance);
    this_fish_rms = cell(num_il_levels, 1);
    this_fish_v_ang = cell(num_il_levels, 1);

    for il =  1 : num_il_levels

        % make a container for this il level, range = 5 trials here
        num_trials = numel(all_fish(i).luminance(il).data);

        % Collect over all body points
        this_il_rms = zeros(num_trials, 12);
        this_il_v_ang = [];

        for trial_idx = 1 : num_trials

            % Grab the target data and calculate RMS
            data = all_fish(i).luminance(il).data(trial_idx); % This is Hope trial 30

            [rms_each_rep] = calculateCleanFullBodyRMS(data);
            [v_ang_each_rep, trial_v_ang] = calculateCleanFullBodyVelocity(data);

            %% 3. Populate the struct
            res(i).luminance(il).data(trial_idx).trID = data.trial_idx;
            res(i).luminance(il).data(trial_idx).rms_reps = rms_each_rep';
           
            res(i).luminance(il).data(trial_idx).trial_v_ang = trial_v_ang;
            this_il_rms = [this_il_rms; rms_each_rep'];
            this_il_v_ang = [this_il_v_ang; trial_v_ang];

        end

        this_fish_rms{il} = this_il_rms;
        this_fish_v_ang{il} = this_il_v_ang;

        % Take out fish 1's bad trials (consistent with FFT struct from
        % fig05b
        if (i == 1) && ((il == 1) || (il == 3) || (il == 9))
            this_fish_v_ang{il} = [];
        end
        
    end

    % Use a 14x12 matrix to contain the average RMS data
    this_fish_rms_avg = zeros(num_il_levels, num_body_pts);
  
    for il = 1 : num_il_levels
        if ~isempty(this_fish_rms{il})
            this_fish_rms_avg(il, :) = nanmean(this_fish_rms{il}, 1);
        end
    end

    res(i).lux_values = all_fish(i).lux_values;
    res(i).rms_mean = this_fish_rms_avg;
    res(i).v_ang = this_fish_v_ang;

    disp(['SUCCESS: fish ', num2str(i), ' tail RMS and angular velocity data is saved.']);

end

save([abs_path, out_filename], 'res');
disp("SUCCESS: RMS + Fish velocity struct saved for the 'valid both' tags.")

%% HELPER: Get the 12x3 and 12x1 RMS arrays
function [rms_displacement] = calculateCleanFullBodyRMS(data)

v = data.valid_both; % [NEW] USE BOTH VALID
p2cm = 0.04; % [CAUTION] use cm as the unit, rather than meters
x = {data.x_rot_rep1 * p2cm, data.x_rot_rep2 * p2cm, data.x_rot_rep3 * p2cm};
y = {data.y_rot_rep1 * p2cm, data.y_rot_rep2 * p2cm, data.y_rot_rep3 * p2cm};

% Calculate displacement, 3 reps total, 12 body points
rms_displacement = zeros(12, 3); % These might have zeros if invalid

for i = 1 : size(x, 2) % Loop through 3 reps
    if v(i) == 1 % if this rep is valid

        rms_displacement(:, i) = rms((y{i} - nanmean(y{i})),'omitnan');
    else
        rms_displacement(:, i) = 0;
    end
end

end


%% HELPER: Calculate x and y combined velocity distributions (clean trials only)
% Lots of sample points, such as il = 4 has 2994 x 12 array
function [v_ang_each_rep, v_ang_combined] = calculateCleanFullBodyVelocity(data)
time_diff = 0.04;
v = data.valid_both;

p2m = 0.0004; % [CAUTION] velocity is in m/s
x = {data.x_rot_rep1 * p2m, data.x_rot_rep2 * p2m, data.x_rot_rep3 * p2m};
y = {data.y_rot_rep1 * p2m, data.y_rot_rep2 * p2m, data.y_rot_rep3 * p2m};

v_ang_each_rep = cell(1, 3);
v_ang_combined = [];

for i = 1 : 3
    if v(i) == 1 % if this rep is valid

        x_disp = x{i} - 220 * p2m; % 500 x 12
        y_disp = y{i} - 110 * p2m;
        angles = rad2deg(atan2(y_disp, x_disp));
        v_angular = diff(angles) / time_diff; % Unwrap angles to handle discontinuities 499 x 12

        v_ang_each_rep{i} = v_angular;
        v_ang_combined = [v_ang_combined; v_angular];

    else
        velocity_reps{i}= zeros(499, 12);
        v_ang_each_rep{i} = zeros(499, 12);
        v_ang_combined = [v_ang_combined; []];
    end
end
end

