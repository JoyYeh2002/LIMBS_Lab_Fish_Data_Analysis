%% fig05c_tail_angular_velocity_distributions.m
% Updated 04.09.2024
% LIMBS Lab
% Author: Huanying (Joy) Yeh

% Experiment Name: Eigenmannia Virescens Luminance + Locomotion Comparisons
%
% Content:
% - Calculate the tail angular velocities and then save in "results_tail_velocity.mat."
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
% "result_tail_angular_velocity.mat"


close all;
addpath 'helper_functions'

%% 1. Specify folder paths
parent_dir = fullfile(pwd, '..', '..');
abs_path = fullfile(parent_dir, 'data_structures\');
out_path = fullfile(parent_dir, 'figures\');
pdf_path = fullfile(parent_dir, 'figures_pdf\');

out_archive_path = fullfile(parent_dir, 'figures_archive\fig05c_tail_velocity_distributions\');
if ~exist(out_archive_path, 'dir')
    mkdir(out_archive_path);
end

outfile_name = 'result_rms_velocity_angular.mat';

close all

%% 2. Load the full body struct and tail FFT struct
all_fish = load(fullfile(abs_path, 'data_clean_body.mat'), 'all_fish').all_fish;
fishNames = {'Hope', 'Len', 'Doris', 'Finn', 'Ruby'}; % consistent with SICB
% 
% % [Input] target fish to save
% target_fish_idx = 1;

% Keep populating the res FFT struct
out_filename = 'result_tail_angular_velocity.mat';
% res = load(fullfile(abs_path, 'result_tail_fft_and_curvature.mat'), 'res').res;


numFish = 5;
num_body_pts = 12;
p2m = 0.0004; % [CAUTION] velocity is in m/s

%% 2. Use the "result" struct to store outputs at rep and luminance abstraction levels
for i = 1 : numFish

    num_il_levels = numel(res(i).luminances);

    % Create data containers for mean data over all trials and reps
    this_fish_rms = cell(num_il_levels, 1);
    this_fish_dist = cell(num_il_levels, 1);
    this_fish_velocity = cell(num_il_levels, 1);
    this_fish_v_ang = cell(num_il_levels, 1);

    for il = 1 : num_il_levels

        % make a container for this il level, range = 5 trials here
        num_trials = numel(res(i).luminances(il).data);

        % Create data containers within the luminance
        this_il_rms = zeros(num_trials, num_body_pts);
        this_il_dist = zeros(num_trials, num_body_pts);

        % [NEW] Add directional velocities
        this_il_v = [];
        this_il_v_ang = [];

        for trial_idx = 1 : num_trials

            % Grab the target data and calculate RMS
            data = all_fish(i).luminances(il).data(trial_idx); % This is Hope trial 30

            [rms_each_rep, rms_trial, dist_each_rep, dist_trial] = calculateRMS(data);

            % NEW: added angular velocity
            % [velocity_each_rep, velocity_trial, ...
            %     v_angular_each_rep, v_angular_trial, num_samples] = calculateVelocity(data);

            % ----------------------- HELPER STARTS HERE
            time_diff = 0.04;
            valid_tag = data.valid_both;

            x = {data.x_rot_rep1 * p2m, data.x_rot_rep2 * p2m, data.x_rot_rep3 * p2m};
            y = {data.y_rot_rep1 * p2m, data.y_rot_rep2 * p2m, data.y_rot_rep3 * p2m};

            v_reps = cell(1, 3);
            v_sample_pts = []; % This stores all the velocity data points of this trail (all valids reps)

            v_angular_reps = cell(1, 3);
            v_angular_sample_pts = [];

            % loop through reps
            for j = 1 : 3
                if valid_tag(j) == 1 % if this rep is valid

                    % Calculate displacements
                    displacements_x = diff(x{j});
                    displacements_y = diff(y{j});

                    displacement = sign(diff(y{j})) .* sqrt(diff(x{j}).^2 + diff(y{j}).^2);

                    % Calculate speed
                    v = displacement / time_diff;
                    v_reps{j} = v;
                    v_sample_pts = [v_sample_pts; v];

                    % Calculate angular velocity
                    x_disp = x{j} - 220 * p2m; % 500 x 12
                    y_disp = y{j} - 110 * p2m;
                    angles = rad2deg(atan2(y_disp, x_disp));

                    v_angular = diff(unwrap(angles)) / time_diff; % Unwrap angles to handle discontinuities 499 x 12 

                    v_angular = diff(angles) / time_diff; 

                    v_angular_reps{j} = v_angular;
                    v_angular_sample_pts = [v_angular_sample_pts; v_angular];

                    close all;
                else
                    v_reps{i}= zeros(499, 12);
                end
            end

            num_samples = size(v_sample_pts, 1);

            %% 3. Populate the struct
            res(i).luminances(il).data(trial_idx).trID = data.trial_idx;
            res(i).luminances(il).data(trial_idx).rms_reps = rms_each_rep';
            res(i).luminances(il).data(trial_idx).rms_trial = rms_trial';
            res(i).luminances(il).data(trial_idx).dist_reps = dist_each_rep';
            res(i).luminances(il).data(trial_idx).dist_trial = dist_trial';

            velocity_trial = v_sample_pts;
            v_angular_trial = v_angular_sample_pts;

            res(i).luminances(il).data(trial_idx).trial_velocity = velocity_trial;
            res(i).luminances(il).data(trial_idx).trial_v_ang = v_angular_trial;

            this_il_rms(trial_idx, :) = rms_trial';
            this_il_dist(trial_idx, :) = dist_trial';
            this_il_v = [this_il_v; velocity_trial];  
            this_il_v_ang = [this_il_v_ang; v_angular_trial];
        end

        % Populate at high level
        this_fish_rms{il} = this_il_rms;
        this_fish_dist{il} = this_il_dist;
        this_fish_velocity{il} = this_il_v;
        this_fish_v_ang{il} = this_il_v_ang;
    end

    % Use a 14x12 matrix to contain the average RMS data
    this_fish_rms_avg = zeros(num_il_levels, num_body_pts);
    this_fish_dist_avg = zeros(num_il_levels, num_body_pts);

    for il = 1 : num_il_levels
        this_fish_rms_avg(il, :) = nanmean(this_fish_rms{il}, 1);
        this_fish_dist_avg(il, :) = nanmean(this_fish_dist{il}, 1);
    end
    res(i).rmsMean = this_fish_rms_avg;
    res(i).distMean = this_fish_dist_avg;
    res(i).velocities = this_fish_velocity;
    res(i).v_angular = this_fish_v_ang;
end

save([abs_path, outfile_name], 'res');
disp(['SUCCESS: ', outfile_name, ' saved for the "valid both + tail" tags.'])


%% HELPER: Calculate x and y combined velocity distributions (clean trials only)
% Lots of sample points, such as il = 4 has 2994 x 12 array
function [v_reps, v_sample_pts, v_angular_reps, v_angular_sample_pts, num_samples] = calculateVelocity_OLD(data)
time_diff = 0.04;
valid_tag = data.valid_both;

p2m = 0.0004; % [CAUTION] velocity is in m/s

x = {data.x_rot_rep1 * p2m, data.x_rot_rep2 * p2m, data.x_rot_rep3 * p2m};
y = {data.y_rot_rep1 * p2m, data.y_rot_rep2 * p2m, data.y_rot_rep3 * p2m};

v_reps = cell(1, 3);
v_sample_pts = []; % This stores all the velocity data points of this trail (all valids reps)

v_angular_reps = cell(1, 3);
v_angular_sample_pts = [];

for i = 1 : 3
    if valid_tag(i) == 1 % if this rep is valid

        % Calculate displacements
        displacements_x = diff(x{i});
        displacements_y = diff(y{i});

        displacement = sign(diff(y{i})) .* sqrt(diff(x{i}).^2 + diff(y{i}).^2);

        % Calculate speed
        v = displacement / time_diff;
        v_reps{i} = v;
        v_sample_pts = [v_sample_pts; v];

        % Calculate angular velocity
        angles = atan2(displacements_y, displacements_x);
        v_angular = diff(unwrap(angles)) / time_diff; % Unwrap angles to handle discontinuities

        v_angular_reps{i} = v_angular;
        v_angular_sample_pts = [v_angular_sample_pts, v_angular];
       
        close all;
    else
        v_reps{i}= zeros(499, 12);
    end
end

num_samples = size(v_sample_pts, 1);

end


%% HELPER: Get the 12x3 and 12x1 RMS arrays
function [rms_displacement, rms_trial, total_displacement, trial_displacement] = calculateRMS(data)

v = data.valid_both; % [NEW] USE BOTH VALID
p2cm = 0.02; % [CAUTION] use cm as the unit, rather than meters
x = {data.x_rot_rep1 * p2cm, data.x_rot_rep2 * p2cm, data.x_rot_rep3 * p2cm};
y = {data.y_rot_rep1 * p2cm, data.y_rot_rep2 * p2cm, data.y_rot_rep3 * p2cm};

% Calculate displacement, 3 reps total, 12 body points
displacement = cell(1, 3);
rms_displacement = zeros(12, 3); % These might have zeros if invalid
total_displacement = zeros(12, 3);

for i = 1 : size(x, 2) % Loop through 3 reps
    if v(i) == 1 % if this rep is valid

        % This is 499 x 12
        displacement{i} = sqrt(diff(x{i}).^2 + diff(y{i}).^2);

        % rms() documentation: https://www.mathworks.com/help/matlab/ref/rms.html
        rms_displacement(:, i) = rms((y{i} - mean(y{i})),'omitnan');

        for p = 1 : 12
            total_displacement(p, i) = sum(displacement{i}(:, p));
        end
    else
        displacement{1} = 0;
        for p = 1 : 12
            rms_displacement(p, i) = 0;
            total_displacement(p, i) = 0;
        end
    end
end

% Take the trial average RMS (valid only)
rms_trial = zeros(12, 1); % only has 12 points
trial_displacement = zeros(12, 1);
num_valid_trials = sum(v);
for j = 1 : 12
    rms_trial(j) = sum(rms_displacement(j, :)) / num_valid_trials;
    trial_displacement(j) = sum(total_displacement(j, :)) / num_valid_trials;
end
end








