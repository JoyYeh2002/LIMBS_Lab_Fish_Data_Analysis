%% Step 00_SICB_head_point_struct_re_organize.m
% Updated 02.15.2024
% LIMBS Lab
% Author: Huanying (Joy) Yeh

% Experiment Name: Eigenmannia Virescens Luminance + Locomotion Comparisons
% Content: Following up on fish head point analysis (td, freq-domain
% responses, selecting clean trials with GUI, bode plots, etc)
% 
% For paper publication, now we re-organize the MATLAB structs to the
% following:
% 1. raw_data_head_point.mat (with all the trials and their tags, basic data
% structure
% 2. clean_data_head_point.mat (all the clean fields selected with GUI.
% All following analyses appear after this. Also save the clean tags in array form, standardize it)

%% 1. Loading the old data
close all;
abs_path = 'C:\Users\joy20\Folder\FA_2023\LIMBS Presentations\data\';
out_path = 'C:\Users\joy20\Folder\FA_2023\LIMBS Presentations\Data\fish_structs_2024\';

if ~exist(out_path, 'dir')
    mkdir(out_path);
end

load([abs_path, 'ORIGINAL_HEAD_POINT_DATA.mat']); % All the raw + cleaned data, stored in "all_fish"
all_fish = m.group;
%% 2. Create "raw_data_head_point.mat": (Trial IDs, x-data, shuttle)
h = struct();
fishNames = {'Hope', 'Len', 'Doris', 'Finn', 'Ruby'}; % consistent with SICB 
numFish = 5;

% Loop through all the fish
for i = 1 : numFish
 
    % first level: fish name and associated data
    h(i).name = fishNames{i};
    
    % temp: clean up fields in here. 
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

%% 3. Create "clean_data_head_point.mat": (Trial IDs, x-data, shuttle, bode gain and phase, CP info)
h = struct();

% 1st level
for i = 1 : numFish

    h(i).name = fishNames{i};
    
    % 2nd level
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

save([out_path, 'clean_data_head_point.mat'], 'h')
disp('SUCCESS: clean_data_head_point.mat is saved.')

