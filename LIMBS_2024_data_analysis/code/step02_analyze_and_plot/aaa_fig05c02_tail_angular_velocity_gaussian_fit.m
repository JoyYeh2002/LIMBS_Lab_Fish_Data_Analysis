%% fig05c02_tail_angular_velocity_gaussian.m
% Updated 04.17.2024
% LIMBS Lab
% Author: Huanying (Joy) Yeh

% Experiment Name: Eigenmannia Virescens Luminance + Locomotion Comparisons
%
% Content:
% - Use Gaussian mixture model (or single Gaussian) to fit all the fish in
% different luminances
% - Expand upon the "result_tail_angular_velocity.mat."
% - Find pattern with mean, std dev, and variance.
% - Plot the following in "\figures"
% - "fig05c02_tail_angular_velocity_gaussian_params.png"
% - These in "\figures_archive\fig05c_tail_velocity_distributions\"
% - All fish Gaussian params vs. illuminance plots

close all;
addpath 'helper_functions'

%% 1. Specify folder paths
parent_dir = fullfile(pwd, '..', '..');
abs_path = fullfile(parent_dir, 'data_structures\');
out_path = fullfile(parent_dir, 'figures\');
pdf_path = fullfile(parent_dir, 'figures_pdf\');

%% 2. Load the full body struct and tail FFT struct
all_fish = load(fullfile(abs_path, 'data_clean_body.mat'), 'all_fish').all_fish;
res = load(fullfile(abs_path, 'result_tail_angular_velocity.mat'), 'res').res;

fishNames = {'Hope', 'Len', 'Doris', 'Finn', 'Ruby'}; % consistent with SICB
num_fish = 5;
num_body_pts = 12;
resolution = 100;
p2m = 0.004;

time_diff = 0.04;

cell_mu = {};
cell_sigma = {};
GMM_mu = {};
GMM_sigma = {};
%
% mode = 'gaussian'

mode = 'gaussian'
num_components = 4

out_archive_path = fullfile(parent_dir, ['figures_archive\fig05c02b_tail_angular_velocity_', mode, ...
    '_02\']);

if ~exist(out_archive_path, 'dir')
    mkdir(out_archive_path);
end

%% 3. Populate struct data for result_tail_angular_velocity.mat
for i =  2 %1 : num_fish
    fish_name = fishNames{i};
    num_il_levels = numel(res(i).luminances);

    for il = 3 %1 : num_il_levels
        num_trials = numel(res(i).luminances(il).x_tail);
        if num_trials < 4
            continue;
        else

            if strcmp(mode, 'gaussian')

                % 4491 x 1 double
                data = res(i).luminances(il).tail_v_ang_all;
                % data = log(abs(data));

                resolution = 30;
                edges = linspace(min(data), max(data), resolution+1); % Adjust the range based on your data
                hist_values_og = histcounts(data, edges, 'Normalization', 'probability') * 100;

                % plot(hist_values_og);
                % hist_values = log(hist_values_og);
                % pd = fitdist(hist_values', 'Normal');

                pd = lognfit('hello', data + 200);
                % pd = fitdist(data, 'Normal');
                [cell_mu{i, il}, cell_sigma{i, il}] = normfit(data);
                % plot_histogram_and_curve(mode, hist_values, pd, i, il, cell_mu{i, il}, cell_sigma{i, il}, out_archive_path);

                x = linspace(min(data), max(data), 1000);

                % Calculate y values using the fitted GMM
                y = pdf(pd, x');
                
                % Plot histogram of data
                figure('Visible', 'on');
                histogram(data, 'Normalization', 'probability');
                hold on;
                plot(x, y, 'r', 'LineWidth', 2);
                ylim([0, 0.16])
                % title(sprintf('%s, fish idx = %d, il = %d, mu = %s, sigma = %s', mode, i, il, mu, sigma));
                legend('Data', mode);

            elseif strcmp(mode, 'GMM')
                options = statset('MaxIter',500);
                gmm= fitgmdist(data,num_components,'Options',options);
                %  gmm = fitgmdist(data, num_components, 'MaxIter', 500, 'RegularizationValue', 1e-6);
                GMM_mu{i, il} = gmm.mu;
                GMM_sigma{i, il} = squeeze(gmm.Sigma);

                plot_histogram_and_curve(mode, data, gmm, i, il, gmm.mu, gmm.Sigma, out_archive_path);


            elseif strcmp(mode, 'student')
                % ft = fittype("cauchy(x, rho)");
                % f = fit()
                % GMM_mu{i, il} = gmm.mu;
                % GMM_sigma{i, il} = squeeze(gmm.Sigma);
                pd = fitdist(data, 'tlocationscale');

                % Plot histogram with adjusted bin width
                plot_histogram_and_curve(mode, data, pd, i, il, pd.mu, pd.sigma, out_archive_path);


            end

            fprintf('%s for fish = %d, il = %d figure is saved.\n', mode, i, il)

            % % Chi-square goodness of fit test
            % [h, p] = chi2gof(data, 'CDF', pd);
            %
            % % Visual inspection of residuals
            % residuals = data - y;
            % figure;
            % plot(residuals);
            % title('Residuals Plot');

        end
    end
end
disp(['SUCCESS: All fish figures saved in ', out_archive_path]);

% ------------------ Plotting Start Here --------------------

function plot_histogram_and_curve(mode, data, distribution, i, il, mu, sigma, out_archive_path)
% Generate x values for the curve
x = linspace(min(data), max(data), 1000);

% Calculate y values using the fitted GMM
y = pdf(distribution, x');

% Plot histogram of data
figure('Visible', 'on');
histogram(data, 'Normalization', 'probability');
hold on;
plot(x, y, 'r', 'LineWidth', 2);
ylim([0, 0.16])
title(sprintf('%s, fish idx = %d, il = %d, mu = %s, sigma = %s', mode, i, il, mu, sigma));
legend('Data', mode);

saveas(gcf, fullfile(out_archive_path, sprintf('%s_fish_%d_IL_%d.png', mode, i, il)));
end

function [mu, sigma] = fitGaussian(data, i, il, out_archive_path)
pd = fitdist(data, 'Normal');
[mu, sigma] = normfit(data);

x = linspace(min(data), max(data), 1000);  % Generate x values for the curve
y = pdf(pd, x);  % Calculate y values using the fitted distribution

figure('Visible', 'on'); % Set visibility to off

histogram(data, 'Normalization', 'probability');

hold on;

[f, xi] = ksdensity(data);
plot(xi, f, 'b', 'LineWidth', 2);

plot(x, y, 'r', 'LineWidth', 2);
ylim([0, 0.16])
title(sprintf('fish idx = %d, il = %d, mu = %.2f, sigma = %.2f', i, il, mu, sigma));
legend('Data', 'Fitted Gaussian', 'Kernal');


% binWidth = 0.1;  % Experiment with different bin widths
% histogram(data, 'Normalization', 'probability', 'BinWidth', binWidth);
% hold on;

% Perform kernel density estimation (KDE)


saveas(gcf, fullfile(out_archive_path, sprintf('fish_%d_IL_%d.png', i, il)));
end

function y = cauchy(x, rho)
gamma = 0.001;
y = zeros(size(x));
for i = 1 : length(x)
    y(i) = gamma / (((x(i) - rho) ^ 2 + gamma ^ 2) * pi);

end
end