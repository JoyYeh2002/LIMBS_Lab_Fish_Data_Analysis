%% Step02_rotate_full_length_struct.m
% Updated 02.15.2024
% LIMBS Lab
% Author: Huanying (Joy) Yeh

% Experiment Name: Eigenmannia Virescens Luminance + Locomotion Comparisons
% 
% Content: 
% - Rotate the x and y values from "data_raw_body.mat" 
% - Outputs to "data_clean_body.mat"
% - Next step: add body tags

%% 1. Load the struct from step01
close all;
abs_path = 'C:\Users\joy20\Folder\FA_2023\LIMBS Presentations\data\fish_structs_2024\';
out_path = 'C:\Users\joy20\Folder\FA_2023\LIMBS Presentations\Data\fish_structs_2024\';
load([abs_path, 'data_raw_body.mat']); 

fishNames = {'Hope', 'Len', 'Doris', 'Finn', 'Ruby'}; % consistent with SICB 
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
            all_fish(fish_idx).luminance(il).data(tr_idx).x_rot = rotated_x;
            all_fish(fish_idx).luminance(il).data(tr_idx).y_rot = rotated_y;
            
            % Segments into 3 reps, then save to struct
            all_fish(fish_idx).luminance(il).data(tr_idx).x_rot_rep1 = rotated_x(251 : 750, :);
            all_fish(fish_idx).luminance(il).data(tr_idx).x_rot_rep2 = rotated_x(751 : 1250, :);
            all_fish(fish_idx).luminance(il).data(tr_idx).x_rot_rep3 = rotated_x(1251 : 1750, :);
            
            all_fish(fish_idx).luminance(il).data(tr_idx).y_rot_rep1 = rotated_y(251 : 750, :);
            all_fish(fish_idx).luminance(il).data(tr_idx).y_rot_rep2 = rotated_y(751 : 1250, :);
            all_fish(fish_idx).luminance(il).data(tr_idx).y_rot_rep3 = rotated_y(1251 : 1750, :);
        end

        disp([' -- COMPLETED IL = ', num2str(il), '---------']);
    end
    disp(['COMPLETED FISH ', fish_name, '---------'])
end

%% 3. Update and save to the original struct
save([out_path, 'data_clean_body.mat'], 'all_fish');
disp("SUCCESS: data_clean_body.mat generated with rotated values.")

% Helper: Find struct by field name
function i = queryStruct(struct, fieldName, query)
for i = 1:numel(struct)
    if isfield(struct(i), fieldName) && isequal(struct(i).(fieldName), query)
        return;
    end
end
end

% Helper: rotate all the x and y data w.r.t the origin point
function [rotated_x, rotated_y] = rotatePoints(x, y, origin_x, origin_y, theta_rad)
    % Rotate each point around the origin
    rotated_x = (x - origin_x) * cos(-theta_rad) - (y - origin_y) * sin(-theta_rad) + origin_x;
    rotated_y = (x - origin_x) * sin(-theta_rad) + (y - origin_y) * cos(-theta_rad) + origin_y;
end
