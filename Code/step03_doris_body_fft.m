%% step03_doris_tail_FFT.m
% Updated 11.17.2023
% LIMBS Lab
% Author: Huanying (Joy) Yeh

% Experiment Name: Eigenmannia Virescens Luminance + Locomotion Comparisons
% Content: Ruby Full Body Tracking and Prelim Analysis
% - Load in the data structure
% - FFT

%% 0. Load the big struct
close all;
abs_path = 'C:\Users\joy20\Folder\FA_2023\LIMBS Presentations\Data\';
out_dir_figures = 'C:\Users\joy20\Folder\FA_2023\LIMBS Presentations\Outputs\';
struct_filename = [abs_path, 'all_fish_full_length_data.mat'];

all_fish_data = load(struct_filename).all_fish_data;

% fishNames = {'Doris', 'Len', 'Ruby', 'Finn'};
fishNames = {'Ruby'};
for k = 1:numel(fishNames)
    fish_name = fishNames{k}
    fish_idx = queryStruct(all_fish_data, 'fish_name', fish_name);

    %% 1. User inputs / control panel to access a certain trial
    do_fft_analysis = 1;
    do_analysis_02 = 0;

    % disp('SUCCESS: running analysis_01: rainbow plots for tail swings.')
    disp('SUCCESS: running analysis_02: tail top time-domain.')
    for il = 2
        % Loop thru all the trials under this il condition [TODO] Populate more
        trial_idx = 36
        % for idx = numel(all_fish_data(fish_idx).luminance(il).data)
        %     trial_idx = all_fish_data(fish_idx).luminance(il).trial_indices(idx);
            data = all_fish_data(fish_idx).luminance(il).data(5);
            head_dir = data.head_dir;

            % Create sample data
            x = {data.x_rep1, data.x_rep2, data.x_rep3};
            y = {data.y_rep1, data.y_rep2, data.y_rep3};
            titles = {'Rep 1', 'Rep 02', 'Rep 03'};
            numPoints = size(data.x_data_raw, 2);
            myColorMap = jet(numPoints);

            if do_analysis_02 == 1
                % Crete the timeline. Unit: seconds
                time = 0 : 0.04 : 19.96;
                % Create the main figure with initial width and height
                figureWidth = 600;  % Initial width (adjust as needed)
                figureHeight = 900;  % Initial height (adjust as needed)
                mainFigure = figure('Position', [80, 15, figureWidth, figureHeight]);

                % Create each subplot
                for i = 1 :numel(y) % there are 3 repetitions
                    % il = 1 has a special title
                    if i == 1
                        title = [fish_name, ' Tail TD Positions, Il = ', num2str(il), ' Trial #',...
                            num2str(trial_idx), ' (20s), Rep 01'];
                    else
                        title = titles{i};
                    end

                    xLim = [0, 20]; % timeline x-axis is out of 20 seconds
                    yLim = [0, 190];
                    
                    % only send in the y coordinates
                    plotTailPointTimeDomainScatterWithColorbar(i, time, y{i}, ...
                        xLim, yLim, myColorMap, title)

                end

                % fig_out_path = [out_dir_figures, fish_name,'_Analysis02\'];
                % if ~exist(fig_out_path, 'dir')
                %     mkdir(fig_out_path);
                % end
                % 
                % fig_out_filename = [fish_name, '_TD_Tail_il_', num2str(il), ...
                %     '_trial_', num2str(trial_idx), '_', num2str(head_dir), '.png'];
                % 
                % saveas(mainFigure, [fig_out_path, fig_out_filename]);
                % disp(['SUCCESS: ', fig_out_filename, ' is saved.']);
         
            end
        % end
        disp([' ----- COMPLETED IL = ', num2str(il), '-----']);
    end
    disp('SUCCESS: ALL PLOTS GENERATED.')
    save('RUBY_IL2_TR36_DATA.mat', 'fish_name', 'il', 'head_dir', 'x', 'y');
end

%% Helper: Find struct by field name
function i = queryStruct(struct, fieldName, query)
for i = 1:numel(struct)
    if isfield(struct(i), fieldName) && isequal(struct(i).(fieldName), query)
        return;
    end
end
end


%% Helper: Analysis 02: tail point t-d movement a 3-panel vertical subplot
function plotTailPointTimeDomainScatterWithColorbar(subplotNum, time, yData, ...
    xLim, yLim, myColorMap, titleText)

subplot(3, 1, subplotNum);
% set(gcf, 'Visible', 'on');
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
