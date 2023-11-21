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
struct_filename = [abs_path, 'DORIS_IL3_TR34_DATA.mat'];


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
line_width = 2;

% Get the tail point of y, rep 1
for rep = 2:3
    % Go along the whole body
    for tail_idx = 1:12
        figure;
        hold on;
        subplot(2, 1,1);

        y_tail = y{rep}(:, tail_idx) * P2M_SCALE * 100; % in cm
        y_tail = filtfilt(b, a, y_tail); % apply the butterworth fiter

        % Plot the time-domain signal

        % plot(time, y_tail, 'color', color_map(tail_idx, :),'LineWidth', line_width);
        plot(time, y_tail, 'color', color_map(tail_idx, :),'LineWidth', line_width);
        xlim([0, 20]);
        ylim([0, 8]); % 0.08m = 8cm
        xlabel("Time(s)")
        ylabel("Y-Pos (cm)")
        title(['Doris Il = 3, Trial34, Rep ', num2str(rep), ' Body pt: ', ...
            num2str(tail_idx), ' Time Domain Y Positions']);
        grid on;

        % Plot the frequency-domain response (magnitude spectrum)
        subplot(2, 1, 2);

        % Perform FFT
        N = length(y_tail);    % Length of the signal
        Fs = 25; %Hz
        frequencies = (0:N-1) * Fs / N;  % Frequency axis for the FFT result
        fft_result = fft(y_tail - mean(y_tail), N);
        magnitude_spectrum = abs(fft_result);

        plot(frequencies, magnitude_spectrum, 'color', color_map(tail_idx, :),'LineWidth', line_width);
        xlim([0, 5]);
        ylim([0, 150]);
        title('Frequency-Domain Response (FFT)');
        xlabel('Frequency (Hz)');
        ylabel('Magnitude');
        grid on;

        fig_out_filename = [fish_name, '_Tail_FFT_filt_pt_', num2str(tail_idx), '_rep_', num2str(rep), '.png'];

        grid on;
        saveas(gcf, [out_dir_figures, fig_out_filename]);
        disp(['SUCCESS: ', fig_out_filename, ' is saved.']);
    end
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
