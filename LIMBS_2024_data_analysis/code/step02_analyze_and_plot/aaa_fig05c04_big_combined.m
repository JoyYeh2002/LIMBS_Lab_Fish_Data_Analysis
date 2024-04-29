%% aaa_fig05c04_big_combined.m
% TD head (20s)
% TD tail (20s)
% Bode plot
% Gaussian distribution and all the other metrics
% Fish name, idx, il, trial number

%% 1. Load structs
close all;
addpath 'helper_functions'

%% 1. Specify folder paths
parent_dir = fullfile(pwd, '..', '..');
abs_path = fullfile(parent_dir, 'data_structures\');

out_archive_path = fullfile(parent_dir, 'figures_archive\fig05c04_grand_panel\');
if ~exist(out_archive_path, 'dir')
    mkdir(out_archive_path);
end

%% 2. Load the full body struct and tail FFT struct
all_fish = load(fullfile(abs_path, 'data_clean_head.mat'), 'all_fish').all_fish;
res = load(fullfile(abs_path, 'result_GMM_kurtosis.mat'), 'res').res;
shuttle = load(fullfile(abs_path, '\helper_structs\helper_shuttle.mat'), 'shuttle').shuttle;

fishNames = {'Hope', 'Len', 'Doris', 'Finn', 'Ruby'}; % consistent with SICB
num_fish = 5;

%% -------------- 1. TD x-positions -----------
% [CAUTION] if there's an error with "Kurt = kurtosis(y), do "clear all" command
x_field = 'fishX';
x_field_mean = 'fishXMean';
TIME = 0:0.04:20-0.04;

% Switch [INPUT] you can also do range_fish_idx = [1, 3, 5],
% range_il_levels = [1, 2, 4, 5]
% Note that fish 1 (Hope) DOES NOT HAVE il levels 1, 3, or 9.
range_fish_idx = 5;
range_il_levels = 9;

colors = lines(5);

%% -------------- 2. Bode Plots ------------
% Struct field names
gainField = 'gmGain';
phaseField = 'gmPhase';

% Colors
gray = [0.7, 0.7, 0.7];

yLimG = [0 10];
yLimP = [-200 -22.5];


colorMap = {'#000000', '#112d80', '#234099', '#2d50b4', '#5070c7', ...
    '#91a6e2', '#acc0fa', '#cbd0ee', '#ececec'};


% Locate the frequency peaks
k = [2, 3, 5, 7, 11, 13, 19, 23, 29, 31, 37, 41];
freq_data = k * 0.05;

%% -------------- 3. Tail TD in this illuminance -------
time = 0:0.04:19.96;



%% 2. Loop through and rotate all fish w.r.t. main body axis
for fish_idx = range_fish_idx
    fish_name = fishNames{fish_idx};
    count = 1;
    c = colors(fish_idx, :);

    for il = range_il_levels

        lux_measured = all_fish(fish_idx).data(il).luxMeasured;

        % 1. Plot head time-domain x positions (20 seconds, all trials in this illuminance level
        fig01_pos = [130 340 500 270];
        fig02_pos = [650 340 500 380];
        fig03_pos = [60, 70, 640, 190];
        fig04_pos = [650, 70, 640, 190];

      
        plot_head_x_positions_td(fig01_pos, fish_name, fish_idx, c, all_fish, il, lux_measured, x_field, TIME, x_field_mean, shuttle)


        % 2. Plot head Bode plot (averaged)
   
        plot_head_bode_mean(fig02_pos, fish_name, all_fish, fish_idx, il, gainField, freq_data, c, lux_measured, phaseField);

        % 3. Tail TD plot
        num_trials = numel(res(fish_idx).luminances(il).y_tail);
        if num_trials < 4
            continue;
        else
            fig = figure('Position', fig03_pos);
            yData = res(fish_idx).luminances(il).y_tail;

            hold on;
            for trial_idx = 1 : num_trials
                p1 = plot(time, yData{trial_idx}, 'LineWidth', 1.2);
                p1.Color(4) = 0.9;
            end
            hold off;

            xlim([0, 20]); % timeline x-axis is out of 20 seconds
            ylim([-50, 250]);
            xlabel("Time(s)")
            ylabel("Tail Y-Pos (pixel)")

            title(sprintf('%s Il = %d (%.2f lux) Tail Y-Positions (%d Trials Total)', fish_name, il, lux_measured, num_trials))

            grid on;
        end

        % 4. Gaussian distribution
        if num_trials < 4
            continue;
        else
            % 4491 x 1 double
            data = res(fish_idx).luminances(il).tail_v_ang_all;
            num_datapoints = numel(res(fish_idx).luminances(il).y_tail);

            data = [data;-data];

            options = statset('MaxIter',500);
            gmm = fitgmdist(data, 2, 'Options',options);

            % Calculate kurtosis
            x = linspace(min(data), max(data), 1000);
            y = pdf(gmm, x');
            kurt = kurtosis(y);
          
            % Calculate standard deviation ratio (assuming two components)
            sigma1 = sqrt(gmm.Sigma(:,:,1));
            sigma2 = sqrt(gmm.Sigma(:,:,2));
            std_ratio = sigma1 / sigma2;

            % --------------------------- Plotting ---------------------
            fig = figure('Position', fig04_pos);

            histogram(data, 'Normalization', 'probability', 'BinWidth', 0.8, 'FaceColor', 'auto');
            hold on;
            plot(x, y, 'r', 'LineWidth', 2);
            ylim([0.0001, 0.16])
            yticks([0, 0.01, 0.05, 0.08, 0.1, 0.15]);

            set(gca, 'YScale', 'log');
            title(sprintf('GMM %d.%d, kurtosis = %.2f, sigma ratio = %.2f', fish_idx, il, kurt, std_ratio));
            legend(sprintf('Fish %d, Il %d, %d Trials', fish_idx, il, num_datapoints), 'GMM Symmetric');
            % 
        end


    end


end

%% ----------- Helper 1: head x positions in time domain ---------------
function plot_head_x_positions_td(fig_pos, fish_name, fish_idx, color, all_fish, il, lux_measured, x_field, TIME, x_field_mean, shuttle)
f = figure();
f.Position = fig_pos;
hold on

% Plot the individual lines all in the same plot
for tr_idx = 1 : numel(all_fish(fish_idx).data(il).(x_field))
    data = cell2mat(all_fish(fish_idx).data(il).(x_field)(tr_idx));
    p1 = plot(TIME, fixSmallTL(data, 10)*100, 'color', color, 'LineWidth', 1.8);
    p1.Color(4) = 0.25;
end

color_shuttle = 'm'; % magenta
data_mean = cell2mat(all_fish(fish_idx).data(il).(x_field_mean));
h1 = plot(TIME, shuttle*100, 'color', color_shuttle, 'LineWidth', 2.4);
h2 = plot(TIME, fixSmallTL(data_mean, 10)*100, 'color', color, 'LineWidth', 2.4);

ylabel('X-Position(cm)');
set(gca,'xtick',[])

xlabel('Time(s)');
xticks(0:2:20);

ylim([-8 8]);

% Get title
num_trials = numel(all_fish(fish_idx).data(il).fishX);
title_text = sprintf('Fish Idx = %d (%s), Il = %d (%.2f lux). %d Trials Total', fish_idx, fish_name, il, lux_measured, num_trials);
title(title_text);

legend([h1, h2], 'Shuttle', 'Mean X-Pos')
end


%% Helper: fixSmallTL
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


%% ----------- Helper 2: Mean Bode Plots in thei illuminance ---------------
function plot_head_bode_mean(fig02_pos, fish_name, all_fish, fish_idx, il, gainField, freq_data, c, lux_measured, phaseField)
f = figure();
f.Position = fig02_pos;

plotName = [fish_name, ' Closed-Loop Frequency Responses'];

% Gain
lineWidth = 2.8;
h1 = axes('position',[0.1 0.56 0.8 0.4]);

data = all_fish(fish_idx).data(il).(gainField);

semilogx(freq_data, smooth(data), 'color', c, 'LineWidth', lineWidth);

axisFontSize = 9;
labelFontSize = 9;

h1.XGrid = 'on';
h1.XLim = [0 2.1];

set(h1, 'XTick', [0.1, 1]);
h1.XAxis.FontSize = labelFontSize;

set(h1,'xScale','log');
set(h1,'yScale','log');

h1.YGrid = 'on';
h1.YLim = [0, 1.5];
set(h1,'YTick',[0, 0.1, 1]);
set(h1,'YTickLabel',["0", "10^{-1}", "10^0","10^1"]);
h1.YAxis.FontSize = labelFontSize;

ylabel('Gain', 'FontSize', axisFontSize)

% Save the closed loop bode plots
title(sprintf('%s Il = %d (%.2f lux) GM Bode Plot', fish_name, il, lux_measured))

% Phase
h2 = axes('position',[0.1 0.1 0.8 0.4]);

data = all_fish(fish_idx).data(il).(phaseField);
semilogx(freq_data, smooth(data), 'color', c, 'LineWidth', lineWidth);

h2.XGrid = 'on';
h2.XLim = [0 2.1];
set(h2,'xScale','log');

h2.XAxis.FontSize = labelFontSize;
xlabel('Freq in Hz', 'FontSize', axisFontSize);
h2.YGrid = 'on';
h2.YLim = [-210, 0];
set(h2,'XTick',freq_data);
set(h2,'YTick',[-200 -150 -100 -50 0 50]);

h2.YAxis.FontSize = 9;
ylabel('Phase(deg)', 'FontSize', axisFontSize);


end