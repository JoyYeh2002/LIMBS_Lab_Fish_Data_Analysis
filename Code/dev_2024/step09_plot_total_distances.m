%% Step09_Total_Distance_Visualize.m
% [Updated 02.16.2024]
% Visualize trends of RMS with one fish
% Load in Hope for now
% rms_reps, trial_rms, dist_reps, trial_distances
%
% Observe the RMS trends across luminances
% Do more fish later
%
% All the experiment outputs are in
% C:\Users\joy20\Folder\FA_2023\LIMBS Presentations\Outputs\

% Spring 2024 semester
% updated 02/09/2024

%% 1. Load in the data
close all;

abs_path = 'C:\Users\joy20\Folder\FA_2023\LIMBS Presentations\data\fish_structs_2024\';
out_path = 'C:\Users\joy20\Folder\FA_2023\LIMBS Presentations\Outputs\';

struct_file = load([abs_path, 'res_RMS.mat']); % All the raw + cleaned data labels for Bode analyis
res = struct_file.res;

fishNames = {'Hope', 'Len', 'Doris', 'Finn', 'Ruby'}; % consistent with SICB
numFish = 5;
num_body_pts = 12;

%% 2. Collect RMS values from loop, then populate struct
for i = 1 : numFish 
    fish_name = fishNames{i};
    num_il_levels = numel(res(i).luminance);

    data = res(i).distMean;

    clolrmap = cool(num_body_pts);

    % Create a figure for plotting
    figure;
    
    % Plot each data point across the 14 conditions (in cm)
    for k = 1:num_body_pts
        plot(1:num_il_levels, data(:, k), '-o', 'Color', clolrmap(k, :),'LineWidth', 2, 'DisplayName', ['Data Point ', num2str(i)]); 
        hold on; 
    end

    % Add x and y labels
    xlabel('Luminance Levels');
    ylabel('RMS (cm)');
    
    % ylabel('Total Distances (cm)');

    % Add a color bar
    h = colorbar;  % Get the handle to the color bar
    custom_ticks = linspace(0, 1, num_body_pts); % Custom ticks for each body point
    set(h, 'Ticks', custom_ticks);
    set(h, 'TickLabels', num2cell(1:num_body_pts)); % Assuming body points are labeled numerically
    xlabel(h, 'Luminance Levels');
    ylabel(h, 'Body Points');
    xlim([1, num_il_levels]);
    ylim([0, 80]);

    % Remove legend
    legend('off');

    % Set color map
    colormap(clolrmap);

    title([fish_name, ' Body Points Total Swim Distances - ', num2str(num_il_levels), ' Il Levels Total']);
    % title([fish_name, ' All Luminance Levels Total Distances']);

    fig_out_path = [out_path, 'RMS_plots\'];
    if ~exist(fig_out_path, 'dir')
        mkdir(fig_out_path);
    end

    fig_out_filename = ['DIST_both_whole_body_', fish_name, '.png'];

    saveas(gcf, [fig_out_path, fig_out_filename]);
    disp(['SUCCESS: ', fig_out_filename, ' is saved.']);

end


