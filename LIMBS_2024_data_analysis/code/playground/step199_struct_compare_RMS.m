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
visible = 1;

time = 1:500;
p2m = 0.0004;
dt = 0.04;

% Loop through
for i = [1, 3, 4]
    for il = [2, 4, 6, 9]
        for trial_idx =  [3, 4]
            for rep = [1, 2, 3]
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
                    dev_data = fish_dev(i).luminance(il).data(trial_idx);
                    dev_rms = calculateCleanFullBodyRMS(dev_data);

                    real_x = fish_real(i).luminance(il).data(trial_idx).(field_x)(:, 12);
                    real_y = fish_real(i).luminance(il).data(trial_idx).(field_y)(:, 12);
                    real_data = fish_real(i).luminance(il).data(trial_idx);
                    real_rms = calculateCleanFullBodyRMS(real_data);
                    
                
                catch
                    continue;
                end

                % Calculate the velocity distribution for this trial
               
                big_title = ['Fish ', num2str(i), ', IL = ', num2str(il), ', Trial = ', num2str(trial_idx), ', Rep = ', num2str(rep)];


                %% 04-12: Compare tail RMS
                body_points = [1:12];
                body_points = body_points';
                rms_compare_figure = plot_compare_rms(body_points, dev_rms, real_rms, big_title, visible);
                % saveas(y_compare_figure, [out_path, 'fish_', num2str(i), '_il_', num2str(il), '_tr_', num2str(trial_idx), '_rep_', num2str(rep), 'tail_vel_compare.png']);
                % disp('SUCCESS: y_compare figure saved.')



                %% 04-10: Just compare the y1 (dev) and y2 (real) values

                % y_compare_figure = plot_compare(time(1:end-1), v_ang_dev, v_ang_real, big_title, visible);
                % saveas(y_compare_figure, [out_path, 'fish_', num2str(i), '_il_', num2str(il), '_tr_', num2str(trial_idx), '_rep_', num2str(rep), 'tail_vel_compare.png']);
                % disp('SUCCESS: y_compare figure saved.')

                % Compare histograms
                % hist_figure = plot_histogram_compare(v_ang_dev, v_ang_real, big_title, visible);
                % saveas(hist_figure, [out_path, 'fish_', num2str(i), '_il_', num2str(il), '_tr_', num2str(trial_idx), '_rep_', num2str(rep), 'tail_vel_hist.png']);
                % disp('SUCCESS: side-by-side hist saved.')



            end
        end
    end
end


%% HELPER: Get the 12x3 and 12x1 RMS arrays
function [rms_displacement] = calculateCleanFullBodyRMS(data)

v = data.valid_both; % [NEW] USE BOTH VALID
p2cm = 0.04; % [CAUTION] use cm as the unit, rather than meters
x = {data.x_rot_rep1 * p2cm, data.x_rot_rep2 * p2cm, data.x_rot_rep3 * p2cm};
y = {data.y_rot_rep1 * p2cm, data.y_rot_rep2 * p2cm, data.y_rot_rep3 * p2cm};

% Calculate displacement, 3 reps total, 12 body points
rms_displacement = zeros(12, 3); % These might have zeros if invalid

for i = 1 : size(x, 2) % Loop through 3 reps
    if v(i) == 1 % if this rep is valid

        rms_displacement(:, i) = rms((y{i} - nanmean(y{i})),'omitnan');
    else
        rms_displacement(:, i) = 0;
    end
end

end



function v_ang = get_v_ang(x, y, p2m, dt)
x_disp = x - 220 * p2m; % 500 x 12
y_disp = y - 110 * p2m;

angles = rad2deg(atan2(y_disp, x_disp));
v_ang = diff(angles) / dt; % Unwrap angles to handle discontinuities 499 x 12
end

function compare_figure = plot_compare_rms(x, y1, y2, big_title, visible)
compare_figure = figure;
if visible == 0
    set(gcf, 'visible', 'off')
else
    set(gcf, 'visible', 'on')
end

hold on

for i = 1 : 3
    plot(x, y1(:, i), 'color', 'b');
    plot(x, y2(:, i), 'color', 'm');
    disp('hello')

end
legend;
title(big_title);

end


function y_compare_figure = plot_compare(x, y1, y2, big_title, visible)
y_compare_figure = figure;
if visible == 0
    set(gcf, 'visible', 'off')
else
    set(gcf, 'visible', 'on')
end

hold on
plot(x, y1, 'color', 'b');
plot(x, y2, 'color', 'm');
legend;
title(big_title);

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
else
    set(gcf, 'visible', 'on')
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