%% Step04_body_data_rotate.m
% Updated 03.23.2024
% LIMBS Lab
% Author: Huanying (Joy) Yeh

% Experiment Name: Eigenmannia Virescens Luminance + Locomotion Comparisons
% Content: Full Body Tracking - rotate the fish tracked points along the
% main body axis
% - Load "data_raw_body.mat"
% - Rotate all the x an y positions according to the first 3 points on the
% fish, which indicates the main body axis
% - Outputs a struct: 'data_structures/data_clean_body.mat'

%% 1. Specify folder paths and set up
parent_dir = fullfile(pwd, '..', '..');
abs_path = fullfile(parent_dir, 'data_structures\');
out_path = fullfile(parent_dir, 'data_structures\');
all_fish = load(fullfile(abs_path, 'data_raw_body.mat'), 'all_fish').all_fish; 

fishNames = {'Hope', 'Len', 'Doris', 'Finn', 'Ruby'}; % consistent with SICB
numIls = [14, 9, 11, 9, 9];
numFish = 5;

%% 2. Loop through and rotate all fish w.r.t. main body axis
for k = 1 : numFish
    fish_name = fishNames{k};
    fish_idx = queryStruct(all_fish, 'fish_name', fish_name);

    for il = 1 : numel(all_fish(fish_idx).luminance)
        for tr_idx = 1 : numel(all_fish(fish_idx).luminance(il).data)
            f = all_fish(fish_idx).luminance(il).data(tr_idx); % This is trial 31
            
            % Loop through all the frames in a trial
            rotated_x = zeros(1777, 12);
            rotated_y = zeros(1777, 12);
            
            for frame_idx = 1:1777
                % Get the 12 points throughout the image
                x = f.x_data_raw(frame_idx, :);
                y = f.y_data_raw(frame_idx, :);
            
                % Linear fit with the first 3 points and rotate the fish
                coefficients = polyfit(x(1:3), y(1:3), 1);
                theta = atan(coefficients(1));
                [rotated_x(frame_idx, :), rotated_y(frame_idx, :)] = rotatePoints(x, y, x(2), y(2), theta);
                
            end
            
            % Put back into the struct
            % all_fish(fish_idx).luminance(il).data(tr_idx).x_rot = rotated_x;
            % all_fish(fish_idx).luminance(il).data(tr_idx).y_rot = rotated_y;
            
            % Segments into 3 reps, then save to struct
            all_fish(fish_idx).luminance(il).data(tr_idx).x_rot_rep1 = rotated_x(251 : 750, :);
            all_fish(fish_idx).luminance(il).data(tr_idx).x_rot_rep2 = rotated_x(751 : 1250, :);
            all_fish(fish_idx).luminance(il).data(tr_idx).x_rot_rep3 = rotated_x(1251 : 1750, :);
            
            all_fish(fish_idx).luminance(il).data(tr_idx).y_rot_rep1 = rotated_y(251 : 750, :);
            all_fish(fish_idx).luminance(il).data(tr_idx).y_rot_rep2 = rotated_y(751 : 1250, :);
            all_fish(fish_idx).luminance(il).data(tr_idx).y_rot_rep3 = rotated_y(1251 : 1750, :);
        end

        % Remove raw data fields
        all_fish(fish_idx).luminance(il).data = rmfield(all_fish(fish_idx).luminance(il).data, ...
            {'x_data_raw', 'y_data_raw', 'x_rep1', 'x_rep2', 'x_rep3', 'y_rep1', 'y_rep2', 'y_rep3'});
        
        disp([' -- COMPLETED IL = ', num2str(il), ' --------']);
    end
    disp(['COMPLETED FISH ', fish_name, ' ----------'])
end

%% 3. Update and save to a new struct
save([out_path, 'data_clean_body.mat'], 'all_fish');
disp("SUCCESS: /data_structures/data_clean_body.mat generated with rotated values.")

%% Helper: Find struct by field name
function i = queryStruct(struct, fieldName, query)
for i = 1:numel(struct)
    if isfield(struct(i), fieldName) && isequal(struct(i).(fieldName), query)
        return;
    end
end
end

%% Helper: Rotate all the x and y data w.r.t the origin point
function [rotated_x, rotated_y] = rotatePoints(x, y, origin_x, origin_y, theta_rad)
    % Rotate each point around the origin
    rotated_x = (x - origin_x) * cos(-theta_rad) - (y - origin_y) * sin(-theta_rad) + origin_x;
    rotated_y = (x - origin_x) * sin(-theta_rad) + (y - origin_y) * cos(-theta_rad) + origin_y;
end
