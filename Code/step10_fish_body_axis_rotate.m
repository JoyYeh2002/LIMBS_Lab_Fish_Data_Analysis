% step10
% Develop a module for correcting the fish body axis
% - Use the first 2 or three points to grab an axis
% - Find the angle w.r.t. horizontal
% - Rotate all the points wrt. the pin point as well as the image (for
% testing)

% All the experiment outputs are in
% C:\Users\joy20\Folder\FA_2023\LIMBS Presentations\Outputs\step10_fish_rotation\

% Spring 2024 semester
% updated 01/22/2024

close all;
abs_path = 'C:\Users\joy20\Folder\FA_2023\LIMBS Presentations\data\';
out_path = 'C:\Users\joy20\Folder\FA_2023\LIMBS Presentations\Outputs\step10_fish_rotation\';

test_subject = 'len_il_4_trial_31\';
mBody = load([abs_path, 'all_fish_full_length_data.mat']); % All the raw + cleaned data labels for Bode analyis

% Locate the subject fish
f = mBody.all_fish_data(3).luminance(4).data(2); % This is trial 31


% Define the VideoWriter object
videoFilename = '1_pt_full_video.avi';  % Specify the desired video filename
outputVideo = VideoWriter(fullfile(out_path, videoFilename), 'Uncompressed AVI');
outputVideo.FrameRate = 25;  % Set the frame rate (adjust as needed)

open(outputVideo);


% Loop through all the frames in a trial
for frame_idx = 20:20:100

    % Get the 12 points throughout the image
    x = f.x_data_raw(frame_idx, :);
    y = f.y_data_raw(frame_idx, :);

    % Linear fit with the first 3 points
    x_trend_pts = x(1:3);
    y_trend_pts = y(1:3);
    
    figureHandle = figure;
    set(figureHandle, 'Position', [100, 100, 800, 600]);  % Set your desired figure size    
    % set(figureHandle, 'Visible', 'off');

    xlim([0 640]);
    ylim([0 190]);
    
    hold on;
    scatter(x, y, 'o', 'DisplayName', 'Data Points', 'Color', 'b');
    title(['Frame #', num2str(frame_idx)]);

    % Calculate and plot body fit and rotated transformations
    % [coefficients, theta] = plotFittedLine(x_trend_pts, y_trend_pts, figureHandle, 'r');
 
    % Only calculate, no plot
    coefficients = polyfit(x(1:3), y(1:3), 1);
    theta = -atan(coefficients(1));
    [rotated_x, rotated_y] = OLD_rotatePoints(x, y, x(2), y(2), theta);
    
    scatter(rotated_x, rotated_y, 'o', 'filled', 'DisplayName', 'Data Points', 'Color', 'g');

    % Capture the current frame to video
    currentFrame = getframe(figureHandle);
    writeVideo(outputVideo, currentFrame);
    
end

% Close the VideoWriter
close(outputVideo);

% HELPERS are here
function [rotated_x, rotated_y] = rotatePoints(x, y, origin_x, origin_y, theta)

    rotated_x = zeros(1, 12);
    rotated_y = zeros(1, 12);

    R = [cos(theta), - sin(theta);
        sin(theta), cos(theta);];
    
    for idx = 1 : size(x, 2)
        delta = [x(idx) - origin_x;
                y(idx) - origin_y;];
  
        result = R * delta + [origin_x; origin_y];
        rotated_x(idx)= result(1);
        rotated_y(idx)= result(2);
    end
end


% HELPERS are here
function [rotated_x, rotated_y] = NOTWORKING(x, y, origin_x, origin_y, theta)

    E1 = [cos(theta), -sin(theta), -origin_x*cos(theta)+origin_y*sin(theta) + origin_x;
    sin(theta), cos(theta), -origin_x*sin(theta)-origin_y*cos(theta) + origin_y;
    0, 0, 1];

    rotated_x = zeros(1, 12);
    rotated_y = zeros(1, 12);

    for idx = 1 : size(x, 2)
        vector = [x(idx); y(idx); 1];
        result = E1 .* vector;
    
        rotated_x(idx) = result(1);
        rotated_y(idx)= result(2);
    end
end

% HELPERS are here
function [rotated_x, rotated_y] = OLD_rotatePoints(x, y, origin_x, origin_y, theta_rad)
    % Rotate each point around the origin
    rotated_x = (x - origin_x) * cos(theta_rad) - (y - origin_y) * sin(theta_rad) + origin_x;
    rotated_y = (x - origin_x) * sin(theta_rad) + (y - origin_y) * cos(theta_rad) + origin_y;
end

function [coefficients, theta] = plotFittedLine(x, y, figHandle, color)
    coefficients = polyfit(x, y, 1);
    theta = atan(coefficients(1));

    % Generate the fitted line
    xFit = linspace(min(x), 350, 100);
    yFit = polyval(coefficients, xFit);

    % Plot the fitted line on the given figure
    figure(figHandle);

    % Set the xlim and ylim
    xlim([0 640]);
    ylim([0 190]);

    hold on;
    plot(xFit, yFit, '-', 'LineWidth', 2,'DisplayName', 'Fitted Line', 'Color', color);

    fprintf('Fitted Line Equation: y = %.4fx + %.4f\n', coefficients(1), coefficients(2));
    fprintf('Angle with respect to horizontal: %.2f degrees\n', theta);

end
