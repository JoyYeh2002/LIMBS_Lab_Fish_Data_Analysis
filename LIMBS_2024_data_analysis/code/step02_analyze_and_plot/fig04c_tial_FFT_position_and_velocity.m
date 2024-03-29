%% fig04c_tail_FFT_position_and_velocity.m
% Updated 03.26.2024
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
% "fig04c_tail_FFT_position_and_velocity_vs_illuminance.png

close all;
addpath 'helper_functions'

%% 1. Specify folder paths
parent_dir = fullfile(pwd, '..', '..');
abs_path = fullfile(parent_dir, 'data_structures\');
out_path = fullfile(parent_dir, 'figures\');
pdf_path = fullfile(parent_dir, 'figures_pdf\');

%% 1. Load the data
load(fullfile(abs_path, 'data_clean_body.mat'), 'all_fish'); % All the raw + cleaned data labels for Bode analyis

fishNames = {'Hope', 'Len', 'Doris', 'Finn', 'Ruby'}; % consistent with SICB
num_fish = 5;
num_body_pts = 12;
p2m = 0.0004;


colorMap = cool(num_fish + 1);

% Create a new struct
res = struct();

for i = 1 : numFish
    res(i).name = fishNames{i};
    res(i).lux_values = all_fish(i).lux_values;

    num_il_levels = numel(all_fish(i).luminance);
    this_fish_rms = cell(num_il_levels, 1);
    this_fish_dist = cell(num_il_levels, 1);
    this_fish_velocity = cell(num_il_levels, 1);

    for il =  1 : num_il_levels

        % make a container for this il level, range = 5 trials here
        num_trials = numel(all_fish(i).luminance(il).data);

        % Collect over all body points
        this_il_rms = zeros(num_trials, 12);
        this_il_dist = zeros(num_trials, 12);
        this_il_velocity = []; % zeros([num_trials, 3, 499, 12]);

        for trial_idx = 1  : num_trials

            % Grab the target data and calculate RMS
            data = all_fish(i).luminance(il).data(trial_idx); % This is Hope trial 30

            [rms_each_rep, trial_rms, dist_each_rep, trial_distances] = calculateCleanFullBodyRMS(data);
            [velocity_each_rep, trial_velocities, num_samples] = calculateCleanFullBodyVelocity(data);
     
            %% 3. Populate the struct
            res(i).luminance(il).data(trial_idx).trID = data.trial_idx;
            res(i).luminance(il).data(trial_idx).rms_reps = rms_each_rep';
            res(i).luminance(il).data(trial_idx).trial_rms = trial_rms';
            
            res(i).luminance(il).data(trial_idx).dist_reps = dist_each_rep';
            res(i).luminance(il).data(trial_idx).trial_distances = trial_distances';
            res(i).luminance(il).data(trial_idx).trial_velocity = trial_velocities;

            this_il_rms(trial_idx, :) = trial_rms';
            this_il_dist(trial_idx, :) = trial_distances';
            this_il_velocity = [this_il_velocity; trial_velocities];

        end

        % Populate at high level 
        this_fish_rms{il} = this_il_rms;
        this_fish_dist{il} = this_il_dist;
        this_fish_velocity{il} = this_il_velocity;
    end

    % Use a 14x12 matrix to contain the average RMS data
    this_fish_rms_avg = zeros(num_il_levels, num_body_pts);
    this_fish_dist_avg = zeros(num_il_levels, num_body_pts);

    for il = 1 : num_il_levels
        if ~isempty(this_fish_rms{il})
            this_fish_rms_avg(il, :) = nanmean(this_fish_rms{il}, 1);
            this_fish_dist_avg(il, :) = nanmean(this_fish_dist{il}, 1);
        end
    end
    
    res(i).lux_values = all_fish(i).lux_values;
    res(i).rmsMean = this_fish_rms_avg;
    res(i).distMean = this_fish_dist_avg;
    res(i).velocities = this_fish_velocity;

    disp(['SUCCESS: populated fish ', num2str(i)]);

end

save([abs_path, 'result_rms_velocity.mat'], 'res');
disp("SUCCESS: RMS + Fish velocity struct saved for the 'valid both' tags.")


for i = 1 % : num_fish
    res(i).name = fishNames{i};
    res(i).lux = all_fish(i).lux_values;
    res(i).lux = all_fish(i).lux_values;

    num_il_levels = numel(all_fish(i).luminance);

    this_fish_curvature_avg = zeros(num_il_levels, 1);

    for il = 1 % : num_il_levels
        num_trials = numel(all_fish(i).luminance(il).data);

        curvature_y_avg = zeros(num_trials, 1);

        for trial_idx = 1 : num_trials
            %% 3. Populate the struct

            for rep_idx = 1 : 3
                v = all_fish(i).luminance(il).data(trial_idx).valid_both;
                if v(rep_idx) == 1
                    field_x = ['x_rot_rep', num2str(rep_idx)];
                    field_y = ['y_rot_rep', num2str(rep_idx)];
                    
                    data_x = all_fish(i).luminance(il).data(trial_idx).(field_x);
                    data_y = all_fish(i).luminance(il).data(trial_idx).(field_y);
                end
            end
        end
    end
            res(i).luminance(il).trID = all_fish(i).data(il).trID;
            res(i).luminance(il).repID = all_fish(i).data(il).repID;

            x_data = cell2mat(all_fish(i).data(il).fishX(trial_idx)); % 500 x 1
            y_data = cell2mat(all_fish(i).data(il).fishY(trial_idx)); % 500 x 1

            this_il_varX(trial_idx, :) = var((x_data - mean_x),'omitnan');
            this_il_varY(trial_idx, :) = var((y_data - curvature_y_avg),'omitnan');
        end

        % Populate at high level
        res(i).lux(il) = all_fish(i).data(il).luxMeasured;

        this_fish_varX{il} = this_il_varX;
        this_fish_varY{il} = this_il_varY;

        res(i).luminance(il).varX = this_il_varX;
        res(i).luminance(il).varY = this_il_varY;

        this_fish_varX_avg(il, :) = nanmean(this_il_varX, 1);
        this_fish_varY_avg(il, :) = nanmean(this_il_varY, 1);
    
    res(i).varX_mean = this_fish_varX_avg;
    res(i).varY_mean = this_fish_varY_avg;




%% 4. Create curvature struct
for i = 1 % : 5
    counter = 1;

    tic
    for il  = 1 : num_ils(i)
        for trial_idx = 1:size(fish_data{i, il}, 2)
            v = fish_data{i, il}(trial_idx).valid_both;

            for rep = 1:3
                x_field = strcat('x_rot_rep',num2str(rep)); % create x_rep1, x_rep2,...
                y_field = strcat('y_rot_rep',num2str(rep)); % create y_rep1, y_rep2,...

                if isfield(fish_data{i, il}(trial_idx),(x_field)) % check if the field exists

                    % 500 x 12 double
                    X = fish_data{i, il}(trial_idx).(x_field);
                    Y = fish_data{i, il}(trial_idx).(y_field);

                    % fixing at second body point
                    X = X - X(:,2);
                    Y = Y - Y(:,2);

                    % fix body point #2 to (0,0), but head point would be
                    % negative
                    if v(rep) == 0
                        X_corrected_tmp = [];
                        Y_corrected_tmp = [];

                        % Only calculate it when it's valid
                    elseif v(rep) == 1
                        X_corrected_tmp = nan(num_frames,12);
                        Y_corrected_tmp = nan(num_frames,12);


                        % 500 frames total
                        for k = 1:num_frames

                            % Fit to 4th order
                            p = polyfit(X(k,:),Y(k,:),4);
                            px = linspace(X(k,1), X(k,end), num_interp_pts);
                            py = polyval(p,px);

                            % Call the arc length helper function
                            % [arclen, ~] = arclength(px,py,'spline');
                            % Arc_Len(k) = arclen;

                            py2 = interp1(px,py,X(k,:));
                            X_corrected_tmp(k,:) = X(k,:) - X(k,2);
                            Y_corrected_tmp(k,:) = py2(:) - py2(2);

                        end

                        n_fig = n_fig+1;

                        X_corrected{il,trial_idx,rep} = X_corrected_tmp;
                        Y_corrected{il,trial_idx,rep} = Y_corrected_tmp;
                    end

                end
            end
        end

    end
    disp(['IL = ', num2str(il), ' is completed.'])
end

elpased_time = toc;
fprintf('Elapsed time in min = %0.2f\n',round(elpased_time/60,2))

% Save the body curve data
file_name = char(strcat(fishNames(i),'_TEST_HEAT_MAP.mat'));
save(file_name,'X_corrected','Y_corrected')
disp(['SUCCESS: ', fishNames(i), file_name, ' saved.'])
return

%%
trial_idx = 1;
for rep = 1:3
    figure;
    set(gcf,'color','white')
    set(gca,'LineWidth',1.5,'fontsize',14)
    hold on
    colors = jet(size(Y,2));
    for c = 1:size(Y,2)
        plot(Y_corrected{trial_idx,rep}(:,c)*p2m*100,'LineWidth',2,'Color',[colors(c,:), 0.6])
    end
    title(['Fish:',fishNames{i},...
        ', IL Level:',num2str(il),...
        ', Trial:',num2str(fish_data{i, il}(trial_idx).trial_idx),...
        ', Rep:',num2str(rep)],'FontSize',16,'FontWeight','normal')
    xlabel('Frames','FontSize',16)
    ylabel('Postion in cm','FontSize',16)
    c = colorbar;
    colormap(colors)
    c.Ticks = linspace(0,1,size(Y,2)+1)+1/(size(Y,2))/2;
    c.TickLabels = num2cell(1:1:(size(Y,2)+1));
    c.Label.String = 'Body Points';
    c.Label.FontSize = 14;
    ylim([-2.5 2.5])
end



