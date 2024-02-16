%% Step10_plot_velocity_distributions.m
% [Updated 02.16.2024]
% Plot velocity distributions for various luminance levels
% Histograms

%% 1. Load in the data
close all;

abs_path = 'C:\Users\joy20\Folder\FA_2023\LIMBS Presentations\data\fish_structs_2024\';
out_path = 'C:\Users\joy20\Folder\FA_2023\LIMBS Presentations\Outputs\';

struct_file = load([abs_path, 'res_RMS_VELOCITY.mat']); % All the raw + cleaned data labels for Bode analyis
res = struct_file.res;

fishNames = {'Hope', 'Len', 'Doris', 'Finn', 'Ruby'}; % consistent with SICB
numFish = 5;
num_body_pts = 12;

%% 2. Collect RMS values from loop, then populate struct
for i = 1 : numFish
    fish_name = fishNames{i};
    num_il_levels = numel(res(i).luminance);

    data = res(i).velocities;

    data_cell = data';

    % Create edges for histogram bins
    edges = linspace(min(data_cell{1}(:)), max(data_cell{1}(:)), 100); % Adjust the range based on your data

    % Initialize a matrix to store histogram values for each array
    hist_values = zeros(length(edges)-1, numel(data_cell));

    % Compute histograms for each array
    for k = 1:numel(data_cell)
        hist_values(:, k) = histcounts(data_cell{k}(:, 12), edges, 'Normalization', 'probability');
    end

    % Create a meshgrid for plotting
    [X, Y] = meshgrid(edges(1:end-1), 1:numel(data_cell));
    %[X, Y] = meshgrid(linspace(0.01, 0.04, 99), 1:numel(data_cell));


    % Plot the smooth 3D histogram
    figure('Color', 'white');
    % surf(X, Y, hist_values', 'EdgeColor', 'none');
    % p = waterfall(X,Y,smoothdata((Z),2,"movmean",3));
    p = waterfall(X,Y,hist_values');

    p.FaceAlpha = 0.3;
    p.EdgeColor = 'interp';
    p.LineWidth = 2;
    view([17 30])
    xlabel('Velocity Distributions')
    ylabel('Illumination Levels')
    yticks(1:numel(data_cell));

    zlabel('Probability')
    zlim([0, 0.2]);

    % Set ticks for the color bar
    colorbar;

    title('Smooth 3D Histogram of Velocity Distributions');

    map = copper(num_il_levels);
    colormap(map);
    title([fish_name, ' Body Points Velocity Distributions - ', num2str(num_il_levels), ' Il Levels Total']);
    % title([fish_name, ' All Luminance Levels Total Distances']);

    fig_out_path = [out_path, 'RMS_plots\'];
    if ~exist(fig_out_path, 'dir')
        mkdir(fig_out_path);
    end

    fig_out_filename = ['velocity_tail_point_', fish_name, '.png'];

    saveas(gcf, [fig_out_path, fig_out_filename]);
    disp(['SUCCESS: ', fig_out_filename, ' is saved.']);

end

