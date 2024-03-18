%% Step10_plot_velocity_distributions.m
% [Updated 02.16.2024]
% - Plot velocity distributions for various luminance levels
% - Histograms (waterfall plots)
% - User can define which point to plot (from body to tail points)
% fig_out_filename = ['/RMS_plots/velocity_tail_point_', fish_name, '.png'];
%% Updated 03/18 for tail valid
%% Need to discuss further

%% 1. Load in the data
close all;

abs_path = 'C:\Users\joy20\Folder\FA_2023\LIMBS Presentations\data\fish_structs_2024\';
fig_out_path = 'C:\Users\joy20\Folder\FA_2023\LIMBS Presentations\Outputs\RMS\';

struct_file = load([abs_path, 'result_rms_velocity.mat']); % All the raw + cleaned data labels for Bode analyis
res = struct_file.res;

fishNames = {'Hope', 'Len', 'Doris', 'Finn', 'Ruby'}; % consistent with SICB
numFish = 5;
num_body_pts = 12;
resolution = 30;
lux_axis_limit = [0, 210];

%% 2. Collect RMS values from loop, then populate struct
for i = 1 : numFish
    fish_name = fishNames{i};
    num_il_levels = numel(res(i).luminance);

    lux = res(i).lux_values;
    data = res(i).velocities;

    data_cell = data';
    edges = linspace(min(data_cell{1}(:)), max(data_cell{1}(:)), resolution); % Adjust the range based on your data
    hist_values = zeros(length(edges)-1, numel(data_cell));

    % Compute histograms for each array
    for k = 1:numel(data_cell)
        hist_values(:, k) = histcounts(data_cell{k}(:, 12), edges, 'Normalization', 'probability');
    end

    % Create a meshgrid for plotting
    
    [X, Y] = meshgrid(edges(1:end-1), lux);
    

    % Plot the smooth 3D histogram
    figure('Color', 'white');
    
    % p = waterfall(X,Y,hist_values');
    p = surf(X,Y,hist_values' * 100);

    set(gca,'YScale','log')
    p.FaceAlpha = 0.3;
    p.EdgeColor = 'interp';
    p.LineWidth = 2;
    view([17 30])
    xlabel('Velocity Distributions')
    ylabel('Lux Values (log scale)')
    yticks(lux);

    zlabel('Probability (%)')
    ylim(lux_axis_limit);
    zlim([0, 0.30] * 100);

    % Set ticks for the color bar
    colorbar;

    title('0318 Smooth 3D Histogram of Velocity Distributions');

    map = copper(num_il_levels);
    colormap(map);
    title([fish_name, ' Body Points Velocity Distributions - ', num2str(num_il_levels), ' Il Levels Total']);
    % title([fish_name, ' All Luminance Levels Total Distances']);

    fig_out_filename = [fig_out_path, '03_18_velocity_tail_point_', fish_name, '.png'];

    saveas(gcf, fig_out_filename);
    disp(['SUCCESS: ', fig_out_filename, ' is saved.']);

end

