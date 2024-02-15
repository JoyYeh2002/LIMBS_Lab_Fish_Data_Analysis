% step15
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

% Load in the data
close all;

abs_path = 'C:\Users\joy20\Folder\FA_2023\LIMBS Presentations\data\fish\';
out_path = 'C:\Users\joy20\Folder\FA_2023\LIMBS Presentations\Outputs\';

struct_file = load([out_path, 'RMS_temp_all_RMS_fixed.mat']); % All the raw + cleaned data labels for Bode analyis
all_fish = struct_file.all_fish;
fish_names = {'Hope', 'Ruby', 'Len', 'Finn', 'Doris'};
num_body_pts = 12;

% Loop settings
for fish_idx = [1, 2, 3, 4, 5] %: 5 % Now looking at fish #2
    fish_name = fish_names{fish_idx};

    % Make a container for all il levels for comparisons
    num_il_levels = numel(all_fish(fish_idx).luminance);
    this_fish_rms = cell(num_il_levels, 1);
    this_fish_dist = cell(num_il_levels, 1);

    for il = 1 : num_il_levels

        % make a container for this il level, range = 5 trials here
        num_trials = numel(all_fish(fish_idx).luminance(il).data);

        % Collect over all body points
        this_il_rms = zeros(num_trials, 12);
        this_il_dist = zeros(num_trials, 12);

        for trial_idx = 1 : num_trials
            % Grab data from struct (12x1), (12x1). (no longer considering
            % each rep)
            trial_rms = all_fish(fish_idx).luminance(il).data(trial_idx).trial_rms;
            trial_dist = all_fish(fish_idx).luminance(il).data(trial_idx).trial_distances;

            this_il_rms(trial_idx, :) = trial_rms;
            this_il_dist(trial_idx, :) = trial_dist;

        end

        this_fish_rms{il} = this_il_rms;
        this_fish_dist{il} = this_il_dist;
    end


    % Use a 14x12 matrix to contain the average RMS data
    this_fish_rms_avg = zeros(num_il_levels, num_body_pts);
    this_fish_dist_avg = zeros(num_il_levels, num_body_pts);

    for il = 1 : num_il_levels
        this_fish_rms_avg(il, :) = nanmean(this_fish_rms{il}, 1);
        % this_fish_dist_avg(il, :) = nanmean(this_fish_dist{il}, 1);
    end


    % Sample data (replace this with your actual 14x12 array)
    % Sample data (replace this with your actual 14x12 array)
    
    data = this_fish_rms_avg;
    % data = this_fish_dist_avg;


    % Create a figure for plotting
    figure;
    map = jet(num_body_pts);

    % Plot each data point across the 14 conditions (in meters)
    for i = 1:num_body_pts
        plot(1:num_il_levels, data(:, i), '-o', 'Color', map(i, :),'LineWidth', 2, 'DisplayName', ['Data Point ', num2str(i)]); % Plot data point with markers and set display name
        hold on; % Hold the plot for overlaying multiple lines
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
    ylim([0, 1]);

    % Remove legend
    legend('off');

    % Set color map
    colormap(map);

    title([fish_name, ' All Luminance Levels RMS']);

    % title([fish_name, ' All Luminance Levels Total Distances']);


    fig_out_path = [out_path, 'RMS_plots\'];
    if ~exist(fig_out_path, 'dir')
        mkdir(fig_out_path);
    end

    fig_out_filename = ['RMS_y_whole_body_', fish_name, '.png'];

    saveas(gcf, [fig_out_path, fig_out_filename]);
    disp(['SUCCESS: ', fig_out_filename, ' is saved.']);

end


