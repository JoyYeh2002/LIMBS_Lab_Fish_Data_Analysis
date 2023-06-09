% hope_population_tester.m
% Skeleton main driver code for fish tracker 3.0
% If we want to test on one fish, what should we do?
%
% Here's the workflow for 6 luminance conditions for "Hope"
% 1. Make a files struct
% 2. Open whatever files in the directory automatically, make the head
% direction tags
% 3. Then, do tracker full process on them
% 4. At the end, all the files (trials) in the folders should have their
% videos and tracked data
% 
% [TODO]
% 1. Make another script for automatically getting the head directions? Or
% spend an hour or two for visual inspection is also fine
% 2. Might need to clean up the files here, because tracker full process
% isn't really working
%
% Updated 06/09/2023

%% Format of the directory
% this_fish_dir = 'hope_low_trial03_il_1\';

data_dir = '..\data\hope_population_analysis\';
folderCount = 6;  % Total number of folders
files = struct(); % Initialize the struct

% Control Panel
save_head_direction_txt = 0;

% [Input] Record the head directions of all the trials
headDirectionTags = {};
headDirectionTags.L1 = {'R','L','R','R'}; 
headDirectionTags.L2 = {'L','L','L','R','L'}; 
headDirectionTags.L3 = {'L','L'}; 
headDirectionTags.L4 = {'R','L','L'};  
headDirectionTags.L5 = {'L','L'};  
headDirectionTags.L6 = {'L', 'L','L','L'};  

% Loop through directories
for i =  4 %3 :folderCount % This controls the luminance level
    folderName = [data_dir, 'L', num2str(i), '\'];
    subfolders = dir(folderName);
    subfolderNames = {subfolders([subfolders.isdir]).name};
    subfolderNames = subfolderNames(~ismember(subfolderNames,{'.', '..'}));
   
    files(i).levels = subfolderNames;
    files(i).headDirections = headDirectionTags.(sprintf('L%d', i));

    % This controls the trial number in this luminance level
    numFiles = numel(subfolderNames);
    for j = 2 %1 : numFiles
        % Process the full path
        subfolder = subfolderNames{j};
        thisFishDirectory = [fullfile(folderName, subfolder), '\'];
        thisHeadDirection = files(i).headDirections{j};
        fprintf('Processing: %s, trial (%d/%d) in this directory.\n', ...
            thisFishDirectory, j, numFiles);
        disp(['Head directions is: ', thisHeadDirection]);

        % Delete un-needed .csv files for pre-cleaning
        fileList = dir(fullfile(thisFishDirectory, '*.csv')); 
        for k = 1:numel(fileList)
            fileName = fileList(k).name;
            
            % Check if the file does not start with "video_"
            if ~startsWith(fileName, 'video_')
                filePath = fullfile(thisFishDirectory, fileName);
                delete(filePath);  % Delete the file
                disp(['Deleted: ' filePath]);
            end
        end

        % Save the head direction tag to a .txt file
        if save_head_direction_txt == 1
            filePath = fullfile(thisFishDirectory, 'head_direction.txt');
            fileID = fopen(filePath, 'w');
            fprintf(fileID, '%s\n', thisHeadDirection);
            fprintf(fileID, '%s\n', thisFishDirectory);
            
            % Close the file
            fclose(fileID);
            disp('SUCCESS: head_direction.txt is saved.');
        end

        % Call the full process
        tic
        if thisHeadDirection == 'L'
            disp("STARTING full process (L)")
            trackerFullProcess(thisFishDirectory, thisHeadDirection)
        else
            disp("STARTING full process (R)")
            trackerFullProcess(thisFishDirectory, thisHeadDirection)
            continue;
        end

        disp(' ');
        toc
    end
end


