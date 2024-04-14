%% fig05c01_tail_velocity_gaussian.m
% Updated 04.09.2024
% LIMBS Lab
% Author: Huanying (Joy) Yeh

% Experiment Name: Eigenmannia Virescens Luminance + Locomotion Comparisons
%
% Content:
% - Calculat and plot the gaussian param changes
% 
% - Distribution of angular velocities, tail point 12, then histogram
% - Then fit the Gaussian distribution, save sigma and peak
% - Then plot the Gaussian sigma situations + angular velocity
%
% - "fig05c_tail_angular_velocity_gaussian.png"
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
z_limit = [0, 0.14];

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

plotname_prefix = ' Tail Point Angular Velocity Distributions: ';
filename_prefix = 'tail_v_ang_hist_log_';
x_label = 'Angular Velocity Distributions (deg/s)';

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

  
    fig_out_filename = [filename_prefix, num2str(view_coords), fish_name, 'surf.png'];

    saveas(gcf, [fig_out_path, fig_out_filename]);
    disp(['SUCCESS: ', fig_out_filename, ' is saved.']);

end

