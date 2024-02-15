
% Step 06 playground (or step 07)
% tries to clean up and re-save the head point stuff from SICB 2023
% Don't try to do too much!!
% 
% Split into multiple structs
% 1. head_point_raw_data.mat (with all the trials and their tags, basic data
% structure
%
% 2. head_point_cleaned_data.mat (all the clean fields selected with GUI.
% All following analyses appear after this. Also save the clean tags in array form, standardize it)
% 
% 3. full_length_raw_data.mat (with all the body data (pinned), as well as
% displacement from head point due to pinning -> the head point at every
% frame will need this!)
% 
% Rules:
% Don't make too many fields and labels, keep the file sizes small
% Format the clean tags so that they are interchangeable

close all;
abs_path = 'C:\Users\joy20\Folder\FA_2023\LIMBS Presentations\data\';
out_path = 'C:\Users\joy20\Folder\FA_2023\LIMBS Presentations\Data\fish_structs_2024\';

if ~exist(out_path, 'dir')
    mkdir(out_path);
end

mHead = load([abs_path, 'ORIGINAL_HEAD_POINT_DATA.mat']); % All the raw + cleaned data labels for Bode analyis

% "h" struct will be in "head_point_raw_data.mat"
h = struct();
fishNames = {'Hope', 'Len', 'Doris', 'Finn', 'Ruby'}; % consistent with SICB 
numFish = 5;

% Loop through all the fish
for i = 1 : numFish
 
    % first level: fish name and associated data
    h(i).name = fishNames{i};
    
    % temp: clean up fields in here. 
    % version
    data = struct();
    og = all_fish(i).fishData;
    
    % Re-name fields and assign original data
    for il = 1:numel(og) 
        data(il).luminance = og(il).illumination;
        data(il).lux = og(il).luxTick;
        data(il).luxMeasured = og(il).luxTickActual;
    
        data(il).trID = og(il).testID;
        data(il).repID = og(il).repID;
    
        data(il).shuttleX = og(il).shuttleX;
        data(il).fishX = og(il).fishX;
    end

    h(i).data = data;
    
end

save([out_path, 'raw_data_head_point.mat'], 'h')
disp('SUCCESS: raw_data_head_point.mat is saved.')

