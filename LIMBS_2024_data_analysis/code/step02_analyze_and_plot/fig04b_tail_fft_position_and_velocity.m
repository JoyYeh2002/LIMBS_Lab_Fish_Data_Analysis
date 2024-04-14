%% fig04c_tail_FFT_position_and_velocity.m
% Updated 04.04.2024
% LIMBS Lab
% Author: Huanying (Joy) Yeh

% Experiment Name: Eigenmannia Virescens Luminance + Locomotion Comparisons
%
% Content:
% - Tail point FFT position and velocity
% - Save to the result_tail_FFT.mat struct
% - Plot the FFT pos, FFT velocity vs. illuminance plot for 1 fish
%
% Output:
% "fig04c_tail_FFT_vs_illuminance_Hope.png"
% "fig04c_tail_FFT_vs_illuminance_Doris.png"
% Struct: "result_tail_fft_and_curvature.mat"

close all;
addpath 'helper_functions'

%% 1. Specify folder paths
parent_dir = fullfile(pwd, '..', '..');
abs_path = fullfile(parent_dir, 'data_structures\');
out_path = fullfile(parent_dir, 'figures\');

out_archive_path = fullfile(parent_dir, 'figures_archive\fig04c_tail_FFT\');
if ~exist(out_archive_path, 'dir')
    mkdir(out_archive_path);
end

pdf_path = fullfile(parent_dir, 'figures_pdf\');

% Tail plotting playground
% Does tail interpolation actually mess with the tail?
% What happened to Hope Il = 1, trial = 2, rep 1? The only valid trial?

close all

%% 1. Load the full body + rotated struct

all_fish = load(fullfile(abs_path, 'data_clean_body.mat'), 'all_fish').all_fish;

fishNames = {'Hope', 'Len', 'Doris', 'Finn', 'Ruby'}; % consistent with SICB

p2m = 0.0004;
num_frames = 500;

Fs = 25;
Fc = 5; % cutoff frequencyin Hz
Wn = Fc/(Fs/2); % Cut-off frequency for discrete-time filter
[b, a] = butter(2, Wn); % butterworth filter parameters
smooth_window_size = 3;

% Define time domain data and parameters
T = 1/Fs; % Sampling period
L = 500; % Length of signal (500 frames)
t = (0:L-1)*T; % Time vector 1 x 500

% Inputs
sample_fish_idx = [1, 3]; % Select fish #1 to be in the final paper

% Create the FFT result structure
res = struct();

for i = 1 : 5
    h =  findobj('type','figure');
    n_fig = length(h);

    fish_name = fishNames{i};
    res(i).fish_name = fish_name;
    
    num_ils = numel(all_fish(i).luminance);

    res(i).luminances = struct();

    for il = 1: num_ils

        num_trials = numel(all_fish(i).luminance(il).data);
        count = 1;

        % These are for individual trials
        res(i).luminances(il).x_tail = {};
        res(i).luminances(il).y_tail = {};
        res(i).luminances(il).y_fft_amp = {};
        res(i).luminances(il).y_fft_vel = {};

        for trial_idx = 1 : num_trials %range_trial

            res(i).luminances(il).lux = all_fish(i).lux_values(il);

            f = all_fish(i).luminance(il).data(trial_idx);

            % Use DB criteria
            v = all_fish(i).luminance(il).data(trial_idx).valid_both;
            % v = all_fish(i).luminance(il).data(trial_idx).valid_body & all_fish(i).luminance(il).data(trial_idx).valid_head;
            v_percentage = all_fish(i).luminance(il).data(trial_idx).valid_tail_percent;
            % v = [1, 1, 1];

            for rep = 1: 3 
                % Use only the valid data
                if v(rep) == 1
                    v_percent = v_percentage(rep);
                    
                    x_tail = all_fish(i).luminance(il).data(trial_idx).(['x_rot_rep', num2str(rep)]);
                    y_tail = all_fish(i).luminance(il).data(trial_idx).(['y_rot_rep', num2str(rep)]);

                    % only keep tail
                    x_tail = x_tail(:, 12);
                    y_tail = y_tail(:, 12);

                    % Append x_tail to the cell array
                    res(i).luminances(il).x_tail{end+1} = x_tail;
                    res(i).luminances(il).y_tail{end+1} = y_tail;

                    % Calculate FFT
                    [f1, amp_smooth, f2, vel_smooth] = fftAmpAndVelocity(y_tail, Fs, T, p2m, smooth_window_size);
                    res(i).luminances(il).y_fft_amp{end+1} = amp_smooth;
                    res(i).luminances(il).y_fft_vel{end+1} = vel_smooth;
                    count = count + 1;
                end
            end
        end

        % Get the average FFT
        res(i).freq = f1;

        num_valid_trials = numel(res(i).luminances(il).x_tail);
        if num_valid_trials > 3
            res(i).luminances(il).y_fft_amp_mean = mean(cell2mat(res(i).luminances(il).y_fft_amp),2);
            res(i).luminances(il).y_fft_vel_mean = mean(cell2mat(res(i).luminances(il).y_fft_vel),2);
        else
            res(i).luminances(il).y_fft_amp_mean = [];
            res(i).luminances(il).y_fft_vel_mean = [];
        end
    end

    % ------------------Plot FFT for 5 fish with colored legend, 5 figs total ------------------
    main_figure = figure('Position', [100, 30, 500, 500]);
    % set(main_figure, 'Visible', 'off');

    colors = magma(num_ils + 1);
    legend_labels = cellfun(@(x) [num2str(x), ' lux'], num2cell(all_fish(i).lux_values), 'UniformOutput', false);

    xlabel('Frame');
    ylabel('y-positions (pixel)'); % THERE ARE SOME SLIGHT DIFFERENCES!

    %% Tail Y FFT amplitude plot
    subplot(211)
    set(gcf, 'Visible', 'off');
    hold on
    num_ils = numel(res(i).luminances);
    for il = 1 : num_ils
        fft_amp = res(i).luminances(il).y_fft_amp_mean;
        if ~isempty(fft_amp)
            plot(f1, smooth(fft_amp, 3), 'LineWidth',2, 'Color',colors(il,:), 'DisplayName', legend_labels{il});
        end
    end

    xlabel('Frequency (Hz)');
    ylabel('Amplitude Smoothed (cm)');
    xlim([0, 4]);

    legend('Location', 'northeast', 'NumColumns', 2);
    title([fish_name, ' All Luminance Levels Tail Y FFT']);

    %% Tail Y FFT velocity plot
    subplot(212)
    hold on
    for il = 1 : num_ils
        fft_vel = res(i).luminances(il).y_fft_vel_mean;
        if ~isempty(fft_vel)
            plot(f2, smooth(fft_vel, 3), 'LineWidth',2,'Color',colors(il,:), 'DisplayName', legend_labels{il});
        end
    end

    xlabel('Frequency (Hz)');
    ylabel('Velocity Smoothed (cm/s)');
    xlim([0, 4]);
    title('FFT Velocity vs. Frequency');

    legend('Location', 'northeast', 'NumColumns', 2);
 
    % Save all images to archive folder
    saveas(main_figure, [out_archive_path, fish_name, '.png']);

    % Save sample fish as official paper figure
    if ismember(i, sample_fish_idx)
        saveas(main_figure, [out_path, 'fig04b_tail_FFT_vs_illuminance_', fish_name, '.png']);
        saveas(main_figure, [pdf_path, 'fig04b_tail_FFT_vs_illuminance_', fish_name, '.pdf']);
    end

    disp(['SUCCESS: ', 'fig04b_tail_FFT_vs_illuminance_', fish_name, '.png is saved.']);
end

save([abs_path, 'result_tail_fft_and_curvature.mat'], 'res');
disp("Tail FFT information saved in 'result_tail_fft_and_curvature.mat'.")


%% Helper: get the FFT amplitude and velocity
function [f1, amp_smooth, f2, vel_smooth] = fftAmpAndVelocity(X, Fs, T, p2m, window_size)
X = X - mean(X);
X = X * p2m * 100; % unit in cm
[f1, P1] = singleSidedSpectra(X, Fs);

amp_smooth = movmean(P1, window_size);

delta_t = T; % Time difference between frames
delta_position = diff(X); % Differences in position
velocity = delta_position / delta_t; % Velocity is change in position over time
[f2, P2] = singleSidedSpectra(velocity, Fs);
vel_smooth = movmean(P2, window_size);
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

