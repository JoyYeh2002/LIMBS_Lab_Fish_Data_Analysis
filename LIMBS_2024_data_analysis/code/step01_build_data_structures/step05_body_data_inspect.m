%% Step05_body_data_inspect.m
% Updated 03.23.2024
% LIMBS Lab
% Author: Huanying (Joy) Yeh

% Experiment Name: Eigenmannia Virescens Luminance + Locomotion Comparisons
%
% Content:
% - [optional] Run this to verify results. Feel free to skip it for further analysis.
% - Use "data_clean_body.mat", generate two kinds of "rainbow plots"
% - These help users visulaly inspect all trials to detect tracking losses
% - Next step leads to creating "body bad tags"
% - Output: save figures to
% "figures_archive/position_scatterplots" and
% "figures_archive/position_timeline"

%% 1. Load the big struct
close all;

parent_dir = fullfile(pwd, '..', '..');
abs_path = fullfile(parent_dir, 'data_structures\');
out_path = fullfile(parent_dir, 'figures_archive\');
all_fish = load(fullfile(abs_path, 'data_clean_body.mat'), 'all_fish').all_fish; 

fishNames = {'Hope', 'Len', 'Doris', 'Finn', 'Ruby'}; % consistent with SICB
numIls = [14, 9, 11, 9, 9];
numFish = 5;
numPoints = 12;

%% 2. User inputs / control panel to access a certain trial
plot_scatter_points = 0;
plot_on_time_scale = 1;

%% 3. Loop through everything
for k = 1 : numFish
    fish_name = fishNames{k};
    fish_idx = queryStruct(all_fish, 'fish_name', fish_name);

    % Prep data
    for il = 1 : numel(all_fish(fish_idx).luminance)

        % Loop thru all the trials under this il condition
        for idx = 1 : numel(all_fish(fish_idx).luminance(il).data)
            trial_idx = all_fish(fish_idx).luminance(il).trial_indices(idx);
            data = all_fish(fish_idx).luminance(il).data(idx);
            head_dir = data.head_dir;

            % Use rotated implementation
            x = {data.x_rot_rep1, data.x_rot_rep2, data.x_rot_rep3};
            y = {data.y_rot_rep1, data.y_rot_rep2, data.y_rot_rep3};

            titles = {'Rep 01', 'Rep 02', 'Rep 03'};
            myColorMap = jet(numPoints);

            % Create the main figure with initial width and height
            fig_width = 600;  % Initial width (adjust as needed)
            fig_height = 980;  % Initial height (adjust as needed)

            % Crete the timeline (seconds)
            time = 0 : 0.04 : 19.96;

            % Scattered rainbow plots
            if plot_scatter_points == 1
                main_figure = figure('Position', [100, 30, fig_width, fig_height]);

                % Create each subplot
                for i = 1 :numel(y)
                    % Call the plotting function for the current subplot
                    if i == 1
                        title = [fish_name, ' Il = ', num2str(il), ' Trial #',...
                            num2str(trial_idx), ', Rep 01'];
                    else
                        title = titles{i};
                    end

                    % Plot with helper function
                    plotScatterWithColorbar(i, x{i}, y{i}, myColorMap, title);
                end

                fig_out_path = [out_path, 'position_scatterplots\', fish_name, '\'];
                if ~exist(fig_out_path, 'dir')
                    mkdir(fig_out_path);
                end

                fig_out_filename = [fish_name, '_il_', num2str(il), ...
                    '_trial_', num2str(trial_idx), '_', num2str(head_dir), '.png'];

                saveas(main_figure, [fig_out_path, fig_out_filename]);
                disp(['SUCCESS: ', fig_out_filename, ' is saved.']);
            end

            % Time domain 12-point rainbow plots (20s each), 3 vertical
            % stacked panels
            if plot_on_time_scale == 1
                main_figure = figure('Position', [100, 30, fig_width, fig_height]);

                % Create each subplot
                for i = 1 :numel(y) % there are 3 repetitions
                    % Call the plotting function for the current subplot
                    if i == 1
                        title = [fish_name, ' Tail TD Positions, Il = ', num2str(il), ' Trial #',...
                            num2str(trial_idx), ' (20s), Rep 01'];
                    else
                        title = titles{i};
                    end

                    xLim = [0, 20]; % timeline x-axis is out of 20 seconds
                    yLim = [-50, 250];

                    % Plot with helper function
                    plotTailPointTimeDomainScatterWithColorbar(i, time, y{i}, ...
                        xLim, yLim, myColorMap, title)
                end

                % fig_out_path = [out_path, 'position_timelines\', fish_name,'\'];
                fig_out_path = [out_path, 'tail_timelines\', fish_name,'\'];
                if ~exist(fig_out_path, 'dir')
                    mkdir(fig_out_path);
                end

                fig_out_filename = [fish_name, '_TD_Tail_il_', num2str(il), ...
                    '_trial_', num2str(trial_idx), '_', num2str(head_dir), '.png'];

                saveas(main_figure, [fig_out_path, fig_out_filename]);
                disp(['SUCCESS: ', fig_out_filename, ' is saved.']);
            end
        end
    end
    disp(['SUCCESS: ALL PLOTS GENERATED FOR FISH ', fish_name, '.'])
end

%% Helper: Find struct by field name
function i = queryStruct(struct, fieldName, query)
for i = 1:numel(struct)
    if isfield(struct(i), fieldName) && isequal(struct(i).(fieldName), query)
        return;
    end
end
end

%% Helper: Analysis 01: rainbow in a subplot
function plotScatterWithColorbar(subplotNum, xData, yData, myColorMap, titleText)

subplot(3, 1, subplotNum);
set(gcf, 'Visible', 'off');
numPoints = size(xData, 2);

% Plot all columns with the jet colormap
hold on;
for col = 1:numPoints
    scatter(xData(:, col), yData(:, col), 10, myColorMap(col, :), 'filled');
end
hold off;

colormap(myColorMap);

% Custom color bar
h = colorbar;  % Get the handle to the color bar
custom_ticks = [0, 0.5, 1];
custom_labels = {'Head', 'FMiddle', 'Tail'};

title(h, 'Fish');
set(h, 'XTick', custom_ticks);
set(h, 'XTickLabel', custom_labels);

xlim([0, 640]); % The axis bounds are the same as the camera frame size
ylim([-50, 250]);
xlabel("X-Pos (pixel)")
ylabel("Y-Pos (pixel)")

title(titleText);

grid on;
end

%% Helper: Analysis 02: tail point t-d movement a 3-panel vertical subplot
function plotTailPointTimeDomainScatterWithColorbar(subplotNum, time, yData, ...
    xLim, yLim, myColorMap, titleText)

subplot(3, 1, subplotNum);
set(gcf, 'Visible', 'off');
numPoints = size(yData, 2); % Use all 12 points

% Plot all columns with the jet colormap

hold on;
for col = 1:numPoints
    plot(time, yData(:, col), 'Color', myColorMap(col, :), 'LineWidth', 2);
end
hold off;
colormap(myColorMap);

% Custom color bar
h = colorbar;  % Get the handle to the color bar
custom_ticks = [0, 0.5, 1];
custom_labels = {'Head', 'FMiddle', 'Tail'};

title(h, 'Fish');
set(h, 'XTick', custom_ticks);
set(h, 'XTickLabel', custom_labels);

xlim(xLim);
ylim(yLim);
xlabel("Time(s)")
ylabel("Y-Pos (pixel)")
title(titleText);

grid on;
end

