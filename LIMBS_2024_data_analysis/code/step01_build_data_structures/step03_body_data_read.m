%% Step03_body_data_read.m
% Updated 03.23.2024
% LIMBS Lab
% Author: Huanying (Joy) Yeh

% Experiment Name: Eigenmannia Virescens Luminance + Locomotion Comparisons
% Content: Full Body Tracking with DLC: parsing results
% - Load in the data xls files from DLC folders
% - Build data structure for all fish
% - Outputs a struct: 'data_structures/data_raw_body.mat'

%% 1. Specify folder paths
parent_dir = fullfile(pwd, '..', '..');
abs_path = fullfile(parent_dir, 'data\body_bending\');
out_path = fullfile(parent_dir, 'data_structures\');

if ~exist(out_path, 'dir')
    mkdir(out_path);
end

%% 2. Initial setup
fishNames = {'Hope', 'Len', 'Doris', 'Finn', 'Ruby'}; % consistent with SICB
numIls = [14, 9, 11, 9, 9];
numFish = 5;
all_fish = initializeFishStruct(fishNames, numIls, numFish);
h = load(fullfile(out_path, 'data_clean_head.mat'), 'h').h;

%% 3. Populate illuminance info
for i = 1:numFish
    lux = [];
    for il = 1 : numel(h(i).data)
        lux(il) = h(i).data(il).luxMeasured;
    end
    all_fish(i).lux_values = lux;
end

%% 4. Loop thorugh all fish and populate data
x_filename = 'x_interp_data.csv';
y_filename = 'y_interp_data.csv';
head_DLC_filename = 'trial*.csv';

for fish_idx = 1 : numel(fishNames)
    fish_name = fishNames{fish_idx};
   
    % Find the struct for this fish
    i = queryStruct(all_fish, 'fish_name', fish_name);
    sub_folders = dir([abs_path, fish_name]);

    is_illuminance_folder = [sub_folders.isdir] & ~startsWith({sub_folders.name}, {'.', '..', 'plots'});
    sub_folders = sub_folders(is_illuminance_folder);

    % Loop through sub-folders
    for folder_idx = 1:numel(sub_folders)
        folder_name = sub_folders(folder_idx).name;

        % Check if the folder name contains only numeric characters
        if ~isempty(regexp(folder_name, '^\d+$', 'once'))
            % Construct the full path to the sub-folder
            sub_path = dir([abs_path, fish_name, '/', folder_name]);

            % disp(['Processing luminance folder: ', num2str(folder_name)])

            is_trial_folder = [sub_path.isdir] & startsWith({sub_path.name}, 'trial');
            trial_folders = sub_path(is_trial_folder);

            % Process the files within this illumination condition
            for k = 1:numel(trial_folders)

                trial_folder_name = trial_folders(k).name;
                this_dir = fullfile(trial_folders(k).folder, trial_folder_name);

                [trial_idx, il, head_dir] = getTrialInfo(trial_folder_name);
                
                % Read 12 points along the body
                matrix_raw_x = readCSVFile(this_dir, x_filename);
                matrix_raw_y = readCSVFile(this_dir, y_filename);
                
                % Read the head point tracked data (for data clean-up)
                matrix_origin = readCSVFile(this_dir, head_DLC_filename);
                matrix_origin_x = matrix_origin(:, 2);
                matrix_origin_y = matrix_origin(:, 3);

                % Rotate data by 180 degrees depending on head direction
                if head_dir == 1
                    matrix_origin_x = 640 - matrix_origin_x;
                    matrix_origin_y = 190 - matrix_origin_y;
                end

                % Populate struct with all the info
                all_fish(fish_idx).luminance(il).data = [all_fish(fish_idx).luminance(il).data, ...
                    populateData(trial_idx, head_dir, matrix_origin_x, matrix_origin_y, matrix_raw_x, matrix_raw_y)];
                all_fish(fish_idx).luminance(il).trial_indices = [all_fish(fish_idx).luminance(il).trial_indices, ...
                    trial_idx];
            end
        end
        disp([' -- COMPLETED IL = ', num2str(il), ' --------']);
    end
    disp(['Completed fish: ', fish_name, ' ----------'])
end

%% 5. Save the struct as it. In later scripts, just load this
out_struct_filename = [out_path, 'data_raw_body.mat'];
save(out_struct_filename, 'all_fish');
disp('SUCCESS: /data_structures/data_raw_body.mat is saved.')


%% -------------------------- HELPER FUNCTIONS START HERE ---------------------------------
%% Helper: Initialize empty fish struct for full-body tracking
function fish_struct = initializeFishStruct(fishNames, numIls, numFish)
fish_struct = struct('fish_idx', [], 'fish_name', []);
for fish_idx = 1:numFish
    fish_struct(fish_idx).fish_idx = fish_idx;
    fish_struct(fish_idx).fish_name = fishNames{fish_idx};

    numIl = numIls(fish_idx);
    for il = 1:numIl
        fish_struct(fish_idx).luminance(il).il = il;
        fish_struct(fish_idx).luminance(il).trial_indices = [];
        fish_struct(fish_idx).luminance(il).data = [];
    end
end
end

%% Helper: Find struct by field name
function i = queryStruct(struct, fieldName, query)
for i = 1:numel(struct)
    if isfield(struct(i), fieldName) && isequal(struct(i).(fieldName), query)
        return;
    end
end
end

%% Helper: extract trial number, illuminance, and head direction from folder name
function [trial_num, il, head_dir] = getTrialInfo(input_str)
% regex
pattern = 'trial(\d{2})_il_(\d{1,2})_([-1]?[1])';
tokens = regexp(input_str, pattern, 'tokens');

% Check if tokens are found
if ~isempty(tokens)
    trial_num = str2double(tokens{1}{1});
    il = str2double(tokens{1}{2});
    head_dir = str2double(tokens{1}{3});
else
    error('Pattern not found in the input string.');
end
end

%% Helper: read data csv files and return tables
function data_table = readCSVFile(directory, data_filename)
if exist(directory, 'dir')

    % List all CSV files in the directory (x.csv or y.csv)
    file_pattern = fullfile([directory, '\', data_filename]);
    csv_files = dir(file_pattern);
    if isempty(csv_files)
        disp(file_pattern)
        error('No CSV files found in the directory.');
    end

    % Read table (1777 x 12)
    filename = csv_files(1).name;
    full_file_path = fullfile(directory, filename);
    if exist(full_file_path, 'file')
        data_table = readmatrix(full_file_path);
    else
        error('Selected CSV file does not exist.');
    end
else
    error('Directory does not exist.');
end
end

%% Helper: populate data
function trial = populateData(trial_idx, head_dir, origin_x, origin_y, x, y)
trial.trial_idx = trial_idx;
trial.head_dir = head_dir;

trial.x_origin = origin_x; % 1777 x 12
% trial.y_origin = origin_y;

% trial.x_origin1 = origin_x(251 : 750, :);
% trial.x_origin2 = origin_x(751 : 1250, :);
% trial.x_origin3 = origin_x(1251 : 1750, :);

trial.x_data_raw = x; % 1777 x 12
trial.y_data_raw = y;

% Segments into 3 reps, then save to struct
trial.x_rep1 = x(251 : 750, :);
trial.x_rep2 = x(751 : 1250, :);
trial.x_rep3 = x(1251 : 1750, :);

trial.y_rep1 = y(251 : 750, :);
trial.y_rep2 = y(751 : 1250, :);
trial.y_rep3 = y(1251 : 1750, :);
end




