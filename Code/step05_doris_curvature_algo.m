%% Step 05: Curvature Algo
close all;
abs_path = 'C:\Users\joy20\Folder\FA_2023\LIMBS Presentations\Data\';
out_dir_figures = 'C:\Users\joy20\Folder\FA_2023\LIMBS Presentations\Outputs\AAA_playground\';
% struct_filename = [abs_path, 'DORIS_IL3_TR34_DATA.mat'];
struct_filename = [abs_path, 'RUBY_IL2_TR36_DATA.mat'];

% Doris, il = 3, trial # = 34
P2M_SCALE = 2 * 0.0002;
time = 0 : 0.04 : 19.96;

data = load(struct_filename);
fish_name = data.fish_name;
il = data.il;
trial_idx = 34;
head_dir = data.head_dir;

rep = 1;
x = data.x{rep};
y = data.y{rep};

num_points = 12;
% x = randn(500, num_points);   % Replace with your x data
% y = randn(500, num_points);   % Replace with your y data

% Calculate curvature for each frame
curvature = zeros(size(x));

for frame = 1:size(x, 1)
    % Fit a spline curve to the points
    pp = csape(1:num_points, [x(frame, :); y(frame, :)], 'variational');

    % Evaluate the derivative of the spline to get curvature
    curvature(frame, :) = fnval(fnder(pp, 2), 1:num_points);
end

% Plot curvature at each time step
figure;
for frame = 1:size(x, 1)
    plot(time(frame), mean(curvature(frame, :)), 'o', 'MarkerSize', 5, 'MarkerFaceColor', 'r');
    hold on;
end

title('Average Curvature Over Time');
xlabel('Time');
ylabel('Average Curvature');
grid on;
