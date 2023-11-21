%% step04_doris_FFT_functions.m
% Updated 11.17.2023
% LIMBS Lab
% Author: Huanying (Joy) Yeh

% Experiment Name: Eigenmannia Virescens Luminance + Locomotion Comparisons
% Content: Develop the FFT algorithm and visualization for ONE TRIAL only

%% 0. Load the big struct
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

x = data.x;
y = data.y;

% Make the butterworth filter
fs = 25;
fc = 5;
Wn = fc/(fs/2); % Cut-off for discrete-time filter
[b,a]=butter(2,Wn); % butterworth filter parameters

color_map = jet(12);
color_map = ['r';'b';'m'];
line_width = 2;

% Get the tail point of y, rep 1
for tail_idx = 1:12
    figure;
    hold on;

    subplot(2, 1,1);
    for rep = 1:3
        % Go along the whole body

        % figure;
        % hold on;
        y_tail = y{rep}(:, tail_idx) * P2M_SCALE * 100; % in cm
        y_tail = filtfilt(b, a, y_tail); % apply the butterworth fiter

        % Plot TD
        hold on;
        plot(time, y_tail, 'color', color_map(rep),'LineWidth', line_width);
    end
    xlim([0, 20]);
    ylim([0, 8]); % 0.08m = 8cm
    xlabel("Time(s)")
    ylabel("Y-Pos (cm)")
    legend('Rep 1', 'Rep 2', 'Rep 3');
    % title(['Body Pt: ', num2str(tail_idx), ' Doris Il03, Tr34, All Rep', ...
    %     ' Time Domain Y Positions']);
    title(['Body Pt: ', num2str(tail_idx), ' Ruby Il02, Tr36, All Rep', ...
        ' Time Domain Y Positions']);
    grid on;

    % Plot the frequency-domain response (magnitude spectrum)
    subplot(2, 1, 2);
    hold on;
    for rep = 1:3

        % Perform FFT
        y_tail = y{rep}(:, tail_idx) * P2M_SCALE * 100; % in cm
        y_tail = filtfilt(b, a, y_tail); % apply the butterworth fiter

        N = length(y_tail);    % Length of the signal
        Fs = 25; %Hz
        frequencies = (0:N-1) * Fs / N;  % Frequency axis for the FFT result
        fft_result = fft(y_tail - mean(y_tail), N);
        magnitude_spectrum = abs(fft_result);

        plot(frequencies, magnitude_spectrum, 'color', color_map(rep),'LineWidth', line_width);

    end
    xlim([0, 5]);
    ylim([0, 200]);
    title('Frequency-Domain Response (FFT)');
    xlabel('Frequency (Hz)');
    ylabel('Magnitude');
    grid on;

    fig_out_filename = [fish_name, '_body_pt_', num2str(tail_idx), '_Tail_FFT_by_fish_point', '.png'];

    grid on;
    saveas(gcf, [out_dir_figures, fig_out_filename]);
    disp(['SUCCESS: ', fig_out_filename, ' is saved.']);
end

% % Butterworth filter [Don't use yet]
% % Frequency response analysis
% [Hz, Freq] = freqz(b, a, 1024, 2); % 1024 points, normalized frequency range [0, 2]
%
% % Plot the magnitude and phase responses
% figure;
%
% % Magnitude response
% subplot(2, 1, 1);
% plot(Freq, 20*log10(abs(Hz)));
% title(['Magnitude Response: fs = ', num2str(fs), ' fc = ', num2str(fc)]);
% xlabel('Frequency (normalized)');
% ylabel('Magnitude (dB)');
% grid on;
%
% % Phase response
% subplot(2, 1, 2);
% plot(Freq, angle(Hz));
% title('Phase Response');
% xlabel('Frequency (normalized)');
% ylabel('Phase (radians)');
% grid on;
