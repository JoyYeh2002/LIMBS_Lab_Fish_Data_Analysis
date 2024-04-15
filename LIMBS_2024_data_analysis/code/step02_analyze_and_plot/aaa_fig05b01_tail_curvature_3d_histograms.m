%% fig05b_tail_curvature_histogram.m
% LIMBS Lab
% Author: Huanying (Joy) Yeh

% Experiment Name: Eigenmannia Virescens Luminance + Locomotion Comparisons
%
% Caution:
% - Need to run "fig04b_tail_fft_position_and_velocity.m to obtain the base
% struct
%
% Content:
% - Calculate and save tail curvature info to "result_tail_fft_and_curvature.mat"
% - Plot the following in "\figures"
% - "fig05b01_tail_curve_hist_3d_ruby.png"
% - "fig05b02_tail_curve_hist_top_hope.png"
% - "fig05b03_tail_curve_hist_top_len.png"
% - "fig05b04_tail_curve_hist_top_doris.png"
% - "fig05b05_tail_curve_hist_top_finn.png"
% - "fig05b06_tail_curve_hist_top_ruby.png"
%
% - These in "\figures_archive\fig05b_tail_curvature_distributions\"
% - "fig05b01_tail_curve_hist_3d_hope.png"
% - "fig05b01_tail_curve_hist_3d_len.png"
% - "fig05b01_tail_curve_hist_3d_doris.png"
% - "fig05b01_tail_curve_hist_3d_finn.png"
%
% - Save the struct with curvature. Save in
% "result_tail_curvature.mat"


close all;
addpath 'helper_functions'


%% 0: inputs - whether to plot the 3d distributions or 2d
populate_curvature_struct = 0;
plot_3d = 1;
plot_2d = 0;


%% 1. Specify folder paths
parent_dir = fullfile(pwd, '..', '..');
abs_path = fullfile(parent_dir, 'data_structures\');
out_path = fullfile(parent_dir, 'figures\');
pdf_path = fullfile(parent_dir, 'figures_pdf\');

out_archive_path = fullfile(parent_dir, 'figures_archive\fig05b_tail_curvature_distributions\');
if ~exist(out_archive_path, 'dir')
    mkdir(out_archive_path);
end

close all

%% 2. Load the full body struct and tail FFT struct
all_fish = load(fullfile(abs_path, 'data_clean_body.mat'), 'all_fish').all_fish;
fishNames = {'Hope', 'Len', 'Doris', 'Finn', 'Ruby'}; % consistent with SICB

% [Input] target fish to save (Ruby)
target_fish_idx = 5;

% Keep populating the res FFT struct

p2m = 0.0004;
num_frames = 500;
font_size = 10;
y_label_rotation = 30;
x_label_rotation = -10;

%% 3. Calculate curvature and save to struct
if populate_curvature_struct == 1
    res = load(fullfile(abs_path, 'result_tail_positions.mat'), 'raw').raw;

    for i = 1 : 5
        h =  findobj('type','figure');
        n_fig = length(h);

        fish_name = fishNames{i};
        num_ils = numel(all_fish(i).luminance);

        for il = 1: num_ils
            num_trials = numel(all_fish(i).luminance(il).data);
            count = 1;

            % Add the new field
            res(i).luminances(il).body_curvature = {};

            for trial_idx = 1 : num_trials
                f = all_fish(i).luminance(il).data(trial_idx);

                % Calculate cuvature (10 points along the body total)
                v = all_fish(i).luminance(il).data(trial_idx).valid_both;
                for rep = 1 : 3
                    valid = v(rep);
                    if valid == 1
                        field_name_x = ['x_rot_rep', num2str(rep)];
                        field_name_y = ['y_rot_rep', num2str(rep)];
                        x = f.(field_name_x);
                        y = f.(field_name_y);

                        radii = zeros(500, 10);
                        for ii = 1 : 500
                            [~,R,~] = curvature([x(ii, :)'*p2m*100,y(ii, :)'*p2m*100]); % Unit: cm
                            radii(ii, :) = 1./R(2:end-1);
                        end

                        res(i).luminances(il).body_curvature{end+1} = radii; % radius of curvature
                        count = count + 1;
                    end
                end
            end

            % Record illumiannce conditions with > 3 good trials
            num_valid_trials = numel(res(i).luminances(il).x_tail);
            if num_valid_trials > 3

                this_il_tail_curves = nan(500, num_valid_trials);
                for idx = 1 : num_valid_trials
                    data_elements = res(i).luminances(il).body_curvature;
                    curv_arr = cell2mat(data_elements(:, idx)); % 500 x 10
                    curv_arr_tail = curv_arr(:, end); % 500 x 1

                    % Populate that row (500 x 1)
                    this_il_tail_curves(:, idx) = curv_arr_tail;
                end

                % 500 x 1, assign to struct
                this_il_tail_curves_mean = mean(this_il_tail_curves, 2);
                res(i).luminances(il).tail_curvature_mean = this_il_tail_curves_mean;

            else % invalid
                res(i).luminances(il).tail_curvature_mean = [];
            end
        end
        disp(['SUCCESS: ', fish_name, ' FFT and curvature data saved.']);
    end

    % Save to another struct
    save([abs_path, 'result_tail_curvature.mat'], 'res');
    disp('FFT and tail curve saved in result_tail_curvature.mat.');
end

%% Plotting starts here
% Loop through all the fish
for i = 1:5

    % ------------------------- 3D view plot ------------------------------
    if plot_3d == 1
        main_figure = figure('Position', [100, 50, 800, 500]);
        set(gcf, 'Visible', 'off');

        fish_name = fishNames{i};

        clear Z
        set(gca,'LineWidth',1.5,'FontSize',14)
        hold on
        edges = linspace(0,0.3,100);

        lux_ticks = [];
        Z = []; % 14 x 99 double
        lux = all_fish(i).lux_values;
        num_ils = size(lux, 2);

        % Plot the 3d surface plot of the tail curvature distribution histogram
        for il  = 1:num_ils
            curv = res(i).luminances(il).tail_curvature_mean;
            if isempty(curv)
                continue;
            else
                h = histogram(curv, edges,'Normalization','probability');
                lux_ticks = [lux_ticks, lux(il)];
                Z = [Z; h.Values];
                delete(h); % Remove the histogram plot
            end
        end

        [X,Y] = meshgrid(edges(1:end-1), lux_ticks);

        surf(X,Y,smoothdata((Z), 2, "movmean", 3));
        default_colors = get(gca, 'ColorOrder');

        view([15 50])

        xlabel('Curvature', 'FontSize', font_size, 'Rotation', x_label_rotation);
        xlim([0, 0.1]);
        set(gca, 'XGrid', 'off');

        set(gca, 'YScale', 'log');
        ylabel('Illumination (lux)', 'FontSize', font_size, 'Rotation', y_label_rotation);
        lux_ticks_3d = [0.4, 1, 2, 3.5, 7, 15, 30, 60, 150, 210];
        yticks(lux_ticks_3d);
        yticklabels(lux_ticks_3d);
        ylim([0, 220]);

        zlabel('Probability', 'FontSize', font_size);
        sgtitle([fish_name, ' Tail Point Curvature Distribution (3D)'],'fontsize', font_size)

        c = colorbar;
        c.Title.String = 'Probability';

        set(gca, 'FontSize', font_size);

        % Save the 3d image
        saveas(main_figure, [out_archive_path, 'curve_hist_3d_', fish_name, '.png']);
        disp(['SUCCESS: tail curvature 3D view: ', fish_name, ' saved in archive.']);

        % Save to fig output and pdf folder
        if i == target_fish_idx
            saveas(main_figure, [out_path, 'fig05b01_tail_curve_hist_3D_', fish_name, '.png']);
            saveas(main_figure, [pdf_path, 'fig05b01_tail_curve_hist_3D_', fish_name, '.pdf']);
            disp(['SUCCESS: fig05b01 (3d) for ', fish_name, ' saved to .png and .pdf.'])
        end
    end
    % ------------------------- Top view plots ----------------------------

    if plot_2d == 1
        top_figure = figure('Position', [100, 50, 800, 500]);
        set(gcf, 'Visible', 'off');

        surf(X,Y,smoothdata((Z), 2, "movmean", 3));

        view([0 0 90])
        xlabel('Curvature')
        xlim([0, 0.1]);
        set(gca, 'XGrid', 'off');

        set(gca, 'YScale', 'log');
        ylabel('Illumination (lux)');
        yticks(lux);
        yticklabels(lux);
        ylim([0, 220]);

        zlabel('Probability')
        sgtitle([fish_name, ' Tail Point Curvature Distribution (Top View)'],'fontsize', font_size)

        c = colorbar;
        c.Title.String = 'Probability';
        set(gca, 'FontSize', font_size);

        % Save the top view image into archive
        saveas(top_figure, [out_archive_path, 'curve_hist_top_', fish_name, '.png']);
        disp(['SUCCESS: tail curvature top view: ', fish_name, ' saved in archive.'])

        % Save the copies into fig and fig_pdf
        saveas(top_figure, [out_path, 'fig05b0', num2str(i+1), '_tail_curve_hist_top_view_', fish_name, '.png']);
        saveas(top_figure, [pdf_path, 'fig05b0', num2str(i+1), '_tail_curve_hist_top_view_', fish_name, '.pdf']);
        disp(['SUCCESS: fig05b for ', fish_name, ' saved to .png and .pdf.'])
    end
end
