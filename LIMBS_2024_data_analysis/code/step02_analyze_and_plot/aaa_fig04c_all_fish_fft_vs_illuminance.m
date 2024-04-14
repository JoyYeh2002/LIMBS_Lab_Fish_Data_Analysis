%% fig04d_all_fish_fft_vs_illuminance.m
% Updated 04.14.2024
% LIMBS Lab
% Author: Huanying (Joy) Yeh

% Experiment Name: Eigenmannia Virescens Luminance + Locomotion Comparisons
%
% Content:
% - Load tail point FFT and velocity from "result_tail_fft.mat"
% - Cluster all 5 fish for illuminance dependence
% - Each fish's FFT frequency peak where the velocity peak 
%
% Output (for archive):
% "fig04d_tail_FFT_at_peak.png" at various frequencies (usually 1 hz or 1.5
% hz)

close all;
addpath 'helper_functions'

%% 1. Specify folder paths
parent_dir = fullfile(pwd, '..', '..');
abs_path = fullfile(parent_dir, 'data_structures\');
out_path = fullfile(parent_dir, 'figures\');
out_pdf_path = fullfile(parent_dir, 'figures_pdf\');

out_archive_path = fullfile(parent_dir, 'figures_archive\fig04c_tail_FFT_at_peak\');
if ~exist(out_archive_path, 'dir')
    mkdir(out_archive_path);
end

pdf_path = fullfile(parent_dir, 'figures_pdf\');

close all

%% 2. Load the FFT result struct
fft_amp = load(fullfile(abs_path, 'data_clean_body.mat'), 'all_fish').all_fish;
res = load(fullfile(abs_path, 'result_tail_fft.mat'), 'res').res;

p2m = 0.0004;
num_frames = 500;

fishNames = {'Hope', 'Len', 'Doris', 'Finn', 'Ruby'}; % consistent with SICB
numIls = [14, 9, 11, 9, 9];
numFish = 5;

%% 3. Populate the all-fish FFT amplitude/velocity struct
freq_ticks = res(1).freq;

fft_amp = struct();
fft_vel = struct();

% Populate lux levels
for j = 1 : 14
    fft_amp(j).lux = res(1).luminances(j).lux;
    fft_vel(j).lux = res(1).luminances(j).lux;
end

% Populate Hope (fish 1)
for j = 1 : 14
    fft_amp(j).Hope= res(1).luminances(j).y_fft_amp_mean;
    fft_vel(j).Hope= res(1).luminances(j).y_fft_vel_mean;
end

% Populate fish 2 through 5
fish_name = "Len";
fish_idx = 2;
destination_arr = [1, 2, 4, 6, 8, 9, 10, 12, 14];
num_iters = 9;
fft_amp = populateData(fft_amp, res, fish_name, fish_idx, destination_arr, num_iters,'y_fft_amp_mean');
fft_vel = populateData(fft_vel, res, fish_name, fish_idx, destination_arr, num_iters,'y_fft_vel_mean');

fish_name = "Doris";
fish_idx = 3;
destination_arr = [1, 2, 4, 5, 6, 7, 9, 10, 11, 12, 14];
num_iters = 11;
fft_amp = populateData(fft_amp, res, fish_name, fish_idx, destination_arr, num_iters,'y_fft_amp_mean');
fft_vel = populateData(fft_vel, res, fish_name, fish_idx, destination_arr, num_iters,'y_fft_vel_mean');

fish_name = "Finn";
fish_idx = 4;
destination_arr = [1, 2, 4, 5, 7, 8, 10, 13, 14];
num_iters = 9;
fft_amp = populateData(fft_amp, res, fish_name, fish_idx, destination_arr, num_iters,'y_fft_amp_mean');
fft_vel = populateData(fft_vel, res, fish_name, fish_idx, destination_arr, num_iters,'y_fft_vel_mean');

fish_name = "Ruby";
fish_idx = 5;
destination_arr = [1, 2, 4, 5, 7, 8, 10, 13, 14];
num_iters = 9;
fft_amp = populateData(fft_amp, res, fish_name, fish_idx, destination_arr, num_iters,'y_fft_amp_mean');
fft_vel = populateData(fft_vel, res, fish_name, fish_idx, destination_arr, num_iters,'y_fft_vel_mean');

cell_amp = struct2cell(fft_amp);
cell_vel = struct2cell(fft_vel);

lux_ticks = squeeze(cell_amp(1, :, :)); % Hope standard lux cetegories
all_fft_amp = squeeze(cell_amp(2:end, :, :))'; % All 5 fish cell array
all_fft_vel = squeeze(cell_vel(2:end, :, :))'; % All 5 fish cell array


%% 4. Plot FFT amplitude for a few frequencies
lux = cell2mat(lux_ticks);
colors = magma(14);
colors_fish = cool(6);

%% 5. Dynamically find peaks for each fish.
for fish_idx = 1:5
    sum = zeros(251, 1);
    this_fish = all_fft_vel(:, fish_idx);

    data = cell2mat(all_fft_vel(il, fish_idx));

    for il = 1 : 14
        data = cell2mat(this_fish(il));
        if ~isempty(data)
            sum = sum + data;
        end
    end
 
    [~, max_idx] = max(sum);
    res(fish_idx).peak_freq = freq_ticks(max_idx);
end

%% Inputs
plot_customized_peaks = 1;

if plot_customized_peaks == 1


    main_figure = figure('Position', [100, 30, 700, 450]);
    set(main_figure, 'Visible', 'off');

    hold on

    % Loop through fish
    for fish_idx = 1 :5

        lux = all_fish(fish_idx).lux_values;

        if fish_idx == 1
            lux = [lux(2), lux(4:8), lux(10:14)];
        end

       
        target_freq = res(fish_idx).peak_freq;
        target_idx = find(freq_ticks == target_freq);
        target_idx_range = target_idx - 4 : target_idx + 4; % 0.05Hz each idx, so we go 0.2Hz above and 0.2hz below

        c = colors_fish(fish_idx, :);
        good_lux = [];
        good_data = [];

        counter = 1;
        for il =  1  : 14
            if ~isempty(cell2mat(all_fft_vel(il, fish_idx)))
                
                data = cell2mat(all_fft_vel(il, fish_idx));

                data_pt = mean(data(target_idx_range));
               
                scatter(lux(counter), data_pt, 'MarkerFaceColor', c, 'MarkerEdgeColor', c);

                good_lux = [good_lux, lux(counter)];
                good_data = [good_data, data_pt];
               
                counter = counter + 1;
            end
        end

        h_fish(fish_idx) = plot(good_lux, good_data, 'Color', c, ...
            'DisplayName', [fishNames{fish_idx}, ': Peak at ', num2str(target_freq), ' Hz'], 'LineWidth', 1.5);
        hold on;
    end

    legend(h_fish);
    % 1. Set x axis to log scale
    set(gca, 'XScale', 'log');

    % 2. Set title
    title('All 5 fish Tail FFT Velocity vs. Illuminance at Respective Peak Values.');
    xlim([0, 220]);
    xticks(all_fish(1).lux_values);
    xticklabels({'0.1', '0.4', '1', '2', '3.5', '5.5', '7', '9.5', '12', '15', '30', '60', '150', '210'});
    xlabel('Illuminance (lux)');

    ylabel('FFT Tail Velocity (m)');

    % 6. Add grid lines
    grid on;

    % Save all images to archive folder
    saveas(main_figure, [out_path, 'fig04c_all_fish_tail_fft_velocities_at_epak.png']);
    saveas(main_figure, [out_pdf_path, 'fig04c_all_fish_tail_fft_velocities_at_epak.pdf']);
    disp('fig04d_all_fish_tail_fft_velocities_at_epak.png is saved.');
end

% Save the struct
save([abs_path, 'result_tail_fft.mat'], 'res', 'all_fft_amp', 'all_fft_vel');
disp("More detailed FFT struct saved at 'result_tail_fft.mat'");

% Helper: populate the y tail fft data at the specified illuminance level
% (destination_arr) for one fish
function updated_struct = populateData(input_struct, res, fish_name, fish_idx, destination_arr, num_iters, field_name)
for i = 1:num_iters
    input_struct(destination_arr(i)).(fish_name) = res(fish_idx).luminances(i).(field_name);
end
updated_struct = input_struct;
end

