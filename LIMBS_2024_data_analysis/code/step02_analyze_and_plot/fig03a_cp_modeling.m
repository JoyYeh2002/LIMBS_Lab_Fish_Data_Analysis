%% fig03a_cp_modeling.m
% Updated 04.07.2024
% LIMBS Lab
% Author: Huanying (Joy) Yeh

% Experiment Name: Eigenmannia Virescens Luminance + Locomotion Comparisons
%
% Content: Fitting CP model with "data_clean_head.mat"
% - Pick some sample illuinance levels
% - Experimental outputs saved to figures_archive_cp_modeling"
%
% Out file names:
% - 'fig03a_fit_cp_model_sample.png'; in /figures
% - 'fig03a_cp_model_[fish_name]_il_[il_levels]_cp_model_fig.png' in
% /figures/archive

close all;
close all;

%% 1. Specify folder paths
parent_dir = fullfile(pwd, '..', '..');
abs_path = fullfile(parent_dir, 'data_structures\');
out_archive_path = fullfile(parent_dir, 'figures_archive\fig03a_cp_modeling\');

out_path = fullfile(parent_dir, 'figures\');
pdf_path = fullfile(parent_dir, 'figures_pdf\');

if ~exist(out_archive_path, 'dir')
    mkdir(out_archive_path);
end

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

% Colors
c = copper(10);
colorMap = [c(4, :); c(6, :); c(7, :); c(8, :); c(9, :)];
gray = [0.7, 0.7, 0.7];

% Struct field names

gainField = 'cpGain';
phaseField = 'cpPhase';

% gainField = 'gmGain';
% phaseField = 'gmPhase';


if gainField == 'cpGain'
    y_lim_gain= [0 3];
    y_lim_phase = [-210, -20];
    title_suffix = ' CP Bode Plot';
else
    y_lim_gain = [0 10];
    y_lim_phase = [-200 -22.5];
    title_suffix = ' GM Bode Plot';
end

% Locate the frequency peaks
k = [2, 3, 5, 7, 11, 13, 19, 23, 29, 31, 37, 41];
freq_data = k * 0.05;

%% 2. Loop through and rotate all fish w.r.t. main body axis
colorMap = {'#000000', '#112d80', '#234099', '#2d50b4', '#5070c7', ...
    '#91a6e2', '#acc0fa', '#cbd0ee', '#ececec'};

% [INPUT]
for fish_idx = 1 : numFish
    fish_name = fishNames{fish_idx};

    f = figure();
    f.Position = [100 100 300 550];
    il = 0;

    num_il_levels = numel(all_fish(fish_idx).data);
    colorMap = cool(num_il_levels);

    plotName = [fish_name, ' Closed-Loop Frequency Responses'];

    % Gain
    lineWidth = 1.9;
    h1 = axes('position',[0.2 0.56 0.76 0.4]);
    hold on

    for il = 1 : num_il_levels
        data = all_fish(fish_idx).data(il).(gainField);
        % c = colorMap{il};
        c = colorMap(il, :);
        semilogx(freq_data, smooth(data), ...
            'color', c, 'LineWidth', lineWidth);
    end

    axisFontSize = 12;
    labelFontSize = 9;

    h1.XGrid = 'on';
    h1.XLim = [0 2.1];

    set(h1, 'XTick', [0.1, 1]);
    h1.XAxis.FontSize = labelFontSize;

    set(h1,'xScale','log');
    set(h1,'yScale','log');

    h1.YGrid = 'on';
    h1.YLim = y_lim_gain;
    set(h1,'YTick', [0, 0.1, 1]);
    set(h1,'YTickLabel', ["0", "10^{-1}", "10^0","10^1"]);
    h1.YAxis.FontSize = labelFontSize;

    ylabel('Gain', 'FontSize', axisFontSize)

    % Save the closed loop bode plots
    title([fish_name, title_suffix])

    il = 0;

    % Phase
    h2 = axes('position',[0.2 0.1 0.75 0.4]);
    hold on
    for il = 1 : num_il_levels
        data = all_fish(fish_idx).data(il).(phaseField);

        c = colorMap(il, :);
        semilogx(freq_data, smooth(data), 'color', c, 'LineWidth', lineWidth);
    end

    h2.XGrid = 'on';
    h2.XLim = [0 2.1];
    set(h2,'xScale','log');

    h2.XAxis.FontSize = labelFontSize;
    xlabel('Freq in Hz', 'FontSize', axisFontSize);
    h2.YGrid = 'on';
    h2.YLim = y_lim_phase;
    set(h2,'YTick',[-200 -150 -100 -50 0 50]);

    h2.YAxis.FontSize = 9;
    ylabel('Phase(deg)', 'FontSize', axisFontSize);

    saveas(gcf, [out_archive_path, fish_name, '.png']);

    % Only save Finn to the output path
    if fish_name == "Finn"
        saveas(gcf, [out_path, 'fig03a_CP_plot_', fish_name, '.png']);
        saveas(gcf, [pdf_path, 'fig03a_CP_plot_', fish_name, '.pdf']);
    end
end



