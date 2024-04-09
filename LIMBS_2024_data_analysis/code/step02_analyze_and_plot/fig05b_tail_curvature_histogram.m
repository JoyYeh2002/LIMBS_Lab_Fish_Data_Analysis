%% fig05b_tail_curvature_histogram.m
% LIMBS Lab
% Author: Huanying (Joy) Yeh

% Experiment Name: Eigenmannia Virescens Luminance + Locomotion Comparisons
%
% Content:
% - Calculate and save tail curvature info to "result_tail_curvature.mat"
% - Plot "fig05b_tail_curvature_histogram.png"
%
% Caution:
% - Need to run "fig04b_tail_fft_position_and_velocity.m

close all;
addpath 'helper_functions'

%% 1. Specify folder paths
parent_dir = fullfile(pwd, '..', '..');
abs_path = fullfile(parent_dir, 'data_structures\');
out_path = fullfile(parent_dir, 'figures\');

out_archive_path = fullfile(parent_dir, 'figures_archive\fig05b_tail_curvature\');
if ~exist(out_archive_path, 'dir')
    mkdir(out_archive_path);
end

pdf_path = fullfile(parent_dir, 'figures_pdf\');

close all

%% 2. Load the full body struct and tail FFT struct
all_fish = load(fullfile(abs_path, 'data_clean_body.mat'), 'all_fish').all_fish;
fishNames = {'Hope', 'Len', 'Doris', 'Finn', 'Ruby'}; % consistent with SICB

% Keep populating the res FFT struct
out_filename = 'result_tail_fft_and_curvature.mat';
res = load(fullfile(abs_path, out_filename), 'res').res;

p2m = 0.0004;
num_frames = 500;

% [INPUT]
% sample_fish_i = [1, 3]; % Select fish #1 to be in the final paper

calculate_things = 1;
if calculate_things == 1
    %% 3. Calculate curvature and save to struct
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

                v = all_fish(i).luminance(il).data(trial_idx).valid_both;
                for rep = 1 : 3
                    valid = v(rep);
                    if valid == 1
                        % Get meta data
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

            num_valid_trials = numel(res(i).luminances(il).x_tail);
            if num_valid_trials > 3

                % 500 x 6 double
                this_il_tail_curves = nan(500, num_valid_trials);
                for idx = 1 : num_valid_trials

                    % 500 x 10
                    data_elements = res(i).luminances(il).body_curvature;
                    curv_arr = cell2mat(data_elements(:, idx)); % 500 x 10

                    % 500 x 1
                    curv_arr_tail = curv_arr(:, end);

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
    end

    % Save to another struct
    save([abs_path, out_filename], 'res');
    disp(['FFT and tail curve saved in ', out_filename]);

end


plot_stuff = 1;

if plot_stuff == 1

    for i = 1 
        main_figure = figure('Position', [100, 50, 800, 500]);
        fish_name = fishNames{i};

        clear Z
        set(gca,'LineWidth',1.5,'FontSize',14)
        hold on
        edges = linspace(0,0.3,100);

        lux_ticks = [];
        Z = []; % 14 x 99 double
        lux = all_fish(i).lux_values;
        num_ils = size(lux, 2);
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

        surf(X,Y,smoothdata((Z),2,"movmean",3)); % Change to surf plot
        % colormap(cool); % Set colormap
        
        default_colors = get(gca, 'ColorOrder');


        view([45 30])
        xlabel('Curvature')
        xlim([0, 0.1]);
        set(gca, 'XGrid', 'off'); % Turns off the x grid

        set(gca, 'YScale', 'log');
        ylabel('Illumination (lux)');
        yticks(lux);
        yticklabels(lux);
        ylim([0, 220]);

        zlabel('Probability')
        sgtitle(['Fish: ',fish_name,', Tail Point Curvature All'],'fontsize',14)

        c = colorbar; % Add color bar
        c.Title.String = 'Probability'; % Add title to the color bar

        saveas(main_figure, [out_archive_path, 'tail_curvature_main_v3_', fish_name, '.png']);
        disp(["SUCCESS: tail curvature main: ", fish_name, " saved in archive."])

        top_figure = figure('Position', [100, 50, 800, 500]);

        surf(X,Y,smoothdata((Z),2,"movmean",3)); % Change to surf plot
        view([0 0 90])
        xlabel('Curvature')
        xlim([0, 0.1]);
        set(gca, 'XGrid', 'off'); % Turns off the x grid

        set(gca, 'YScale', 'log');
        ylabel('Illumination (lux)');
        yticks(lux);
        yticklabels(lux);
        ylim([0, 220]);

        zlabel('Probability')
        sgtitle(['Fish: ',fish_name,', Tail Point Curvature Tip'],'fontsize',14)

        c = colorbar; % Add color bar
        c.Title.String = 'Probability'; % Add title to the color bar

        % saveas(top_figure, [out_archive_path, 'tail_curvature_top_v3_', fish_name, '.png']);
        % disp(["SUCCESS: tail curvature top view: ", fish_name, " saved in archive."])

        saveas(top_figure, [out_archive_path, 'tail_curvature_top_v4_', fish_name, '.png']);
        disp(["SUCCESS: tail curvature top view: ", fish_name, " saved in archive."])

    end
end



% Save all images to archive folder
% saveas(main_figure, [out_archive_path, fish_name, '.png']);

% Save sample fish as official paper figure
% if ismember(i, sample_fish_i)
%     saveas(main_figure, [out_path, 'fig04b_tail_FFT_vs_illuminance_', fish_name, '.png']);
%     saveas(main_figure, [pdf_path, 'fig04b_tail_FFT_vs_illuminance_', fish_name, '.pdf']);
% end
%
% disp(['SUCCESS: ', 'fig04b_tail_FFT_vs_illuminance_', fish_name, ' is saved.']);
% end
%
% save([abs_path, 'result_tail_fft.mat'], 'res');
% disp("Tail FFT information saved in 'result_tail_fft.mat'.")




