%% fig05c03_tail_angular_velocity_plotting.m
% Updated 04.09.2024
% LIMBS Lab
% Author: Huanying (Joy) Yeh

% Experiment Name: Eigenmannia Virescens Luminance + Locomotion Comparisons
%
% Content:
% - Plot the Gaussian fit of "result_tail_rms_and_angular_velocity.mat."


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

close all

%% 2. Load the full body struct and tail FFT struct
all_fish = load(fullfile(abs_path, 'data_clean_body.mat'), 'all_fish').all_fish;
res  = load(fullfile(abs_path, 'result_tail_rms_and_angular_velocity.mat'), 'res').res;

fishNames = {'Hope', 'Len', 'Doris', 'Finn', 'Ruby'}; % consistent with SICB
numFish = 5;
num_body_pts = 12;
resolution = 100;
lux_axis_limit = [0, 210];
z_limit = [0, 0.1];

%% 2. [User inputs] for adjusting the plot
data_field = "v_ang";
map = cool;
target_body_pt = 12;
apply_smooth = 0;

position_coords = [50, 50, 700, 450];
view_coords = [30 30];

% Case statements

% If head
if target_body_pt == 1
    if apply_smooth == 0
        plotname_prefix = ' Head Point Angular Velocity Distributions: ';
        filename_prefix = 'head_v_ang_hist_';
        x_label = 'Angular Velocity Distributions (rad/s)';
    end
    
    if apply_smooth == 1
        kb_kf = [5, 5];
        plotname_prefix = ' (Smoothed) Head Point Angular Velocity Distributions: ';
        filename_prefix = 'smooth_belly_v_ang_hist_';
        x_label = 'Smoothed Angular Velocity Distributions (deg/s)';     
    end

elseif target_body_pt == 12
    if apply_smooth == 0
        plotname_prefix = ' Tail Point Angular Velocity Distributions: ';
        filename_prefix = 'tail_v_ang_hist_log_';
        x_label = 'Angular Velocity Distributions (deg/s)';
    end
    
    if apply_smooth == 1
        kb_kf = [5, 5];
        plotname_prefix = ' (Smoothed) Tail Point Angular Velocity Distributions: ';
        filename_prefix = 'smooth_tail_v_ang_hist_log_';
        x_label = 'Smoothed Angular Velocity Distributions (deg/s)';
        
    end

else % for all other body points
    if apply_smooth == 0
        plotname_prefix = [' Body Point ', num2str(target_body_pt), ' Angular Velocity Distributions: '];
        filename_prefix = ['body_point_', num2str(target_body_pt), '_v_ang_hist_'];
        x_label = 'Angular Velocity Distributions (deg/s)';
    end
    
    if apply_smooth == 1
        kb_kf = [5, 5];
        plotname_prefix = [' (Smoothed) Body Point ', num2str(target_body_pt), ' Angular Velocity Distributions: '];
        filename_prefix = ['smooth_body_point_', num2str(target_body_pt), '_v_ang_hist_'];
        x_label = 'Smoothed Angular Velocity Distributions (deg/s)';
    end
end

%% 3. Plot the waterfall
for i =  1 : numFish
    fish_name = fishNames{i};
    num_il_levels = numel(res(i).luminance);
    lux = res(i).lux_values;

    % data = res(i).velocities;
    data = res(i).(data_field);

    data_cell = data';
    
    edges = linspace(min(data_cell{2}(:)), max(data_cell{2}(:)), resolution+1); % Adjust the range based on your data
    
    Z = zeros(length(edges)-1, numel(data_cell));

    % Compute histograms for each array

    lux_ticks = [];
    Z = []; % 14 x 99 double

    lux = all_fish(i).lux_values;
     num_ils = size(lux, 2);

     for il  = 1:num_ils

        if isempty(data_cell{il})
            continue;
        else
             h = histcounts(data_cell{il}(:, target_body_pt), edges, 'Normalization', 'probability');
             lux_ticks = [lux_ticks, lux(il)];
             Z = [Z; h]; 
        end
    end

    % [NEW] smooth out the histogram
    if apply_smooth == 1
        Z = movmean(Z, kb_kf); % Adjust window size as needed
    end

    [X, Y] = meshgrid(edges(1:end-1), lux_ticks);
    figure('Color', 'white', 'Position', position_coords);

    % p = waterfall(X, Y,Z' * 100);
    p = surf(X, Y, Z * 100);
    set(gca, 'YScale', 'log');
    % set(gca, 'ZScale', 'log');
    
    p.FaceAlpha = 0.7;
    p.EdgeColor = 'interp';
    p.LineWidth = 2;
    view(view_coords);

    xlabel(x_label);
    ylabel('Lux Values (log scale)')
    
    %yticks(lux);
    yticks([0, 0.2, 1, 2, 2.5, 5, 7, 9, 15, 60, 150, 210])

    zlabel('Probability (%)')
    ylim(lux_axis_limit);
    zlim(z_limit * 100);
    zticks([0, 5, 10, 15, 20, 30, 35])

    % Set ticks for the color bar
    colorbar;

    colormap(map);
    title([fish_name, plotname_prefix, num2str(num_il_levels), ' Luminance Levels']);

    fig_out_filename = [filename_prefix, num2str(view_coords), fish_name, '.png'];

    saveas(gcf, [out_archive_path, fig_out_filename]);
    disp(['SUCCESS: ', fig_out_filename, ' is saved.']);

end


