
close all;


abs_path = 'C:\Users\joy20\Folder\FA_2023\LIMBS Presentations\data\fish\';
% out_path = 'C:\Users\joy20\Folder\FA_2023\LIMBS Presentations\Outputs\step10_fish_rotation\';
out_path = 'C:\Users\joy20\Folder\FA_2023\LIMBS Presentations\Outputs\';


test_subject = 'len_il_4_trial_31\';
struct_file = load([out_path, 'rotated_fish_valid.mat']); % All the raw + cleaned data labels for Bode analyis
all_fish = struct_file.all_fish;

% Locate the subject fish
f = all_fish(1).luminance(10).data(4); % This is Hope trial 30
% f = all_fish(3).luminance(4).data(2); % This is len trial 31

% Loop through all the frames in a trial
all_angles = zeros(1777, 12);

for frame_idx = 1:1777

    % 1 x 12 double
    x = f.x_rot(frame_idx, :);
    y = f.y_rot(frame_idx, :);

    x_origin = x(2);
    y_origin = y(2);

    % Calculate differences in coordinates
    dx = abs(x - x_origin);
    dy = abs(y_origin - y);

    % Calculate angles with respect to the horizontal axis
    angles_horizontal = atan2(dy, dx) * (180 / pi);
    all_angles(frame_idx, :) = abs(angles_horizontal);


end

save([out_path, 'all_angles_temp.mat'], 'all_angles');
disp("Temp angles struct saved.")
