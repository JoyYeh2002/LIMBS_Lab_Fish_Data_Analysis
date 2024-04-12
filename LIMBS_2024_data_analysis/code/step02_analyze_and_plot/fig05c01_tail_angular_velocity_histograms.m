%% fig05c_tail_angular_velocity_gaussian.m
% Updated 04.09.2024
% LIMBS Lab
% Author: Huanying (Joy) Yeh

% Experiment Name: Eigenmannia Virescens Luminance + Locomotion Comparisons
%
% Content:
% - Plot angular velocities (fig5c) in surface plot 
% - Loaded from "result_tail_rms_and_angular_velocity.mat."
% - Plot the following in "\figures"
%
% - "fig05c01_tail_angular_velocity_histograms.png"
%
% - These in "\figures_archive\fig05c_tail_velocity_distributions\"
% - All fish 3d histograms

close all;
addpath 'helper_functions'

%% 1. Specify folder paths
parent_dir = fullfile(pwd, '..', '..');
abs_path = fullfile(parent_dir, 'data_structures\');
out_path = fullfile(parent_dir, 'figures\');
pdf_path = fullfile(parent_dir, 'figures_pdf\');

out_archive_path = fullfile(parent_dir, 'figures_archive\fig05c_tail_ang_vel_surf\');
if ~exist(out_archive_path, 'dir')
    mkdir(out_archive_path);
end


%% 2. Load the full body struct and tail FFT struct
all_fish = load(fullfile(abs_path, 'data_clean_body.mat'), 'all_fish').all_fish;
res  = load(fullfile(abs_path, 'result_tail_rms_and_angular_velocity.mat'), 'res').res;

fishNames = {'Hope', 'Len', 'Doris', 'Finn', 'Ruby'}; % consistent with SICB
numFish = 5;
num_body_pts = 12;
resolution = 100;

lux_axis_limit = [0, 210];
z_limit = [0, 0.1];

%% Step16_plot_angular_velocity_distributions.m
%% 1. Load in the data
apply_smooth = 0;
view_coords = [30 30];
alpha = 1;

%% 2. [User inputs] for adjusting the plot
data_field = "v_ang";
map = magma;
target_body_pt = 12;

position_coords = [50, 50, 700, 450];

% Case statements


%% 3. Plot the waterfall
for i =  1 : numFish
    fish_name = fishNames{i};
    num_il_levels = numel(res(i).luminance);
    lux = res(i).lux_values;

    % data = res(i).velocities;
    data = res(i).(data_field);

    data_cell = data';

    edges = linspace(min(data_cell{2}(:)), max(data_cell{2}(:)), resolution+1); % Adjust the range based on your data
    hist_values = zeros(length(edges)-1, numel(data_cell));

    % Compute histograms for each array
    for k = 1:numel(data_cell)
        if ~isempty(data_cell{k})
        hist_values(:, k) = histcounts(data_cell{k}(:, target_body_pt), edges, 'Normalization', 'probability');
        end
    end

 
    % fig_out_path = [out_path, 'RMS_plots\04-09_Angular_Velocity\'];
    fig_out_path = [out_path, '\angular_velocity_real_plots\'];
    if ~exist(fig_out_path, 'dir')
        mkdir(fig_out_path);
    end
  
    fig_out_filename = [filename_prefix, num2str(view_coords), fish_name, '.png'];

    saveas(gcf, [fig_out_path, fig_out_filename]);
    disp(['SUCCESS: ', fig_out_filename, ' is saved.']);

end

