% step14
% Solve for all the RMS and total displacements
% - for each trial: 
%  12x3 double (rms_reps)
%  12x1 double (trial_rms)
%  12x3 double (dist_reps)
%  12x1 double (trial_distances)
% - Only use the clean trials
% - Helper functions can be templates for future stuff

% All the experiment outputs are in
% C:\Users\joy20\Folder\FA_2023\LIMBS Presentations\Outputs\

% Spring 2024 semester
% updated 02/09/2024

% Locate the subject fish
abs_path = 'C:\Users\joy20\Folder\FA_2023\LIMBS Presentations\data\fish\';
out_path = 'C:\Users\joy20\Folder\FA_2023\LIMBS Presentations\Outputs\';

struct_file = load([out_path, 'rotated_fish_valid.mat']); % All the raw + cleaned data labels for Bode analyis
all_fish = struct_file.all_fish;
fish_names = {'Hope', 'Ruby', 'Len', 'Finn', 'Doris'};

% Loop settings
for fish_idx = 1 %: 5 % Now looking at fish #2
    fish_name = fish_names{fish_idx};

    for il = 1 : numel(all_fish(fish_idx).luminance)
        for trial_idx = 1 : numel(all_fish(fish_idx).luminance(il).data)

            % Grab the target data and calculate RMS
            data = all_fish(fish_idx).luminance(il).data(trial_idx); % This is Hope trial 30
            [rms_each_rep, trial_rms, dist_each_rep, trial_distances] = calculateCleanFullBodyRMS(data);

            % Populate the struct
            all_fish(fish_idx).luminance(il).data(trial_idx).rms_reps = rms_each_rep;
            all_fish(fish_idx).luminance(il).data(trial_idx).trial_rms = trial_rms;
            all_fish(fish_idx).luminance(il).data(trial_idx).dist_reps = dist_each_rep;
            all_fish(fish_idx).luminance(il).data(trial_idx).trial_distances = trial_distances;

        end
    end
end

save([out_path, 'RMS_temp_all.mat'], 'all_fish');
disp("Temp RMS struct saved.")

%% HELPER: Get the 12x3 and 12x1 RMS arrays
function [rms_displacement, trial_rms, total_displacement, trial_displacement] = calculateCleanFullBodyRMS(data)

v = data.validity;
p2m = 0.0002;
x = {data.x_rot_rep1 * p2m, data.x_rot_rep2 * p2m, data.x_rot_rep3 * p2m};
y = {data.y_rot_rep1 * p2m, data.y_rot_rep2 * p2m, data.y_rot_rep3 * p2m};

% Calculate displacement
displacement = cell(1, 3);
rms_displacement = zeros(12, 3); % These might have zeros if invalid
total_displacement = zeros(12, 3);

for i = 1 : size(x, 2) % Up to 3
    if v(i) == 1 % if this rep is valid
        displacement{i} = sqrt(diff(x{i}).^2 + diff(y{i}).^2);
        for p = 1 : 12
            rms_displacement(p, i) = sqrt(mean(displacement{i}(:, p).^2));
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
    trial_displacement(j) = sum(total_displacement(j, :))/num_valid_trials;
end
end


