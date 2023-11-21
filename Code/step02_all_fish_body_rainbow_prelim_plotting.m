%% all_fish_tail_prlim_analysis.m
% Updated 10.27.2023
% LIMBS Lab
% Author: Huanying (Joy) Yeh

% Experiment Name: Eigenmannia Virescens Luminance + Locomotion Comparisons
% Content: Ruby Full Body Tracking and Prelim Analysis
% - Load in the data
% - Build data structure
% - FFT, position distributions, velocity, and curvature plots

%% 0. Load the big struct
close all;
abs_path = 'C:\Users\joy20\Folder\FA_2023\LIMBS Presentations\Data\';
out_dir_figures = 'C:\Users\joy20\Folder\FA_2023\LIMBS Presentations\Outputs\';
struct_filename = [abs_path, 'all_fish_full_length_data.mat'];

all_fish_data = load(struct_filename).all_fish_data;

% [REF] will be automatically looped
% directories = {'trial10_il_9_1\', ...
%     'trial26_il_3_-1\', ...
%     'trial32_il_6_1\', ...
%     'trial23_il_1_-1\', ...
%     'trial40_il_1_-1\'};
fishNames = {'Doris', 'Len', 'Ruby', 'Finn'};
for k = 1:numel(fishNames)
    fish_name = fishNames{k}
    fish_idx = queryStruct(all_fish_data, 'fish_name', fish_name);

    %% 1. User inputs / control panel to access a certain trial
    do_analysis_01 = 0;
    do_analysis_02 = 1;

    % disp('SUCCESS: running analysis_01: rainbow plots for tail swings.')
    disp('SUCCESS: running analysis_02: tail top time-domain.')
    for il = [1:9]
        % Loop thru all the trials under this il condition [TODO] Populate more
        for idx = 1 : numel(all_fish_data(fish_idx).luminance(il).data)
            trial_idx = all_fish_data(fish_idx).luminance(il).trial_indices(idx);
            data = all_fish_data(fish_idx).luminance(il).data(idx);
            head_dir = data.head_dir;

            % Create sample data
            x = {data.x_rep1, data.x_rep2, data.x_rep3};
            y = {data.y_rep1, data.y_rep2, data.y_rep3};
            titles = {'Rep 1', 'Rep 02', 'Rep 03'};
            numPoints = size(data.x_data_raw, 2);
            myColorMap = jet(numPoints);

            if do_analysis_01 == 1
                % Create the main figure with initial width and height
                figureWidth = 600;  % Initial width (adjust as needed)
                figureHeight = 900;  % Initial height (adjust as needed)
                mainFigure = figure('Position', [100, 30, figureWidth, figureHeight]);

                % Create each subplot
                for i = 1 :numel(y)
                    % Call the plotting function for the current subplot
                    if i == 1
                        title = [fish_name, ' Il = ', num2str(il), ' Trial #',...
                            num2str(trial_idx), ', Rep 01'];
                    else
                        title = titles{i};
                    end
                    plotScatterWithColorbar(i, x{i}, y{i}, myColorMap, title);
                end

                fig_out_path = [out_dir_figures, fish_name,'_Analysis01\'];
                fig_out_filename = [fish_name, '_il_', num2str(il), ...
                    '_trial_', num2str(trial_idx), '_', num2str(head_dir), '.png'];

                saveas(mainFigure, [fig_out_path, fig_out_filename]);
                % disp(['SUCCESS: ', fig_out_filename, ' is saved.']);
            end


            if do_analysis_02 == 1
              
                % Crete the timeline. Unit: seconds
                time = 0 : 0.04 : 19.96;
                % Create the main figure with initial width and height
                figureWidth = 600;  % Initial width (adjust as needed)
                figureHeight = 900;  % Initial height (adjust as needed)
                mainFigure = figure('Position', [100, 30, figureWidth, figureHeight]);

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
                    yLim = [0, 190];

                    plotTailPointTimeDomainScatterWithColorbar(i, time, y{i}, ...
                        xLim, yLim, myColorMap, title)

                end

                fig_out_path = [out_dir_figures, fish_name,'_Analysis02\'];
                if ~exist(fig_out_path, 'dir')
                    mkdir(fig_out_path);
                end
                
                fig_out_filename = [fish_name, '_TD_Tail_il_', num2str(il), ...
                    '_trial_', num2str(trial_idx), '_', num2str(head_dir), '.png'];

                saveas(mainFigure, [fig_out_path, fig_out_filename]);
                disp(['SUCCESS: ', fig_out_filename, ' is saved.']);
         
            end
        end
        disp([' ----- COMPLETED IL = ', num2str(il), '-----\n']);
    end
    disp('SUCCESS: ALL PLOTS GENERATED.')
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
ylim([0, 190]);
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
