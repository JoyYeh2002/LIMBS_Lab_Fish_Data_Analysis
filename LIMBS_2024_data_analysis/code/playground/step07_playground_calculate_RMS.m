%% Step07_RMS_Velocity_Calculations.m
% Makes result_rms_velocity.mat

%% 1. Load the data
mode = 'dev'

abs_path = 'C:\Users\joy20\Folder\SP_2024\LIMBS_2024_data_analysis\code\playground\';
struct_file = load([abs_path, 'data_clean_body_', mode, '.mat']); % All the raw + cleaned data labels for Bode analyis
all_fish = struct_file.all_fish;

out_path = [abs_path, '\RMS_ALL_plot_', mode, '\'];
if ~exist(out_path, 'dir')
    mkdir(out_path)
end

fig_out_filename = [mode, '_tail_rms.png'];

fishNames = {'Hope', 'Len', 'Doris', 'Finn', 'Ruby'}; % consistent with SICB
numFish = 5;
num_body_pts = 12;

%% 2. Use the "result" struct to store outputs at rep and luminance abstraction levels
res = struct();

for i = 1 : numFish

    res(i).name = fishNames{i};

    % Create containers for higher-level data structures (avg over all
    % trials and reps)
    num_il_levels = numel(all_fish(i).luminance);

    this_fish_rms = cell(num_il_levels, 1);
    this_fish_dist = cell(num_il_levels, 1);
    this_fish_velocity = cell(num_il_levels, 1);

    for il = 1 : num_il_levels

        % make a container for this il level, range = 5 trials here
        num_trials = numel(all_fish(i).luminance(il).data);

        % Collect over all body points
        this_il_rms = zeros(num_trials, 12);
        this_il_dist = zeros(num_trials, 12);
        this_il_velocity = []; % zeros([num_trials, 3, 499, 12]);

        for trial_idx = 1 : num_trials

            % Grab the target data and calculate RMS
            data = all_fish(i).luminance(il).data(trial_idx); % This is Hope trial 30

            [rms_each_rep, trial_rms, dist_each_rep, trial_distances] = calculateCleanFullBodyRMS(data);
            [velocity_each_rep, trial_velocities, num_samples] = calculateCleanFullBodyVelocity(data);
     
            %% 3. Populate the struct
            res(i).luminance(il).data(trial_idx).trID = data.trial_idx;
            res(i).luminance(il).data(trial_idx).rms_reps = rms_each_rep';
            res(i).luminance(il).data(trial_idx).trial_rms = trial_rms';
            
            res(i).luminance(il).data(trial_idx).dist_reps = dist_each_rep';
            res(i).luminance(il).data(trial_idx).trial_distances = trial_distances';
            res(i).luminance(il).data(trial_idx).trial_velocity = trial_velocities;

            this_il_rms(trial_idx, :) = trial_rms';
            this_il_dist(trial_idx, :) = trial_distances';
            this_il_velocity = [this_il_velocity; trial_velocities];

        end

        % Populate at high level 
        this_fish_rms{il} = this_il_rms;
        this_fish_dist{il} = this_il_dist;
        this_fish_velocity{il} = this_il_velocity;
    end

    % Use a 14x12 matrix to contain the average RMS data
    this_fish_rms_avg = zeros(num_il_levels, num_body_pts);
    this_fish_dist_avg = zeros(num_il_levels, num_body_pts);

    for il = 1 : num_il_levels
        this_fish_rms_avg(il, :) = nanmean(this_fish_rms{il}, 1);
        this_fish_dist_avg(il, :) = nanmean(this_fish_dist{il}, 1);
    end
    
    res(i).lux_values = all_fish(i).lux_values;
    res(i).rmsMean = this_fish_rms_avg;
    res(i).distMean = this_fish_dist_avg;
    res(i).velocities = this_fish_velocity;

end

save([abs_path, 'result_rms_velocity_', mode, '.mat'], 'res');
disp("SUCCESS: RMS + Fish velocity struct saved for the 'valid both' tags.")

% -------------------------- Step 08 Starts Here --------------------------
target_pt = 12; % only look at tail
field_name = 'rmsMean';
num_fish = 5;
colorMap = cool(6);

figure;
hold on;
set(gca, 'XScale', 'log'); % Set log scale for x-axis

%% 2. Gather data
all_lux = [];
all_data_pts = [];
all_data_pts_processed = [];

for i = 1:num_fish
    this_data = res(i).(field_name);
    this_data = this_data(:, 12);
    all_data_pts = [all_data_pts; this_data];
end

mean_value_all = mean(all_data_pts);

for i = 1:num_fish
    lux = res(i).lux_values;
    fish_name = fishNames{i};

    data = res(i).(field_name);
    data = data(:, 12);
    mean_value_this = mean(data);

    %% Centered, then smoothed for x-variance values
    data_smoothed_centered = smooth(data - (mean_value_this - mean_value_all));
   
    all_lux = [all_lux, lux];
    all_data_pts_processed = [all_data_pts_processed; data_smoothed_centered];

    plot(lux, data_smoothed_centered, '-', 'Color', colorMap(i, :), 'LineWidth', 2, 'Marker', 'o', 'MarkerSize', 3, 'MarkerFaceColor', colorMap(i, :));
end

%% 3. Fit sigmoid function then plot it
x = log(all_lux');
y = all_data_pts_processed;
[fitted_model, gof] = createSigmoidFit(x, y);

num_sample_points = 500;
x_sample_points = linspace(min(x), max(x), num_sample_points);
y_sample_points = feval(fitted_model, x_sample_points);
a = fitted_model.a;
b = fitted_model.b;
c = fitted_model.c;
d = fitted_model.d;

plot(exp(x_sample_points), y_sample_points, 'Color', 'k', 'LineWidth', 3)

grid on; % Display grid
title([mode, '_All Fish ', strrep(field_name, '_', ' '), ' Distributions']); % Set plot title
subtitle(['Fitted Sigmoid: a=', num2str(a), ', b=', num2str(b), ...
    ', c=', num2str(c), ', d=', num2str(d)]);

x_ticks = res(1).lux_values;
xticks(res(1).lux_values);
xticklabels(x_ticks);

xlim([0, 220]);

xlabel('Illuminance (lux)');
ylabel('Tail Point RMS Postion (cm^2)')
legend('Fish 1', 'Fish 2', 'Fish 3', 'Fish 4', 'Fish 5', ['Fitted Sigmoid: R^2 = ', num2str(gof.rsquare)], 'Location', 'southwest'); % Add legend

%% 4. Save to figure
saveas(gcf, [out_path, fig_out_filename]);
disp(['SUCCESS: ', fig_out_filename, ' is saved.']);


%% Helper: Sigmoid parameters generated by MATLAB on 12-Mar-2024 15:48:24
function [fitresult, gof] = createSigmoidFit(x, y)
 
[xData, yData] = prepareCurveData( x, y );

ft = fittype( 'a/(1+exp(-b*(x-c)))+d', 'independent', 'x', 'dependent', 'y' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.StartPoint = [0.933993247757551 0.678735154857773 0.757740130578333 0.743132468124916];

[fitresult, gof] = fit( xData, yData, ft, opts );
end


%% HELPER: Calculate x and y combined velocity distributions (clean trials only)
% Lots of sample points, such as il = 4 has 2994 x 12 array
function [velocity_reps, velocity_sample_pts, num_samples] = calculateCleanFullBodyVelocity(data)
time_diff = 0.04;
v = data.valid_both; 

p2m = 0.0002; % [CAUTION] velocity is in m/s
x = {data.x_rot_rep1 * p2m, data.x_rot_rep2 * p2m, data.x_rot_rep3 * p2m};
y = {data.y_rot_rep1 * p2m, data.y_rot_rep2 * p2m, data.y_rot_rep3 * p2m};

velocity_reps = cell(1, 3);
velocity_sample_pts = []; % This stores all the velocity data points of this trail (all valids reps)
velocity_angular_reps = cell(1, 3);
velocity_sample_pts = []; 
for i = 1 : 3
    if v(i) == 1 % if this rep is valid

        % Calculate displacements
        displacements_x = diff(x{i});
        displacements_y = diff(y{i});
        
        displacement =  sqrt(diff(x{i}).^2 + diff(y{i}).^2);
        result = displacement / time_diff;

        velocity_reps{i}= result;
        velocity_sample_pts = [velocity_sample_pts; result];

         % Calculate angular displacements
        angles = atan2(displacements_y, displacements_x);
        angular_displacements = diff(unwrap(angles)); % Unwrap angles to handle discontinuities
        
        % Calculate angular velocities
        angular_velocities{i} = angular_displacements / time_diff;


    else
        velocity_reps{i}= zeros(499, 12);
    end
end
num_samples = size(velocity_sample_pts, 1);
end


%% HELPER: Get the 12x3 and 12x1 RMS arrays
function [rms_displacement, trial_rms, total_displacement, trial_displacement] = calculateCleanFullBodyRMS(data)

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
trial_rms = zeros(12, 1); % only has 12 points
trial_displacement = zeros(12, 1);
num_valid_trials = sum(v);
for j = 1 : 12
    trial_rms(j) = sum(rms_displacement(j, :)) / num_valid_trials;
    trial_displacement(j) = sum(total_displacement(j, :)) / num_valid_trials;
end
end



