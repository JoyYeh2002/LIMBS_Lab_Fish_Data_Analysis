%% fig01b_head_position_variances.m
% Updated 03.26.2024
% LIMBS Lab
% Author: Huanying (Joy) Yeh

% Experiment Name: Eigenmannia Virescens Luminance + Locomotion Comparisons
%
% Content: Plotting x- and y- variances of the fish head positions
% - Create and save new struct with head variance calculations:
% "result_head_variances.mat"
% - All fish variances vs. all illuminance levels
% - x axis is in log scale
%
% Out file names:
% - 'fig01b01_head_variances_x.png';
% - 'fig01b02_head_variances_y.png';

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

%% 1. Load the data
all_fish = load(fullfile(abs_path, 'data_clean_head.mat'), 'h').h;
fishNames = {'Hope', 'Len', 'Doris', 'Finn', 'Ruby'}; % consistent with SICB
num_fish = 5;
num_body_pts = 1;

colorMap = cool(num_fish + 1);

%% 2. Calculate x- and y- variances and save to struct
res = struct();
 for i = 1 : num_fish
    res(i).name = fishNames{i};

    num_il_levels = numel(all_fish(i).data);

    this_fish_varX = cell(num_il_levels, 1);
    this_fish_varX_avg = zeros(num_il_levels, 1);
    this_fish_varY = cell(num_il_levels, 1);
    this_fish_varY_avg = zeros(num_il_levels, 1);

    for il = 1 : num_il_levels
        num_trials = numel(all_fish(i).data(il).fishX);

        this_il_varX = zeros(num_trials, num_body_pts);
        this_il_varY = zeros(num_trials, num_body_pts);
        mean_x = cell2mat(all_fish(i).data(il).fishXMean);
        mean_y = cell2mat(all_fish(i).data(il).fishYMean);

        for trial_idx = 1 : num_trials
            %% 3. Populate the struct
            res(i).luminance(il).trID = all_fish(i).data(il).trID;
            res(i).luminance(il).repID = all_fish(i).data(il).repID;

            x_data = cell2mat(all_fish(i).data(il).fishX(trial_idx)); % 500 x 1
            y_data = cell2mat(all_fish(i).data(il).fishY(trial_idx)); % 500 x 1

            this_il_varX(trial_idx, :) = var((x_data - mean_x),'omitnan');
            this_il_varY(trial_idx, :) = var((y_data - mean_y),'omitnan');
        end

        % Populate at high level
        res(i).lux(il) = all_fish(i).data(il).luxMeasured;

        this_fish_varX{il} = this_il_varX;
        this_fish_varY{il} = this_il_varY;

        res(i).luminance(il).varX = this_il_varX;
        res(i).luminance(il).varY = this_il_varY;

        this_fish_varX_avg(il, :) = nanmean(this_il_varX, 1);
        this_fish_varY_avg(il, :) = nanmean(this_il_varY, 1);
    end
    res(i).varX_mean = this_fish_varX_avg;
    res(i).varY_mean = this_fish_varY_avg;
end

% outfile_name = 'result_head_variances.mat';
% save([abs_path, outfile_name], 'res');
% disp(['SUCCESS: ', outfile_name, ' saved.'])

%% 3. Plot all fish scatter plots with sigmoid fit
for field_to_plot = ['X', 'Y']
    field_name = ['var', field_to_plot, '_mean'];

    % figure;
    figure;
    set(gca, 'XScale', 'log'); % Set log scale for x-axis
    hold on;

    % Get the mean of all
    all_lux = [];
    all_data_pts = [];
    all_data_pts_processed = [];
    for i = 1 : num_fish
        this_data = res(i).varX_mean;
        all_data_pts = [all_data_pts; this_data];
    end

    mean_value_all = mean(all_data_pts);

    for i = 1 : num_fish
        fish_name = fishNames{i};
        lux = res(i).lux;
        data = res(i).(field_name);

        %% colorMap_indiv = summer(size(lux, 2) + 4);
        mean_value_this = mean(data);

        %% Centered, then smoothed for x-variance values
        data_smoothed_centered = smooth(data - (mean_value_this - mean_value_all)) * 1e4;

        % Make the y-variance outliers more transparent
        if field_to_plot == 'Y' && (i == 2 || i == 3)
            opacity = 0.3;
            c = [colorMap(i, :), opacity];
            p1 = plot(lux, data_smoothed_centered, '-', 'Color', c, 'LineWidth', 2);
        else
            all_lux = [all_lux, lux];
            all_data_pts_processed = [all_data_pts_processed; data_smoothed_centered];
            p1 = plot(lux, data_smoothed_centered, '-', 'Color', colorMap(i, :), 'LineWidth', 2, 'Marker', 'o', 'MarkerSize', 3, 'MarkerFaceColor', colorMap(i, :));
        end
    end


    %% 4. Fit a sigmoid model
    x = log(all_lux');
    y = all_data_pts_processed;

    [fitted_model, gof] = createSigmoidFit(field_name, x, y);

    num_sample_points = 500;
    x_sample_points = linspace(min(x), max(x), num_sample_points);

    % Evaluate the fitted model at the sample points
    y_sample_points = feval(fitted_model, x_sample_points);
    a = fitted_model.a;
    b = fitted_model.b;
    c = fitted_model.c;
    d = fitted_model.d;

    % Plot the fitted sigmoid
    plot(exp(x_sample_points), y_sample_points, 'Color', 'k', 'LineWidth', 2)

    grid on; % Display grid
    title(['All Fish ', strrep(field_name, '_', ' '), ' Distributions']); % Set plot title
    subtitle(['Fitted Sigmoid: a=', num2str(a), ', b=', num2str(b), ...
        ', c=', num2str(c), ', d=', num2str(d)]);

    % Remove some x axis ticks to prevent cluttering
    x_ticks = res(1).lux;
    values_to_remove = [5.5, 12, 150];
    x_ticks = x_ticks(~ismember(x_ticks, values_to_remove));

    xticks(x_ticks);
    xticklabels(x_ticks);

    xlim([0, 220]);

    % Labeling
    xlabel('Illuminance (lux)');
    ylabel('X-Position Variances (cm^2)')

    if field_to_plot == 'X'
        legend('Fish 1', 'Fish 2', 'Fish 3', 'Fish 4', 'Fish 5', ['Sigmoid: R^2 = ', ...
            num2str(gof.rsquare)]); % Add legend

    else
        legend('Fish 1', 'Fish 2 (excluded)', 'Fish 3 (excluded)', 'Fish 4', 'Fish 5', ...
            ['Sigmoid: R^2 = ', num2str(gof.rsquare)]); % Add legend
    end
    legend('Location', 'southwest');

    if field_to_plot == 'X'
        fig_idx = '1';
    else
        fig_idx = '2';
    end
    % saveas(gcf, [out_path, 'fig01b0', fig_idx, '_head_', field_to_plot, '_position_variances.png']);
    % saveas(gcf, [pdf_path, 'fig01b0', fig_idx, '_head_', field_to_plot, '_position_variances.pdf']);
    % 
    % disp(['SUCCESS: head', field_to_plot, ' position variances for all fish is saved.']);
end

%% Helper: sigmoid fit, generated from curve fitter tool
function [fitresult, gof] = createSigmoidFit(field_name, x, y)
%  Auto-generated by MATLAB on 12-Mar-2024 15:48:24

[xData, yData] = prepareCurveData( x, y );

% Set up fittype and options.
ft = fittype( 'a/(1+exp(-b*(x-c)))+d', 'independent', 'x', 'dependent', 'y' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';

if (field_name == "varX_mean")
    opts.StartPoint = [0.473288848902729 0.351659507062997 0.830828627896291 0.585264091152724];
elseif (field_name == "varY_mean")
    opts.StartPoint = [0.0357116785741896 0.849129305868777 0.933993247757551 0.678735154857773];
end

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );

end






