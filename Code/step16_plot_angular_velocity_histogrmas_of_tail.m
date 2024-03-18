%% Step16_plot_angular_velocity_distributions.m
% [Updated 02.23.2024]
% - Plot angular velocity distributions for various luminance levels
% - Histograms (waterfall plots)
% - Similar to step10: plot_velocity_distributions.m
% fig_out_filename = ['/RMS_plots/angular_velocity_tail_point/_', fish_name, '.png'];

%% 1. Load in the data
close all;

abs_path = 'C:\Users\joy20\Folder\FA_2023\LIMBS Presentations\data\fish_structs_2024\';
out_path = 'C:\Users\joy20\Folder\FA_2023\LIMBS Presentations\Outputs\';

struct_file = load([abs_path, 'result_rms_velocity_angular.mat']); % All the raw + cleaned data labels for Bode analyis
res = struct_file.res;

fishNames = {'Hope', 'Len', 'Doris', 'Finn', 'Ruby'}; % consistent with SICB
numFish = 5;
num_body_pts = 12;
resolution = 30;
lux_axis_limit = [0, 210];
z_limit = [0, 0.15];

%% 2. [User inputs] for adjusting the plot
data_field = "v_angular";
map = cool;
target_body_pt = 12;
apply_smooth = 1;

position_coords = [50, 50, 700, 450];
view_coords = [0 0];

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
    edges = linspace(min(data_cell{1}(:)), max(data_cell{1}(:)), resolution+1); % Adjust the range based on your data
    hist_values = zeros(length(edges)-1, numel(data_cell));

    % Compute histograms for each array
    for k = 1:numel(data_cell)
        hist_values(:, k) = histcounts(data_cell{k}(:, target_body_pt), edges, 'Normalization', 'probability');
    end

    % [NEW] smooth out the histogram
    if apply_smooth == 1
        hist_values = movmean(hist_values, kb_kf); % Adjust window size as needed
    end

    [X, Y] = meshgrid(edges(1:end-1), lux);
    figure('Color', 'white', 'Position', position_coords);


    p = waterfall(X, Y,hist_values' * 100);
    set(gca, 'YScale', 'log');
    set(gca, 'ZScale', 'log');
    
    p.FaceAlpha = 0.3;
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
    zticks([0, 1, 2, 3, 4, 5, 6, 7, 8, 10, 20, 30])

  


    % Set ticks for the color bar
    colorbar;
    % map = winter(num_il_levels);

    colormap(map);
    title([fish_name, plotname_prefix, num2str(num_il_levels), ' Luminance Levels']);

    fig_out_path = [out_path, 'RMS_plots\03-18_Angular_Velocity\'];
    if ~exist(fig_out_path, 'dir')
        mkdir(fig_out_path);
    end

    fig_out_filename = [filename_prefix, fish_name, '.png'];

    saveas(gcf, [fig_out_path, fig_out_filename]);
    disp(['SUCCESS: ', fig_out_filename, ' is saved.']);

end

