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

GMM = {};
GMM_mu = {};
GMM_sigma = {};
GMM_component_ratio = {};
%

% mode = 'gaussian'

mode = 'GMM_symm'
num_components = 2

out_archive_path = fullfile(parent_dir, ['figures_archive\fig05c02b_tail_angular_velocity_', mode, ...
    '_', num2str(num_components), '\']);

if ~exist(out_archive_path, 'dir')
    mkdir(out_archive_path);
end

%% 3. Populate struct data for result_tail_angular_velocity.mat
for i = 1 : num_fish
    fish_name = fishNames{i};
    num_il_levels = numel(res(i).luminances);

    for il = 1 : num_il_levels
        num_trials = numel(res(i).luminances(il).x_tail);
        if num_trials < 4
            continue;
        else
            % 4491 x 1 double
            data = res(i).luminances(il).tail_v_ang_all;

            data = [data;-data];

            if strcmp(mode, 'GMM_symm')
                options = statset('MaxIter',500);
                gmm= fitgmdist(data,num_components, 'Options',options);
                % GMM{i, il} = gmm;
                % GMM_mu{i, il} = gmm.mu; % 5 x 14 x 2
                % GMM_sigma{i, il} = squeeze(gmm.Sigma); % 5 x 14 x 2
                % GMM_component_ratio{i, il} = gmm.ComponentProportion;

                res(i).luminances(il).GMM = gmm;
                res(i).luminances(il).mu = gmm.mu;
                res(i).luminances(il).sigma = squeeze(gmm.Sigma);
                res(i).luminances(il).component_ratio = gmm.ComponentProportion;

            for bin_width = 0.8
                plot_histogram_and_curve(mode, data, bin_width, gmm, i, il, gmm.mu, gmm.Sigma, out_archive_path);
                fprintf('%s for fish = %d, il = %d figure is saved.\n', mode, i, il)
            end
          
            elseif strcmp(mode, 'student')
         
                pd = fitdist(data, 'tlocationscale');

                % Plot histogram with adjusted bin width
                plot_histogram_and_curve(mode, data, pd, i, il, pd.mu, pd.sigma, out_archive_path);
            end
        end
    end
end

% Save to .mat file
% save([abs_path, 'result_GMM_params_', num2str(num_components), '_components.mat'], 'GMM', 'GMM_mu', 'GMM_sigma', 'GMM_component_ratio');
% disp("Tail gaussian fits saved in 'result_GMM_params_2_components.mat'.");

save([abs_path, 'result_GMM_symm_', num2str(num_components), '_components.mat'], 'res');
disp("Tail gaussian fits saved in 'result_GMM_params_2_components.mat'.");


% ------------------ Plotting Start Here --------------------
% 
% function plot_histogram_and_curve(mode, data, num_bins, distribution, i, il, mu, sigma, out_archive_path)
function plot_histogram_and_curve(mode, data, bin_width, distribution, i, il, mu, sigma, out_archive_path)
% Generate x values for the curve
x = linspace(min(data), max(data), 1000);

% Calculate y values using the fitted GMM
y = pdf(distribution, x');

% Plot histogram of data
figure('Visible', 'off');
% histogram(data, 'Normalization', 'probability', 'NumBins', num_bins, 'FaceColor', 'g');
histogram(data, 'Normalization', 'probability', 'BinWidth', bin_width, 'FaceColor', 'auto');

hold on;
plot(x, y, 'r', 'LineWidth', 2);
ylim([0.0001, 0.16])
yticks([0, 0.01, 0.05, 0.08, 0.1, 0.15]);
% Set y-axis scale to logarithmic
set(gca, 'YScale', 'log');
title(sprintf('%s, fish idx = %d, il = %d', mode, i, il));
legend('Data', mode);

saveas(gcf, fullfile(out_archive_path, sprintf('%s_fish_%d_IL_%d.png', mode, i, il)));
end

