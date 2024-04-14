% WHat's happening to the data??
%% 1. Load the data
close all

abs_path = 'C:\Users\joy20\Folder\SP_2024\LIMBS_2024_data_analysis\code\playground\';

% Save the copies into fig and fig_pdf
out_path = [abs_path, 'Tail_V_Ang_Histogram_Compare\'];
if ~exist(out_path, 'dir')
    mkdir(out_path);
end

struct_file_real = load([abs_path, 'data_clean_body_real.mat']); % All the raw + cleaned data labels for Bode analyis
fish_real = struct_file_real.all_fish;

struct_file_dev = load([abs_path, 'data_clean_body_dev.mat']); % All the raw + cleaned data labels for Bode analyis
fish_dev = struct_file_dev.all_fish;

% Toggle visibiilty
visible = 0;

% Loop through
for i = [1, 3, 4]
    for il = [2, 4, 6, 9]
        for trial_idx = [2, 3, 4]
            for rep = [1, 3]
                field_x = ['x_rot_rep', num2str(rep)];
                field_y = ['y_rot_rep', num2str(rep)];

                % only use valid trials
                v = fish_dev(i).luminance(il).data(trial_idx).valid_both(rep);
                if v == 0
                    continue;
                end
                
                try
                    % Get the data
                    dev_x = fish_dev(i).luminance(il).data(trial_idx).(field_x)(:, 12);
                    dev_y = fish_dev(i).luminance(il).data(trial_idx).(field_y)(:, 12);

                    real_x = fish_real(i).luminance(il).data(trial_idx).(field_x)(:, 12);
                    real_y = fish_real(i).luminance(il).data(trial_idx).(field_y)(:, 12);

                    % Your processing code here
                    % ...
                catch
                    % Skip this iteration if an error occurs (e.g., fields do not exist)
                    continue;
                end

                time = 1:500;
                p2m = 0.0004;
                dt = 0.04;

                % Calculate the velocity distribution for this trial
                v_ang_dev = get_v_ang(dev_x, dev_y, p2m, dt);
                v_ang_real = get_v_ang(real_x, real_y, p2m, dt);

                big_title = ['Fish ', num2str(i), ', IL = ', num2str(il), ', Trial = ', num2str(trial_idx), ', Rep = ', num2str(rep)]

                % Just compare the y1 (dev) and y2 (real) values
                y_compare_figure = plot_compare(time(1:end-1), v_ang_dev, v_ang_real, big_title, visible);
                saveas(y_compare_figure, [out_path, 'fish_', num2str(i), '_il_', num2str(il), '_tr_', num2str(trial_idx), '_rep_', num2str(rep), 'tail_vel_compare.png']);
                disp('SUCCESS: y_compare figure saved.')

                % Compare histograms
                hist_figure = plot_histogram_compare(v_ang_dev, v_ang_real, big_title, visible);
                saveas(hist_figure, [out_path, 'fish_', num2str(i), '_il_', num2str(il), '_tr_', num2str(trial_idx), '_rep_', num2str(rep), 'tail_vel_hist.png']);
                disp('SUCCESS: side-by-side hist saved.')

            end
        end
    end
end

function v_ang = get_v_ang(x, y, p2m, dt)
x_disp = x - 220 * p2m; % 500 x 12
y_disp = y - 110 * p2m;

angles = rad2deg(atan2(y_disp, x_disp));
v_ang = diff(angles) / dt; % Unwrap angles to handle discontinuities 499 x 12
end

function y_compare_figure = plot_compare(x, y1, y2, big_title, visible)
y_compare_figure = figure;
if visible == 0
    set(gcf, 'visible', 'off')
end

hold on
plot(x, y1, 'color', 'b');
plot(x, y2, 'color', 'm');
legend;
title(big_title);

% set(gcf, 'visible', 'off')

end


function hist_figure = plot_histogram_compare(v_ang_dev, v_ang_real, big_title, visible)
resolution = 30;
y_lim = 0.13;
edges = linspace(min(v_ang_dev), max(v_ang_real), resolution);
hist_dev = histcounts(v_ang_dev, edges, 'Normalization', 'probability');
hist_real = histcounts(v_ang_real, edges, 'Normalization', 'probability');

hist_figure = figure; % Create a new figure
if visible == 0
    set(gcf, 'visible', 'off')
end

% Plot the histogram for v_ang_real
subplot(1,2,1); % Create a subplot for the real histogram
bar(edges(1:end-1), hist_real, 'FaceColor', [0.8 0.2 0.2], 'FaceAlpha', 0.5); % Set the FaceAlpha for transparency
xlabel('Bins');
ylabel('Probability');
ylim([0, y_lim])
title('Real Histogram');

% Plot the histogram for v_ang_dev
subplot(1,2,2); % Create a subplot for the dev histogram
bar(edges(1:end-1), hist_dev, 'FaceColor', [0.2 0.2 0.8], 'FaceAlpha', 0.5); % Set the FaceAlpha for transparency
xlabel('Bins');
ylabel('Probability');
ylim([0, y_lim])
title('Dev Histogram');

% Add a big title above the subplots
sgtitle(big_title);

end