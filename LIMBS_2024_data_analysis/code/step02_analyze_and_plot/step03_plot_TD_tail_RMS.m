%% Step03: plot_TD_tail_RMS.m
% Updated 03.12.2024
% LIMBS Lab
% Author: Huanying (Joy) Yeh

% Experiment Name: Eigenmannia Virescens Luminance + Locomotion Comparisons
%
% Content:
% - visualize only tail point RMS movement (both x and y)?

abs_path = 'C:\Users\joy20\Folder\FA_2023\LIMBS Presentations\data\fish_structs_2024\';
out_path = 'C:\Users\joy20\Folder\FA_2023\LIMBS Presentations\Outputs\tail_RMS\';

if ~exist(out_path, 'dir')
    mkdir(out_path);
end

load([abs_path, 'result_rms_velocity.mat']) % head struct: "h"
head_file = load([abs_path, 'data_clean_head.mat']);
all_fish = head_file.h;

fishNames = {'Hope', 'Len', 'Doris', 'Finn', 'Ruby'}; % consistent with SICB
numFish = 5;
num_body_pts = 12;
target_pt = 12; % only look at tail
field_name = 'rmsMean';

figure;
hold on;

% Get the mean of all
all_lux = [];
all_data_pts = [];
all_data_pts_processed = [];

for i = 1:numFish
    this_data = res(i).(field_name);
    this_data = this_data(:, 12);
    all_data_pts = [all_data_pts; this_data];
end

mean_value_all = mean(all_data_pts);

for i = 1:numFish
    colorMap = winter(numFish + 1);

    fish_name = fishNames{i};

    lux = [];

    for il = 1 : numel(all_fish(i).data)
        lux(il) = all_fish(i).data(il).luxMeasured;
    end

    res(i).lux = lux;
    data = res(i).(field_name);
    data = data(:, 12);
    mean_value_this = mean(data);

    %% Centered, then smoothed for x-variance values
    data_smoothed_centered = smooth(data - (mean_value_this - mean_value_all));
    % data_smoothed_centered = data - (mean_value_this - mean_value_all);

    all_lux = [all_lux, lux];
    all_data_pts_processed = [all_data_pts_processed; data_smoothed_centered];

    plot(lux, data_smoothed_centered, '-', 'Color', colorMap(i, :), 'LineWidth', 2, 'Marker', 'o', 'MarkerSize', 3, 'MarkerFaceColor', colorMap(i, :));
end

x = log(all_lux');
y = all_data_pts_processed;
[fitted_model, gof] = createSigmoidFit(x, y);

num_sample_points = 500;
x_sample_points = linspace(min(x), max(x), num_sample_points);

% Evaluate the fitted model at the sample points
y_sample_points = feval(fitted_model, x_sample_points);
a = fitted_model.a;
b = fitted_model.b;
c = fitted_model.c;
d = fitted_model.d;

plot(exp(x_sample_points), y_sample_points, 'Color', 'red', 'LineWidth', 2)

set(gca, 'XScale', 'log'); % Set log scale for x-axis
grid on; % Display grid
title(['All Fish ', strrep(field_name, '_', ' '), ' Distributions']); % Set plot title
subtitle(['Fitted Sigmoid: a=', num2str(a), ', b=', num2str(b), ...
    ', c=', num2str(c), ', d=', num2str(d)]);
x_ticks = res(1).lux;
xticks(res(1).lux);
xticklabels(x_ticks);

xlim([0, 220]);

% Labeling
xlabel('Illuminance (lux)');
ylabel('Tail Point RMS Postion (cm^2)')
legend('Fish 1', 'Fish 2', 'Fish 3', 'Fish 4', 'Fish 5', ['Fitted Sigmoid: R^2 = ', num2str(gof.rsquare)]); % Add legend

% Save the closed loop bode plots
out_filename = [field_name, '_head_', fish_name, '_centered_trend.png'];

saveas(gcf, [out_path, out_filename]);
disp(['SUCCESS: ', out_filename, ' is saved.']);



function [fitresult, gof] = createSigmoidFit(x, y)
%  Auto-generated by MATLAB on 12-Mar-2024 15:48:24


%% Fit: 'untitled fit 1'.

%% Fit: 'untitled fit 1'.
[xData, yData] = prepareCurveData( x, y );

% Set up fittype and options.
ft = fittype( 'a/(1+exp(-b*(x-c)))+d', 'independent', 'x', 'dependent', 'y' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.StartPoint = [0.933993247757551 0.678735154857773 0.757740130578333 0.743132468124916];

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );
end