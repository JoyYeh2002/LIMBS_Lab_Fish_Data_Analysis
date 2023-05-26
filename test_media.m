% Use uinput() to figure out the orientation pixel situation
% Updated 05/24/2023

% Load the image
imagePath = '../data/test_media/sample_frame.jpg';  % Replace with the actual path to your image
image = imread(imagePath);

% Display the image
imshow(image);
title('Click on the image to select three points. Press Enter to finish.');

% Call ginput() to interactively select coordinates
coords = ginput(3);

% Display the selected coordinates
disp('Selected coordinates:');
disp(coords);

% Plot the selected coordinates on the image
hold on;
plot(coords(:, 1), coords(:, 2), 'r+', 'MarkerSize', 10, 'LineWidth', 2);
hold off;
