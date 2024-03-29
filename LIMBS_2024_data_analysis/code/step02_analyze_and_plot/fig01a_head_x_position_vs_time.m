%% fig01a_head_x_position_vs_time.m
% Updated 03.26.2024
% LIMBS Lab
% Author: Huanying (Joy) Yeh

% Experiment Name: Eigenmannia Virescens Luminance + Locomotion Comparisons
%
% Content: Plotting time-domain positions at 3 illuminance levels
% - Fish name: Hope
% - Illuminance range: 1, 4, 13 (0.1 lux, 2 lux, 150 lux)
% - All trials in one luminance condition (40% opacity), overlayed with
% the shuttle and mean
% - Vertically place 3 luminances: low, medium, high
% 
% Out file names:
% out_filename = 'fig01a01_td_positions.png';

close all;

%% 1. Specify folder paths
parent_dir = fullfile(pwd, '..', '..');
abs_path = fullfile(parent_dir, 'data_structures\');
out_path = fullfile(parent_dir, 'figures\');
pdf_path = fullfile(parent_dir, 'figures_pdf\');

if ~exist(out_path, 'dir')
    mkdir(out_path);
end

if ~exist(pdf_path, 'dir')
    mkdir(pdf_path);
end

%% 2. Initial setup
fishNames = {'Hope', 'Len', 'Doris', 'Finn', 'Ruby'}; % consistent with SICB
numIls = [14, 9, 11, 9, 9];
numFish = 5;

all_fish = load(fullfile(abs_path, 'data_clean_head.mat'), 'h').h;
shuttle = load(fullfile(abs_path, '\helper_structs\helper_shuttle.mat'), 'shuttle').shuttle;

% Struct field names
x_field = 'fishX';
x_field_mean = 'fishXMean';
TIME = 0:0.04:20-0.04;

% Switch
fish_name = 'Hope';
il_range = [1 4 13]; % 0.1, 2, 150 lux.

% Set up colors
opacity = 0.25;
colors = [copper(7), (ones(7, 1)* opacity)];
color_idx = [1, 4, 6];
colors_mean = {'#2256A5', '#2C68F5', '#1FA9FF'}; 
colors_il = {'#543F36', '#805749', '#AC6C23'};

%% 2. Loop through and rotate all fish w.r.t. main body axis
fish_idx = queryStruct(all_fish, 'name', fish_name);

count = 1;
for il = il_range
    % Each il gets a figure
    f = figure();
    f.Position = [100 103 800 400];
    hold on

    % color_this_il = colors_il{count};
    color_this_il = colors_mean{count};

    % Plot the individual lines all in the same plot
    for tr_idx = 1 : numel(all_fish(fish_idx).data(il).(x_field))
        data = cell2mat(all_fish(fish_idx).data(il).(x_field)(tr_idx)); 
        p1 = plot(TIME, fixSmallTL(data, 10)*100, 'color', color_this_il, 'LineWidth', 2);
        p1.Color(4) = 0.25; % Change opacity
    end

    % Extra overlay: Plot the shuttle and mean again
    ylim([-8 8]);

    % Plot the shuttle and mean data
    color_shuttle = [1, 0, 0, 0.9]; % red
    color_mean = colors_mean{count};
    
    data_mean = cell2mat(all_fish(fish_idx).data(il).(x_field_mean));

    plot(TIME, shuttle*100, 'color', color_shuttle, 'LineWidth', 3);
    plot(TIME, fixSmallTL(data_mean, 10)*100, 'color', color_mean, 'LineWidth', 3);

    ylabel('Position(cm)');
    set(gca,'xtick',[])

    xlabel('Time(s)'); %, 'FontSize', 20);
    xticks(0:2:20);

    % Get title
    lux_measured = all_fish(fish_idx).data(il).luxMeasured;
    num_trials = numel(all_fish(fish_idx).data(il).fishX);
    title_text = [fish_name, ' Illuminance = ', num2str(lux_measured), ' lux. ', num2str(num_trials), ' Trials Total'];
    title(title_text);

    saveas(gcf, [out_path, 'fig01a0', num2str(count), '_td_positions.png';]);
    saveas(gcf, [pdf_path, 'fig01a0', num2str(count), '_td_positions.pdf';]);
    count = count + 1;

end

%% Helper: Find struct by field name
function i = queryStruct(struct, fieldName, query)
for i = 1:numel(struct)
    if isfield(struct(i), fieldName) && isequal(struct(i).(fieldName), query)
        return;
    end
end
end

%% Helper: fixSmallTL
% Updated 09.19.2022 by Joy Yeh
% Fill up small tracking losses after applying a 5Hz cut-off butterworth
% filter
%
% Params:
% data: the time-domain x value passed in. Might have small tracking loss
% window: the movmedian window size (10 is good)
%
% Returns:
% fixedData: filled gap with movmedian and applied a butterworth filter.
function [fixedData] = fixSmallTL(data, windowSize)
filled = fillmissing(data, 'movmedian', windowSize);

if sum(isnan(filled)) > 0
    fixedData = filled;
    return;
else
    % butterworth
    fs = 25;
    fc = 5; % 5 Hz cutoff
    Wn = fc /(fs / 2); % Cut-off for discrete-time filter
    [b,a] = butter(2, Wn);
    fixedData = filtfilt(b,a, filled);
end
end





