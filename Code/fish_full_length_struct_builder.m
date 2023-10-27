%% ruby_full_body_analysis_pilot_driver.m
% Updated 10.06.2023
% LIMBS Lab
% Author: Huanying (Joy) Yeh

% Experiment Name: Eigenmannia Virescens Luminance + Locomotion Comparisons
% Content: Ruby Full Body Tracking and Prelim Analysis
% - Load in the data
% - Build data structure
% - FFT, position distributions, velocity, and curvature plots

%% 0. Define metadata for this experiment, then create empty fish struct
fishNames = {'Hope', 'Ruby', 'Len', 'Finn', 'Doris'};
numIls = [14, 9, 9, 9, 11];
numFish = 5;  
all_fish_data = initializeFishStruct(fishNames, numIls, numFish);

%% 1. For Ruby Pilot: load Excel .csv data from local (4 pilot trials data)
abs_path = 'C:\Users\joy20\Folder\FA_2023\LIMBS Presentations\Data\';
fish_name = 'Ruby';
data_dir_name = 'ruby_pilot_data_full_body\'; % [INPUT] This could be changed
out_dir_name = 'outputs\data_structures\'; % [INPUT] could modify or add more fish

x_filename = 'x_interp_data.csv';
y_filename = 'y_interp_data.csv';

% [TODO] will be automatically looped
directories = {'trial10_il_9_1\', ...
    'trial26_il_3_-1\', ...
    'trial32_il_6_1\', ...
    'trial23_il_1_-1\', ...
    'trial40_il_1_-1\'};

%% 2. Preprocessing: populate struct, segment 3 reps

% Find the struct for this fish (Ruby)
i = queryStruct(all_fish_data, 'fish_name', fish_name); 

% Work on all directories
for file_idx = 1:numel(directories)
    this_dir = directories{file_idx};
    [trial_idx, il, head_dir] = getTrialInfo(this_dir);

    % Read the x and y data into 1777x12 matrices
    this_dir = [abs_path, data_dir_name, this_dir]; 
    matrix_raw_x = readCSVFile(this_dir, x_filename);
    matrix_raw_y = readCSVFile(this_dir, y_filename);

    % Populate struct with all the info
    all_fish_data(i).luminance(il).data = [all_fish_data(i).luminance(il).data, ...
        populateData(trial_idx, head_dir, matrix_raw_x, matrix_raw_y)];
    all_fish_data(i).luminance(il).trial_indices = [all_fish_data(i).luminance(il).trial_indices, ...
        trial_idx];
end

%% 3. Save the struct as it. In later scripts, just load this
out_struct_filename = [abs_path, data_dir_name, out_dir_name, 'all_fish_body_struct.mat'];
save(out_struct_filename, 'all_fish_data');
disp(['SUCCESS: ', out_struct_filename, ' is saved.'])


%% -----------------------------------------------------------------------------------------------
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
    % Check if the directory exists
    if exist(directory, 'dir')
        % List all CSV files in the directory
        filePattern = fullfile([directory, data_filename]);
        csvFiles = dir(filePattern);
        
        if isempty(csvFiles)
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

