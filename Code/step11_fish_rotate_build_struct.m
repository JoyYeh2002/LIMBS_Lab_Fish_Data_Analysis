% step 11: Add to data structure with the "rotated" portion
% Develop a module for correcting the fish body axis
% - Use the first 2 or three points to grab an axis
% - Find the angle w.r.t. horizontal
% - Rotate all the points wrt. the pin point as well as the image (for
% testing)

% All the experiment outputs are in
% C:\Users\joy20\Folder\FA_2023\LIMBS Presentations\Outputs\step10_fish_rotation\

% Spring 2024 semester
% updated 01/26/2024

close all;
abs_path = 'C:\Users\joy20\Folder\FA_2023\LIMBS Presentations\data\';
out_path = 'C:\Users\joy20\Folder\FA_2023\LIMBS Presentations\Outputs\step10_fish_rotation\';

mBody = load([abs_path, 'all_fish_full_length_data.mat']); % All the raw + cleaned data labels for Bode analyis

% Locate the subject fish
fish_idx = 3;
il = 4;
tr_idx = 2;

fishNames = {'Len', 'Hope', 'Ruby', 'Finn', 'Doris'};
for k = 1:numel(fishNames)
    fish_name = fishNames{k};
    fish_idx = queryStruct(all_fish_data, 'fish_name', fish_name);

    for il = 1 : numel(mBody.all_fish_data(fish_idx).luminance)
        for tr_idx = 1 : numel(mBody.all_fish_data(fish_idx).luminance(il).data)
            f = mBody.all_fish_data(fish_idx).luminance(il).data(tr_idx); % This is trial 31
            
            % Loop through all the frames in a trial
            rotated_x = zeros(1777, 12);
            rotated_y = zeros(1777, 12);
            
            for frame_idx = 1:1777
                % Get the 12 points throughout the image
                x = f.x_data_raw(frame_idx, :);
                y = f.y_data_raw(frame_idx, :);
            
                % Linear fit with the first 3 points
                coefficients = polyfit(x(1:3), y(1:3), 1);
                theta = atan(coefficients(1));
                [rotated_x(frame_idx, :), rotated_y(frame_idx, :)] = rotatePoints(x, y, x(2), y(2), theta);
                
            end
            
            % Put back into the struct
            mBody.all_fish_data(fish_idx).luminance(il).data(tr_idx).x_rot = rotated_x;
            mBody.all_fish_data(fish_idx).luminance(il).data(tr_idx).y_rot = rotated_y;
            
            % Segments into 3 reps, then save to struct
            mBody.all_fish_data(fish_idx).luminance(il).data(tr_idx).x_rot_rep1 = rotated_x(251 : 750, :);
            mBody.all_fish_data(fish_idx).luminance(il).data(tr_idx).x_rot_rep2 = rotated_x(751 : 1250, :);
            mBody.all_fish_data(fish_idx).luminance(il).data(tr_idx).x_rot_rep3 = rotated_x(1251 : 1750, :);
            
            mBody.all_fish_data(fish_idx).luminance(il).data(tr_idx).y_rot_rep1 = rotated_y(251 : 750, :);
            mBody.all_fish_data(fish_idx).luminance(il).data(tr_idx).y_rot_rep2 = rotated_y(751 : 1250, :);
            mBody.all_fish_data(fish_idx).luminance(il).data(tr_idx).y_rot_rep3 = rotated_y(1251 : 1750, :);

            disp([' ----- Trial = ', num2str(tr_idx), '-----\n']);
        end

        disp([' ----- COMPLETED IL = ', num2str(il), '-----\n']);
    end
    disp(['COMPLETED FISH ', fish_name, '---------'])
end
% This is temp
save([out_path, 'rotated_fish.mat'], 'mBody');

%% Helper: Find struct by field name
function i = queryStruct(struct, fieldName, query)
for i = 1:numel(struct)
    if isfield(struct(i), fieldName) && isequal(struct(i).(fieldName), query)
        return;
    end
end
end

% HELPERS are here
function [rotated_x, rotated_y] = rotatePoints(x, y, origin_x, origin_y, theta_rad)
    % Rotate each point around the origin
    rotated_x = (x - origin_x) * cos(-theta_rad) - (y - origin_y) * sin(-theta_rad) + origin_x;
    rotated_y = (x - origin_x) * sin(-theta_rad) + (y - origin_y) * cos(-theta_rad) + origin_y;
end
