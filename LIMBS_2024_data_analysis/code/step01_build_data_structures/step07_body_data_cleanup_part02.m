%% Step07_body_data_cleanup_part02.m
% Updated 03.24.2024
% LIMBS Lab
% Author: Huanying (Joy) Yeh

% Experiment Name: Eigenmannia Virescens Luminance + Locomotion Comparisons
%
% Content:
% - Now, we include bad tags from the "clean_data_head_point.mat"
% - There will be three sets of validity tags: valid_body, valid_head, valid_both
% - Output: save([abs_path, 'data_clean_body.mat'], 'all_fish');

%% 1. Load the full body + rotated struct
parent_dir = fullfile(pwd, '..', '..');
abs_path = fullfile(parent_dir, 'data_structures\');
out_path = fullfile(parent_dir, 'data_structures\');
if ~exist(out_path, 'dir')
    mkdir(out_path);
end

all_fish = load(fullfile(abs_path, 'data_clean_body.mat'), 'all_fish').all_fish; 
load([abs_path, '\helper_structs\helper_bad_tags_both.mat']);

fishNames = {'Hope', 'Len', 'Doris', 'Finn', 'Ruby'}; % consistent with SICB
p2m = 0.0004;
num_frames = 500;


pixel_thresh = 360; % right most pixel thresh is 360 out of 640 for head origin
valid_percentage_threshold = 92; % Above 92% is good

% For filtering the y values
Fs = 25;
Fc = 5; % cutoff frequencyin Hz
Wn = Fc/(Fs/2); % Cut-off frequency for discrete-time filter
[b, a] = butter(2, Wn); % butterworth filter parameters


%% 2. Populate validity tags
tally = [];
for i = 1 : numel(fishNames)
    h =  findobj('type','figure');
    n_fig = length(h);

    fish_name = fishNames{i}; % Hope
    fish_idx = queryStruct(all_fish, 'fish_name', fish_name);
    fish = all_fish(fish_idx);

    % Assign all zeros by defualt
    for il = 1: numel(fish.luminance) % Through all il levels
        for idx = 1 : numel(fish.luminance(il).data) % through all data
            all_fish(fish_idx).luminance(il).data(idx).valid_head = [0, 0, 0];
            all_fish(fish_idx).luminance(il).data(idx).valid_body = [0, 0, 0];
            all_fish(fish_idx).luminance(il).data(idx).valid_tail = [0, 0, 0];
            % all_fish(fish_idx).luminance(il).data(idx).valid_tail_percent = [0, 0, 0];
            all_fish(fish_idx).luminance(il).data(idx).valid_both = [0, 0, 0];

            validity_tail = zeros(1, 3);
            tail_tags = zeros(1, 3);

            for rep = 1 : 3
                field_name = ['x_origin', num2str(rep)];

                idx_start = 250+(rep-1)*500+1;
                idx_end = idx_start + 499;
                origin_x = all_fish(fish_idx).luminance(il).data(idx).x_origin(idx_start : idx_end, :);

                logicalIndex = origin_x < pixel_thresh; % pixel_thresh = 360

                % Assign 1 to elements less than 340 and 0 otherwise using logical indexing
                resultArray = zeros(size(origin_x));
                resultArray(logicalIndex) = 1;
                good_percentage = sum(resultArray)/500 * 100;
                
 
                all_fish(fish_idx).luminance(il).data(idx).valid_tail(rep) = ...
                    round(good_percentage, 0) > valid_percentage_threshold;
                
                % [TEMP]
                all_fish(fish_idx).luminance(il).data(idx).valid_tail_percent(rep) = good_percentage;

                tally(end+1) = good_percentage;
              
            end
        end
    end

    % Head tags
    tags_head = ID(i).tags_clean_head;
    for row = 1 : size(tags_head, 1)
        good_il = tags_head(row, 1);
        good_tr = tags_head(row, 2);
        good_rep = tags_head(row, 3);

        % Get the dataset in the target luminance
        target_il = fish.luminance(good_il);
        dataset = target_il.data;

        target_idx = find(target_il.trial_indices == good_tr);
        if ~isempty(target_idx)
            % Make valid tag turn into 1
            all_fish(fish_idx).luminance(good_il).data(target_idx).valid_head(good_rep) = 1;
        end
    end

    % Body tags
    tags_body = ID(i).tags_clean_body;
    for row = 1 : size(tags_body, 1)
        good_il = tags_body(row, 1);
        good_tr = tags_body(row, 2);
        good_rep = tags_body(row, 3);

        % Get the dataset in the target luminance
        target_il = fish.luminance(good_il);
        dataset = target_il.data;

        target_idx = find(target_il.trial_indices == good_tr);
        if ~isempty(target_idx)
            % Make valid tag turn into 1
            all_fish(fish_idx).luminance(good_il).data(target_idx).valid_body(good_rep) = 1;
        end
    end

    % Both tags
    tags_both = ID(i).tags_clean_both;
    for row = 1 : size(tags_both, 1)
        good_il = tags_both(row, 1);
        good_tr = tags_both(row, 2);
        good_rep = tags_both(row, 3);

        % Get the dataset in the target luminance
        target_il = fish.luminance(good_il);
        dataset = target_il.data;

        target_idx = find(target_il.trial_indices == good_tr);
        if ~isempty(target_idx)
            % Make valid tag = 1
            % all_fish(fish_idx).luminance(good_il).data(target_idx).valid_both(good_rep) = 1;

            % [NEW] look at valid tail and go through another filtering for
            % TAIL
            if all_fish(fish_idx).luminance(good_il).data(target_idx).valid_tail(good_rep) == 1
                all_fish(fish_idx).luminance(good_il).data(target_idx).valid_both(good_rep) = 1;
            end

            % Re-interpolate x and y
            x_field = strcat('x_rot_rep',num2str(good_rep));
            y_field = strcat('y_rot_rep',num2str(good_rep));

            X = all_fish(fish_idx).luminance(good_il).data(target_idx).(x_field);
            Y = all_fish(fish_idx).luminance(good_il).data(target_idx).(y_field);

            x_tail_og = X(:, 12);
            y_tail_og = Y(:, 12);

            % 500 frames total 
            for k = 1:num_frames
                % Fit to 4th order
                p = polyfit(X(k,:),Y(k,:),4);
                px = linspace(X(k,1), X(k,end), 23);
                py = polyval(p,px);

                py2 = interp1(px,py,X(k,:));  
                if any(isnan(py2)) || any(isinf(py2))   
                    py2 = fillmissing(py2, 'linear'); % Example using linear interpolation to fill missing values
                end
    
                Y(k,:) = py2(:);
               
                % [INPUT] Toggle this to see the corrected fish video
                plot_animation = 0; 
                if plot_animation == 1
                    fig = figure(n_fig+1);
                    clf
                    set(gcf,'color','white')
                    set(gca,'LineWidth',1.5,'fontsize',14)

                    hold on
                    plot(X(k,:),Y(k,:),'r.-','LineWidth',2,'MarkerSize',20)
                    % plot(X_corrected_tmp(k,:),Y_corrected_tmp(k,:),'g.-','LineWidth',2,'MarkerSize',20)

                    plot(px,py,'k-','LineWidth',1.5,'MarkerSize',15)
                    axis([0 640 0 190])
                    fig.Position = [100, 100, 640, 190]; % [left, bottom, width, height]

                    box off
                    time_str = sprintf('%0.2f',round((k-1)/25,2));
                    
                    grid on
                    pause(1e-10)
                end

                
            end

            X(:, 12) = filtfilt(b, a, x_tail_og);
            Y(:, 12) = filtfilt(b, a, y_tail_og);

            % Re-populate
            all_fish(fish_idx).luminance(good_il).data(target_idx).(x_field) = X;
            all_fish(fish_idx).luminance(good_il).data(target_idx).(y_field) = Y;

        end
    end
    disp(['SUCCESS: ', fish_name, ' body validity tags are updated.'])
end

save([out_path, 'data_clean_body.mat'], 'all_fish');
disp("SUCCESS: all 3 validity tags are saved in 'data_clean_body.mat'.")

%% Helper: Find struct by field name
function i = queryStruct(struct, fieldName, query)
for i = 1:numel(struct)
    if isfield(struct(i), fieldName) && isequal(struct(i).(fieldName), query)
        return;
    end
end
end

