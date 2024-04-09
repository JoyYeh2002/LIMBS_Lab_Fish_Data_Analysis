%% fig05b_tail_curvature_histogram.m
% LIMBS Lab
% Author: Huanying (Joy) Yeh

% Experiment Name: Eigenmannia Virescens Luminance + Locomotion Comparisons
%
% Content:
% - Calculate and save tail curvature info to "result_tail_curvature.mat"
% - Plot "fig05b_tail_curvature_histogram.png"
%
% Caution:
% - Need to run "fig04b_tail_fft_position_and_velocity.m

close all;
addpath 'helper_functions'

%% 1. Specify folder paths
parent_dir = fullfile(pwd, '..', '..');
abs_path = fullfile(parent_dir, 'data_structures\');
out_path = fullfile(parent_dir, 'figures\');

out_archive_path = fullfile(parent_dir, 'figures_archive\fig05b_tail_curvature\');
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

figure('Position', [100, 50, 750, 500]);
fish_colors = jet(6);

hold on

default_colors = get(gca, 'ColorOrder');

% Plot the curvature sum data
for i = 1 : 5
   plot(cell2mat(lux_vals(i, :)), cell2mat(data_targets(i, :)), ...
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
ylim([20, 200]);

grid('on');
legend('Fish 1', 'Fish 2', 'Fish 3', 'Fish 4', 'Fish 5');

title('Fish Body (points 4 - 10) all 500 frames body curvature (cm)')
subtitle('vs. Illuminance Levels');


% Save all images to archive folder
% saveas(main_figure, [out_archive_path, fish_name, '.png']);

% Save sample fish as official paper figure
% if ismember(i, sample_fish_i)
%     saveas(main_figure, [out_path, 'fig04b_tail_FFT_vs_illuminance_', fish_name, '.png']);
%     saveas(main_figure, [pdf_path, 'fig04b_tail_FFT_vs_illuminance_', fish_name, '.pdf']);
% end
%
% disp(['SUCCESS: ', 'fig04b_tail_FFT_vs_illuminance_', fish_name, ' is saved.']);
% end
%
% save([abs_path, 'result_tail_fft.mat'], 'res');
% disp("Tail FFT information saved in 'result_tail_fft.mat'.")




