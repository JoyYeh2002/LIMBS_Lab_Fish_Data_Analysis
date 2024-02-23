%% Step14_re_save_rainbow_plots.m
% [Updated 02.19.2024]
% Content:
% - Use the clean tags to save "CLEAN" rainbow plots in chronological order
% - Refer to step03


%% 1. Load the big struct
close all;

abs_path = 'C:\Users\joy20\Folder\FA_2023\LIMBS Presentations\data\fish_structs_2024\';
out_dir_figures = 'C:\Users\joy20\Folder\FA_2023\LIMBS Presentations\Outputs\';
load([abs_path, 'RMS_temp_tags_both.mat']); % All the raw + cleaned data labels for Bode analyis

fishNames = {'Hope', 'Len', 'Doris', 'Finn', 'Ruby'}; % consistent with SICB
numFish = 5;

%% 2. User inputs / control panel to access a certain trial
plot_scatter_points = 0;
plot_on_time_scale = 1;


%% 3. Loop through everything
for k = 1 %:numFish
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

            % [NEW] Introduce the validity tags (clean both)
            v = data.valid_both;

            titles = {'Rep 01', 'Rep 02', 'Rep 03'};

            numPoints = size(data.x_data_raw, 2);
            myColorMap = jet(numPoints);

            % Create the main figure with initial width and height
            figureWidth = 600;  % Initial width (adjust as needed)
            figureHeight = 980;  % Initial height (adjust as needed)

            % Crete the timeline (seconds)
            time = 0 : 0.04 : 19.96;

            % Scattered rainbow plots
            if plot_scatter_points == 1
                mainFigure = figure('Position', [100, 30, figureWidth, figureHeight]);

                % Create each subplot (3 reps total)
                for i = 1 :numel(y)

                    if v(i) == 1

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
                end

                fig_out_path = [out_dir_figures, 'Scatter_', fish_name, '\'];
                if ~exist(fig_out_path, 'dir')
                    mkdir(fig_out_path);
                end

                fig_out_filename = [fish_name, '_il_', num2str(il), ...
                    '_trial_', num2str(trial_idx), '_', num2str(head_dir), '.png'];

                saveas(mainFigure, [fig_out_path, fig_out_filename]);
                disp(['SUCCESS: ', fig_out_filename, ' is saved.']);
            end

            % Time domain 12-point rainbow plots (20s each), 3 vertical
            % stacked panels
            if plot_on_time_scale == 1
                mainFigure = figure('Position', [100, 30, figureWidth, figureHeight]);

                % Create each subplot only if valid
                for i = 1 :numel(y) % there are 3 repetitions
                    if v(i) == 1
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
                end

                fig_out_path = [out_dir_figures, 'Rainbow_Plots_', fish_name,'\'];
                if ~exist(fig_out_path, 'dir')
                    mkdir(fig_out_path);
                end

                % fig_out_filename = [fish_name, '_TD_Tail_il_', num2str(il), ...
                %     '_trial_', num2str(trial_idx), '_', num2str(head_dir), '.png'];
                fig_out_filename = [fish_name, '_trial_', num2str(trial_idx), '_TD_Tail_il_', num2str(il), ...
                    '_', num2str(head_dir), '.png'];

                saveas(mainFigure, [fig_out_path, fig_out_filename]);
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

if validity == 1
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

else % if validity == 0
    subplot(3, 1, subplotNum);
    set(gcf, 'Visible', 'off');
    y_invalid = NaN(size(xData, 2));
    scatter(xData, y_invalid);
end

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

