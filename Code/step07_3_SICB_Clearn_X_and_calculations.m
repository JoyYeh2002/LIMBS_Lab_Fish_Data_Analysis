
% Step 7.3 (to be merged with 7.1)
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
    
    % These are all the clean data
    for il = 1:numel(og) 
        data(il).luminance = og(il).illumination;
        data(il).lux = og(il).luxTick;
        data(il).luxMeasured = og(il).luxTickActual;
    
        % Clean trial numbers (need to make clean tags here)
        data(il).trID = og(il).xClean02Tr;
        data(il).repID = og(il).xClean02Rep;
    
        % Time-domain x
        data(il).fishX = og(il).xClean02;
        data(il).fishXMean = og(il).xClean02Mean;

        % OL freq response (complex, gain, phase)
        data(il).GM = og(il).GM02;
        data(il).gmGain = og(il).gainMean02;
        data(il).gmPhase = og(il).phaseMean02;

        % CP data (complex, gain, phase)
        data(il).CP = og(il).cpClean02;
        data(il).cpGain = og(il).cpGain02;
        data(il).cpPhase = og(il).cpPhase02;
    end

    h(i).data = data;
    
end

% Collect the trial ID and rep ID, then make clean tags



% save([out_path, 'clean_data_head_point.mat'], 'h')
% disp('SUCCESS: clean_data_head_point.mat is saved.')
