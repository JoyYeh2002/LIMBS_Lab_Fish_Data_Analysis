%% Step 12: Pilot Body Rotated / Rainbow Plot
% Comparison of Len Il = 4, Trial 31 (body was visibly slanted)
% Check angle correction
% Updated 01.22.2024
% LIMBS Lab
% Author: Huanying (Joy) Yeh

%% 0. Load the big struct
close all;

abs_path = 'C:\Users\joy20\Folder\FA_2023\LIMBS Presentations\data\';
out_dir_figures = 'C:\Users\joy20\Folder\FA_2023\LIMBS Presentations\Outputs\';
out_path = 'C:\Users\joy20\Folder\FA_2023\LIMBS Presentations\Outputs\step10_fish_rotation\';
test_subject = 'len_il_4_trial_31\';
struct_file = load([out_path, 'rotated_fish.mat']); % All the raw + cleaned data labels for Bode analyis
all_fish_data = struct_file.mBody.all_fish_data;

% Locate the subject fish
fish_idx = 3;
luminance_lvl = 4;
tr_idx = 2;


fishNames = {'Len', 'Hope', 'Ruby', 'Finn', 'Doris'};

for k = 1:numel(fishNames)
    fish_name = fishNames{k};
    fish_idx = queryStruct(all_fish_data, 'fish_name', fish_name);

    %% 1. User inputs / control panel to access a certain trial
    do_analysis_01 = 1;
    do_analysis_02 = 0;

    disp('SUCCESS: running analysis_02: tail top time-domain.')
    for il = 1 : numel(all_fish_data(fish_idx).luminance) 
       
        % Loop thru all the trials under this il condition [TODO] Populate more
        for idx = 1 : numel(all_fish_data(fish_idx).luminance(il).data)
            trial_idx = all_fish_data(fish_idx).luminance(il).trial_indices(idx);
            data = all_fish_data(fish_idx).luminance(il).data(idx);
            head_dir = data.head_dir;

            % Create sample data
            % x = {data.x_rep1, data.x_rep2, data.x_rep3};
            % y = {data.y_rep1, data.y_rep2, data.y_rep3};

            % [NEW] Use rotated implementation
            x = {data.x_rot_rep1, data.x_rot_rep2, data.x_rot_rep3};
            y = {data.y_rot_rep1, data.y_rot_rep2, data.y_rot_rep3};

            titles = {'Rep 1_rot', 'Rep 02_rot', 'Rep 03_rot'};
            
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

                fig_out_path = [out_dir_figures, 'Rotated_Analysis01_', fish_name, '\'];
                if ~exist(fig_out_path, 'dir')
                    mkdir(fig_out_path);
                end
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

                fig_out_path = [out_dir_figures, fish_name,'_Rotated_Analysis02\'];
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
