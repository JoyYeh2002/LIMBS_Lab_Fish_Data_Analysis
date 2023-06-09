% step01_curvature_across_body.m
% Hope Curvature Pilot Analysis
% For 6 luminance levels ranging from 0.4 lux to 210 lux, plot the
% curvature along each illumination levels, groups with all points along
% the body
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

file_name = 'tracked_data.mat';
labels = {'pt01', 'pt02', 'pt03', 'pt04', 'pt05', 'pt06', 'pt07'};
DATA_INDEX_BEGIN = 251;

tracked_data = struct();  % Create an empty struct

numDirs = numel(directories);
meanCurvatures = zeros(numDirs, 7); % Array to store mean curvatures

 % Calculate velocity distribution for each directory
    numPoints = 7;
    velocityArrays = cell(numDirs, numPoints);

for file_idx = 1 %:numDirs % 1: 6
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
    
    for point_idx = 1:numPoints
        
        x_this_point = x_array(:, point_idx);
        y_this_point = y_array(:, point_idx);

        dx = diff(x_this_point);
        dy = diff(y_this_point);

        velocities = sqrt(dx.^2 + dy.^2);

        % [!] Butterworth filter at some frequency
        % https://www.mathworks.com/help/signal/ref/butter.html
        
        threshold = 8; % Define the threshold for outliers

% Assuming you have the velocities array
outliers = abs(velocities - mean(velocities)) > threshold; % Find outlier indices

velocities(outliers) = NaN; % Set outliers to NaN

% Perform linear interpolation to fill in the gaps
nanIndices = find(isnan(velocities));
nonNanIndices = find(~isnan(velocities));
velocities(nanIndices) = interp1(nonNanIndices, velocities(nonNanIndices), nanIndices, 'linear');

% Replace NaN values with the interpolated values
velocities(isnan(velocities)) = velocities(isnan(velocities));

        velocityArrays{file_idx, point_idx} = velocities;
    end
end

% Plot the velocity distributions for each directory
for file_idx = 1 %:numDirs
    %figure;
for point_idx = 1:numPoints
    figure;
    velocities = velocityArrays{file_idx, point_idx};
    plot(velocities, 'Color', customColormap(point_idx, :));
    ylim([0, 10]); % Set y-limits to be the same for all plots
    hold on;
    xlabel('Frame');
    ylabel('Velocity');
    title(['Velocity Distribution - Point ', num2str(point_idx)]); % Label the titles

    hold off;
    folderName = '../../outputs/hope_pilot/velocity_profiles/';
    % Save the figure as a PNG file in the specified folder
    fileName = fullfile(folderName, ['velocity_figure_', num2str(point_idx), '.png']);
    saveas(gcf, fileName);
end
end
