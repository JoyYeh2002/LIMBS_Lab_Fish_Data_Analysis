% fig05b03 loopy loop
% Loop through different kinds of averages and save plots
% Using curve 4 - 9 till end doesn't make a big difference
% Trend is still messy

% close all;
addpath 'helper_functions'

%% 1. Specify folder paths
parent_dir = fullfile(pwd, '..', '..');
abs_path = fullfile(parent_dir, 'data_structures\');
out_path = fullfile(parent_dir, 'figures\');

out_archive_path = fullfile(parent_dir, 'figures_archive\fig05b_tail_curv_all_fish\');
if ~exist(out_archive_path, 'dir')
    mkdir(out_archive_path);
end

pdf_path = fullfile(parent_dir, 'figures_pdf\');

close all

%% 2. Load the full body struct and tail FFT struct
all_fish = load(fullfile(abs_path, 'data_clean_body.mat'), 'all_fish').all_fish;
fishNames = {'Hope', 'Len', 'Doris', 'Finn', 'Ruby'}; % consistent with SICB

% Keep populating the res FFT struct
out_filename = 'result_tail_fft_and_curvature.mat';
res = load(fullfile(abs_path, out_filename), 'res').res;

p2m = 0.0004;
num_frames = 500;

% [INPUT]
% sample_fish_i = [1, 3]; % Select fish #1 to be in the final paper

%% 3. Calculate curvature and save to struct


y_lims = [140, 120, 80];

for fish_start_point = 6
y_lim = 160;

for i = 1 : 5
    h =  findobj('type','figure');
    n_fig = length(h);

    fish_name = fishNames{i};
    num_ils = numel(all_fish(i).luminance);

    for il = 1: num_ils
        num_trials = numel(all_fish(i).luminance(il).data);
        count = 1;

        % Add the new field
        res(i).luminances(il).tail_curvature = {};

        for trial_idx = 1 : num_trials
            f = all_fish(i).luminance(il).data(trial_idx);

            v = all_fish(i).luminance(il).data(trial_idx).valid_both;
            for rep = 1 : 3    
                valid = v(rep);
                if valid == 1
                    % Get meta data
                    field_name_x = ['x_rot_rep', num2str(rep)];
                    field_name_y = ['y_rot_rep', num2str(rep)];
                    x = f.(field_name_x);
                    y = f.(field_name_y);

                    radii = zeros(500, 10);
                    for ii = 1 : 500
                        [~,R,~] = curvature([x(ii, :)'*p2m*100,y(ii, :)'*p2m*100]); % Unit: cm
                        radii(ii, :) = 1./R(2:end-1);
                    end

                    res(i).luminances(il).tail_curvature{end+1} = radii; % radius of curvature
                    count = count + 1;
                end
            end
        end

        num_valid_trials = numel(res(i).luminances(il).x_tail);
        if num_valid_trials > 3
            % res(i).luminances(il).tail_curvature_mean = mean(cell2mat(res(i).luminances(il).tail_curvature),2);
       
            mean_trials = nan(500, num_valid_trials);
            for idx = 1 : num_valid_trials
                 data_elements = res(i).luminances(il).tail_curvature;
                 
                 % curv_arr = cell2mat(data_elements(:, idx)); % 500 x 10
                 % curv_arr_tail = mean(curv_arr(:, 6:end), 2);

                 % Get the 4th to end point
                 curv_arr = cell2mat(data_elements(:, idx)); % 500 x 10
                 curv_arr_tail = curv_arr(:, fish_start_point:end);

                 % Sum everything up
                 mean_trials(:, idx) = sum(curv_arr_tail, 2);
                 
            end
            res(i).luminances(il).tail_curvature_mean = mean(mean_trials, 2); % 500 x 1 double
            res(i).luminances(il).tail_curvature_sum = sum(mean(mean_trials, 2)); % all 500 frames summed
        
        else
            % Invalid, turn off the point
            res(i).luminances(il).tail_curvature_mean = [];
            res(i).luminances(il).tail_curvature_sum =0;
        
        end
    end
end

% Plot the different figs
data_targets = cell(5, 14); % Store sum for all fish
lux_vals = cell(5, 14);
lux = all_fish(1).lux_values;

for fish_idx = 1  : 5
    lux_cell = all_fish(fish_idx).lux_values;

    big_cell = struct2cell(res(fish_idx).luminances);

    % 14 levels total
    for col = 1:size(big_cell, 3)

        % Grab raw data (sum of all curvatures from body points 4 : end)
        data = big_cell{10, 1, col};
        this_lux = lux_cell(col);

        % Get rid of invalid points
        if data == 0
            this_lux = [];
            data = [];
        end

        % Populate big struct
        lux_vals{fish_idx, col} = this_lux;
        data_targets{fish_idx, col} = data;
    end
end

main_figure = figure('Position', [100, 50, 750, 500]);
fish_colors = jet(6);

hold on

default_colors = get(gca, 'ColorOrder');

% Plot the curvature sum data
for i = 1 : 5
   plot(cell2mat(lux_vals(i, :)), smooth(cell2mat(data_targets(i, :))), ...
       "LineWidth", 2, 'Marker', 'o', 'MarkerSize', 5, ...
       'MarkerFaceColor', default_colors(i, :));
end

% Set plot axes
set(gca, 'XScale', 'log');
xlabel('Illumination (lux)');
xticks(lux);
xticklabels(lux);
xlim([0, 220]);

ylabel('Fish Body Curvature Sum (cm)');
ylim([20, y_lim]);

grid('on');
legend('Fish 1', 'Fish 2', 'Fish 3', 'Fish 4', 'Fish 5');

title(['Fish Body points ', num2str(fish_start_point), ' to tail'])
subtitle('all 500 frames total curvature (cm) vs. Illuminance Levels (lux)');

saveas(main_figure, [out_archive_path, 'smooth_scaled_pt_', num2str(fish_start_point), '_all_curve_sum.png']);
disp("SUCCESS: all curve sum stats plot saved in archive.")



end
