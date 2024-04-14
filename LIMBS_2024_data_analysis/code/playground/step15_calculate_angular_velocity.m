%% Step15: two_sided_velocity_distributions.m
% outfile_name = 'result_rms_velocity_angular.mat';

%% 1. Load the data
abs_path = 'C:\Users\joy20\Folder\SP_2024\LIMBS_2024_data_analysis\code\playground\';
struct_file = load([abs_path, 'data_clean_body_real.mat']); % All the raw + cleaned data labels
result_file = load([abs_path, 'result_rms_velocity_real.mat']);

all_fish = struct_file.all_fish;
res = result_file.res;

out_filename = 'result_tail_angular_velocity_real.mat';

close all

fishNames = {'Hope', 'Len', 'Doris', 'Finn', 'Ruby'}; % consistent with SICB
numFish = 5;
num_body_pts = 12;

%% 2. Use the "result" struct to store outputs at rep and luminance abstraction levels
for i = 1 : numFish

    res(i).name = fishNames{i};
    res(i).lux_values = all_fish(i).lux_values;
    num_il_levels = numel(res(i).luminance);

    % Create data containers for mean data over all trials and reps
    this_fish_rms = cell(num_il_levels, 1);
    this_fish_dist = cell(num_il_levels, 1);
    this_fish_velocity = cell(num_il_levels, 1);
    this_fish_v_ang = cell(num_il_levels, 1);

    for il = 1 : num_il_levels

        % make a container for this il level, range = 5 trials here
        num_trials = numel(res(i).luminance(il).data);

        % Create data containers within the luminance
        this_il_rms = zeros(num_trials, num_body_pts);
        this_il_dist = zeros(num_trials, num_body_pts);

        % [NEW] Add directional velocities
        this_il_v = [];
        this_il_v_ang = [];

        for trial_idx = 1 : num_trials

            % Grab the target data and calculate RMS
            data = all_fish(i).luminance(il).data(trial_idx); % This is Hope trial 30

            [rms_each_rep, rms_trial, dist_each_rep, dist_trial] = calculateRMS(data);

            % NEW: added angular velocity
            % [velocity_each_rep, velocity_trial, ...
            %     v_angular_each_rep, v_angular_trial, num_samples] = calculateVelocity(data);

            % ----------------------- HELPER STARTS HERE
            time_diff = 0.04;
            valid_tag = data.valid_both;

            p2m = 0.0004; % [CAUTION] velocity is in m/s

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
                    
                    % time = [0:0.04:19.96];
                    % time_gaps = [0.04:0.04:19.96];
                    %
                    x_disp = x{j} - 220 * p2m; % 500 x 12
                    y_disp = y{j} - 110 * p2m;
                    angles = rad2deg(atan2(y_disp, x_disp));

                    v_angular = diff(unwrap(angles)) / time_diff; % Unwrap angles to handle discontinuities 499 x 12 

                    v_angular_reps{j} = v_angular;
                    v_angular_sample_pts = [v_angular_sample_pts; v_angular];

                    close all;
                else
                    v_reps{i}= zeros(499, 12);
                end
            end

            num_samples = size(v_sample_pts, 1);

            %% 3. Populate the struct
            res(i).luminance(il).data(trial_idx).trID = data.trial_idx;
            res(i).luminance(il).data(trial_idx).rms_reps = rms_each_rep';
            res(i).luminance(il).data(trial_idx).rms_trial = rms_trial';
            res(i).luminance(il).data(trial_idx).dist_reps = dist_each_rep';
            res(i).luminance(il).data(trial_idx).dist_trial = dist_trial';


            velocity_trial = v_sample_pts;
            v_angular_trial = v_angular_sample_pts;

            res(i).luminance(il).data(trial_idx).trial_velocity = velocity_trial;
            res(i).luminance(il).data(trial_idx).trial_v_ang = v_angular_trial;

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

save([abs_path, out_filename], 'res');
disp(['SUCCESS: ', out_filename, ' saved for the "valid both + tail" tags.'])


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







