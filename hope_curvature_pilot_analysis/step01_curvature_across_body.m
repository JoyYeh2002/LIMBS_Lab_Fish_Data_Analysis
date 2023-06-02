% step01_curvature_across_body.m
% Hope Curvature Pilot Analysis
% For 6 luminance levels ranging from 0.4 lux to 210 lux, plot the
% curvature along each of 7 points across the body
%
% Updated 06/02/2023

close all;

fish_name = 'Hope';
directories = {'hope_low_trial03_il_1\', ...
    'hope_trial04_il_2\', ...
    'hope_low_trial27_il_5\', ...
    'hope_low_trial22_il_6\', ...
    'hope_trial08_il_5\', ...
    'hope_trial06_il_7\'};

labels = {'0.4 lux', '2 lux', '7 lux', '10.5 lux', '60 lux', '210 lux'};
file_name = 'tracked_data.mat';
DATA_INDEX_BEGIN = 251;

tracked_data = struct();  % Create an empty struct

numDirs = numel(directories);
meanCurvatures = zeros(numDirs, 7); % Array to store mean curvatures

for file_idx = 1:numDirs
    this_fish_dir = directories{file_idx};
    this_file = ['../../data/', this_fish_dir, file_name];
    load(this_file);

    tracked_data(file_idx).directory = this_fish_dir;
    tracked_data(file_idx).x = cell(3, 1);
    tracked_data(file_idx).y = cell(3, 1);

    tracked_data(file_idx).x{1} = x_tracked(DATA_INDEX_BEGIN : DATA_INDEX_BEGIN + 499, :);
    tracked_data(file_idx).x{2} = x_tracked(DATA_INDEX_BEGIN + 500 : DATA_INDEX_BEGIN + 999, :);
    tracked_data(file_idx).x{3} = x_tracked(DATA_INDEX_BEGIN + 1000 : DATA_INDEX_BEGIN + 1499, :);

    tracked_data(file_idx).y{1} = y_tracked(DATA_INDEX_BEGIN : DATA_INDEX_BEGIN + 499, :);
    tracked_data(file_idx).y{2} = y_tracked(DATA_INDEX_BEGIN + 500 : DATA_INDEX_BEGIN + 999, :);
    tracked_data(file_idx).y{3} = y_tracked(DATA_INDEX_BEGIN + 1000 : DATA_INDEX_BEGIN + 1499, :);

    % Clear the variables to save memory
    clearvars('x_tracked', 'y_tracked');
    
    % Calculate mean curvature for each directory
    x_array = cell2mat(tracked_data(file_idx).x);
    y_array = cell2mat(tracked_data(file_idx).y);
    
    curvatureArray = zeros(500, 7); % Initialize the array to store curvatures

    for i = 1:500
        x = x_array(i, :);
        y = y_array(i, :);

        desiredNumPoints = 7; % Specify the desired number of points

        % Resample the curve to have the desired number of points
        x_resampled = linspace(min(x), max(x), desiredNumPoints);
        y_resampled = interp1(x, y, x_resampled, 'spline');

        % Calculate the curvature of the resampled curve
        dx_resampled = gradient(x_resampled);
        dy_resampled = gradient(y_resampled);
        d2x_resampled = gradient(dx_resampled);
        d2y_resampled = gradient(dy_resampled);
        curvature_resampled = abs(dx_resampled .* d2y_resampled - dy_resampled .* d2x_resampled) ./ (dx_resampled.^2 + dy_resampled.^2).^(3/2);

        % Store the resampled curvature in the curvatureArray
        curvatureArray(i, :) = curvature_resampled;
    end

    % Calculate the mean of each column
    meanCurvatures(file_idx, :) = mean(curvatureArray);
end

figure;
customColormap = [linspace(0.2, 1, 6)', zeros(6, 1), zeros(6, 1)];

% Plot the grouped bars and assign colors from the colormap
h = bar(meanCurvatures', 'grouped');

% Adjust the face color of each individual bar
for i = 1:numel(h)
    h(i).FaceColor = customColormap(i, :);
end


xlabel('Point Index');
ylabel('Average Curvature');
title([fish_name, ' Average Curvature for Each Point']);
legend(labels, 'Interpreter', 'none');
