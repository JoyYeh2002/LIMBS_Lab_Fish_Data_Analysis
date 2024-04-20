%% fig05c01_tail_angular_velocity_histograms.m
% Updated 04.09.2024
% LIMBS Lab
% Author: Huanying (Joy) Yeh

% Experiment Name: Eigenmannia Virescens Luminance + Locomotion Comparisons
%
% Content:
% - Use result_tail_positions.m to calculate the histogram values, then get
% "result_tail_angular_velocity.mat"
% - Plot angular velocities (fig5c) in surface plot
% - Plot the following in "\figures"
% - "fig05c01_tail_angular_velocity_histograms.png"
% - These in "\figures_archive\fig05c_tail_velocity_distributions\":
% - All fish 3d histograms

close all;
addpath 'helper_functions'

%% 1. Specify folder paths
parent_dir = fullfile(pwd, '..', '..');
abs_path = fullfile(parent_dir, 'data_structures\');
out_path = fullfile(parent_dir, 'figures\');
pdf_path = fullfile(parent_dir, 'figures_pdf\');

out_archive_path = fullfile(parent_dir, 'figures_archive\fig05c_tail_angular_velocity_histograms\');
if ~exist(out_archive_path, 'dir')
    mkdir(out_archive_path);
end


%% 2. Load the full body struct and tail FFT struct
all_fish = load(fullfile(abs_path, 'data_clean_body.mat'), 'all_fish').all_fish;
res = load(fullfile(abs_path, 'result_tail_positions.mat'), 'raw').raw;

fishNames = {'Hope', 'Len', 'Doris', 'Finn', 'Ruby'}; % consistent with SICB
num_fish = 5;
num_body_pts = 12;
resolution = 100;
p2m = 0.004;

time_diff = 0.04;

lux_axis_limit = [0, 210];
z_limit = [0, 0.18];

%% Step16_plot_angular_velocity_distributions.m
%% 1. Load in the data
apply_smooth = 0;
view_coords = [30 30];
alpha = 1;

%% 2. [User inputs] for adjusting the plot
map = magma;
target_body_pt = 12;
position_coords = [50, 50, 700, 450];

 % For filtering the y values
Fs = 25;
Fc = 4; % cutoff frequency in Hz
Wn = Fc/(Fs/2); % Cut-off frequency for discrete-time filter
[b, a] = butter(2, Wn); % butterworth filter parameters



%% 3. Populate struct data for result_tail_angular_velocity.mat
for i =  1 : num_fish
    fish_name = fishNames{i};
    num_il_levels = numel(res(i).luminances);

    for il = 1 : num_il_levels
        num_trials = numel(res(i).luminances(il).x_tail);
        if num_trials < 4
            continue;
        else
            v_ang_this_il = [];
            for trial_idx = 1 : num_trials
                x = cell2mat(res(i).luminances(il).x_tail(trial_idx));
                y = cell2mat(res(i).luminances(il).y_tail(trial_idx));

                x_disp = x - 220 * p2m; % 500 x 12
                y_disp = y - 110 * p2m;
                angles = rad2deg(atan2(y_disp, x_disp));
                angles = filtfilt(b, a, angles);

                plot(1:500, angles);
                v_angular = diff(unwrap(angles)) / time_diff;

                % [New] filter the angles up to 4Hz
                % 
                % [f1, P1] = singleSidedSpectra(v_angular, Fs);
                % plot(f1, P1);
                
                v_angular = filtfilt(b, a, v_angular);
                
                % [f2, P2] = singleSidedSpectra(v_angular, Fs);
                % hold on
                % plot(f2, P2);
                % 
                % legend("original", "filtered at 4Hz")


                res(i).luminances(il).tail_v_ang{trial_idx}= v_angular;
                v_ang_this_il = [v_ang_this_il; v_angular];
            end
        end

        res(i).luminances(il).tail_v_ang_all = v_ang_this_il;
    end
end

% Save to struct
save([abs_path, 'result_tail_angular_velocity.mat'], 'res');
disp("Tail FFT information saved in 'result_tail_angular_velocity.mat'.");


% ------------------ Plotting Start Here ---------------------
for i = 1 : num_fish
    fish_name = fishNames{i};
    data_cell = {res(i).luminances.tail_v_ang_all};

    edges = linspace(min(data_cell{2}), max(data_cell{2}), resolution+1); % Adjust the range based on your data
    hist_values = zeros(length(edges)-1, numel(data_cell));

    % Compute histograms for each array
    for k = 1:numel(data_cell)
        if ~isempty(data_cell{k})
            hist_values(:, k) = histcounts(data_cell{k}, edges, 'Normalization', 'probability');
        end
    end

    lux = [res(i).luminances.lux];
    [X, Y] = meshgrid(edges(1:end-1), lux);
    figure('Color', 'white', 'Position', position_coords);
    set(gcf, 'Visible', 'on');

    p = waterfall(X, Y,hist_values' * 100);
    % p = surf(X, Y, hist_values' * 100);
    set(gca, 'YScale', 'log');
    set(gca, 'ZScale', 'log');

    p.FaceAlpha = alpha;
    p.EdgeColor = 'interp';
    p.LineWidth = 2;
    view(view_coords);
    % shading interp
    grid(gca, 'off');

    xlabel('Tail Angular Velocity Distribution (cm/s)');
    ylabel('Lux Values (log scale)')

    %yticks(lux);
    yticks([0, 0.2, 1, 2, 2.5, 5, 7, 9, 15, 60, 150, 210])

    zlabel('Probability (%)')
    ylim(lux_axis_limit);
    zlim(z_limit * 100);
    zticks([0, 1, 2, 3, 4, 5, 6, 7, 8, 10, 11, 12, 13, 14, 15, 20, 30, 50])

    colorbar;
    % map = winter(num_il_levels);

    colormap(map);
    title([fish_name, ' Tail Angular Velocity Distribution, ', num2str(num_il_levels), ' Luminance Levels']);

    fig_out_path = [out_path, '\angular_velocity_real_plots\'];
    if ~exist(fig_out_path, 'dir')
        mkdir(fig_out_path);
    end

    fig_out_filename = ['fig05c01_tail_angular_velocity_histograms_', num2str(view_coords), '_', fish_name, '.png'];
    saveas(gcf, [out_archive_path, fig_out_filename]);
    disp(['SUCCESS: ', fig_out_filename, ' is saved.']);

end


%% Helper: calculate FFT amplitude of input data X and the sampling freq Fs
function [f,P1] = singleSidedSpectra(X,Fs)

X(isnan(X))=[];
X = X - mean(X);

Y = fft(X);
L = length(X);

P2 = abs(Y/L * 2);
P1 = P2(1:round(L/2)+1);

f = Fs*(0:round(L/2))/L;
end

