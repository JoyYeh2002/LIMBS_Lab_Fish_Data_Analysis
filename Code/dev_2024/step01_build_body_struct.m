%% Step01_build_full_length_struct.m
% Updated 02.15.2024
% LIMBS Lab
% Author: Huanying (Joy) Yeh

% Experiment Name: Eigenmannia Virescens Luminance + Locomotion Comparisons
% Content: Ruby Full Body Tracking and Prelim Analysis
% - Load in the data (xls files, digging through the original DLC folders)
% - Build data structure
% - Output: out_struct_filename = [out_path, 'data_raw_body.mat'];

%% 1. Load the Excel file data
abs_path = 'C:\Users\joy20\Folder\FA_2023\LIMBS Presentations\Data\fish\';
out_path = 'C:\Users\joy20\Folder\FA_2023\LIMBS Presentations\Data\fish_structs_2024\'; % [INPUT] could modify or add more fish

if ~exist(out_path, 'dir')
    mkdir(out_path);
end

fishNames = {'Hope', 'Len', 'Doris', 'Finn', 'Ruby'}; % consistent with SICB 
numIls = [14, 9, 11, 9, 9];
numFish = 5;


% Get an empty struct
all_fish = initializeFishStruct(fishNames, numIls, numFish);


%% 1. Get luminance levels in the body struct
head_file = load([out_path, 'data_clean_head.mat']);
h = head_file.h;

for i = 1:numFish
    lux = [];
    for il = 1 : numel(h(i).data)
        lux(il) = h(i).data(il).luxMeasured;
    end

    all_fish(i).lux_values = lux;
end

x_filename = 'x_interp_data.csv';
y_filename = 'y_interp_data.csv';

%% Loop thorugh all fish and populate data
for fish_idx = 1 : numel(fishNames)
    fish_name = fishNames{fish_idx};
    disp(['Processing fish: ', fish_name, '...'])

    % Find the struct for this fish
    i = queryStruct(all_fish, 'fish_name', fish_name);
    subFolders = dir([abs_path, fish_name]);

    isLuminanceFolder = [subFolders.isdir] & ~startsWith({subFolders.name}, {'.', '..', 'plots'});
    subFolders = subFolders(isLuminanceFolder);

    % Loop through sub-folders
    for folderIdx = 1:numel(subFolders)
       
        folderName = subFolders(folderIdx).name;

        % Check if the folder name contains only numeric characters
        if ~isempty(regexp(folderName, '^\d+$', 'once'))
            % Construct the full path to the sub-folder
            subPath = dir([abs_path, fish_name, '/', folderName]);

            disp(["---> Processing luminance folder: ", folderName])
            isTrialFolder = [subPath.isdir] & startsWith({subPath.name}, 'trial');
            trialFolders = subPath(isTrialFolder);

            % Process the files within this illumination condition 
            for k = 1:numel(trialFolders)
 
                trialFolderName = trialFolders(k).name;
                this_dir = fullfile(trialFolders(k).folder, trialFolderName);

                [trial_idx, il, head_dir] = getTrialInfo(trialFolderName);

                disp(["------> Processing trial folder: ", trialFolders(k).name])
                matrix_raw_x = readCSVFile(this_dir, x_filename);
                matrix_raw_y = readCSVFile(this_dir, y_filename);

                % Populate struct with all the info
                all_fish(fish_idx).luminance(il).data = [all_fish(fish_idx).luminance(il).data, ...
                    populateData(trial_idx, head_dir, matrix_raw_x, matrix_raw_y)];
                all_fish(fish_idx).luminance(il).trial_indices = [all_fish(fish_idx).luminance(il).trial_indices, ...
                    trial_idx];
            end
        end
    end
end

%% 2. Save the struct as it. In later scripts, just load this
out_struct_filename = [out_path, 'data_raw_body.mat'];
save(out_struct_filename, 'all_fish');
disp(['SUCCESS: ', out_struct_filename, ' is saved.'])


%% -------------------------- ALL HELPER FUNCTIONS ARE HERE -------------------------------------
%% Helper: extract dir name info
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

%% Helper: Initialize empty fish struct for full-body tracking
function fishStruct = initializeFishStruct(fishNames, numIls, numFish)
% Define an empty structure with the specified fields
fishStruct = struct('fish_idx', [], 'fish_name', []);

% Loop through each fish
for fishIndex = 1:numFish
    fishStruct(fishIndex).fish_idx = fishIndex;
    fishStruct(fishIndex).fish_name = fishNames{fishIndex};

    % Define the nested fields under each "il"
    numIl = numIls(fishIndex);

    for il = 1:numIl
        fishStruct(fishIndex).luminance(il).il = il;
        fishStruct(fishIndex).luminance(il).trial_indices = [];
        fishStruct(fishIndex).luminance(il).data = [];

    end
end
end

%% Helper: populate data
function trial = populateData(trial_idx, head_dir, x, y)
trial.trial_idx = trial_idx;
trial.head_dir = head_dir;

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


%% Helper: Find struct by field name
function i = queryStruct(struct, fieldName, query)
for i = 1:numel(struct)
    if isfield(struct(i), fieldName) && isequal(struct(i).(fieldName), query)
        return;
    end
end
end


% Helper: read data csv files and return tables
function dataTable = readCSVFile(directory, data_filename)
if exist(directory, 'dir')
    % List all CSV files in the directory
    filePattern = fullfile([directory, '\', data_filename]);
    % disp(filePattern)
    csvFiles = dir(filePattern);

    if isempty(csvFiles)
        disp(filePattern)
        error('No CSV files found in the directory.');
    end

    % Select the first CSV file (you can modify this logic as needed)
    filename = csvFiles(1).name;
    fullFilePath = fullfile(directory, filename);

    % Read table (1777 x 12)
    if exist(fullFilePath, 'file')
        dataTable = readmatrix(fullFilePath);
    else
        error('Selected CSV file does not exist.');
    end
else
    error('Directory does not exist.');
end
end

