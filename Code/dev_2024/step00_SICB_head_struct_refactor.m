%% Step 00_SICB_head_point_struct_re_organize.m
% Updated 02.15.2024
% LIMBS Lab
% Author: Huanying (Joy) Yeh

% Experiment Name: Eigenmannia Virescens Luminance + Locomotion Comparisons
% Content: Following up on fish head point analysis (td, freq-domain
% responses, selecting clean trials with GUI, bode plots, etc)
% 
% Outputs:
% 1. data_raw_head.mat: with all trials in  basic data structure
% 2. data_clean_head.mat: all the clean fields selected with GUI

%% CAUTION: Absolute path breaks very easily. Re-populate these structs in the future with proper code

%% 1. Loading the old data
close all;
abs_path = 'C:\Users\joy20\Folder\FA_2023\LIMBS Presentations\data\';
out_path = 'C:\Users\joy20\Folder\FA_2023\LIMBS Presentations\Data\fish_structs_2024\';

if ~exist(out_path, 'dir')
    mkdir(out_path);
end

%% 1.2 Recover the y values (og and clean are from two different structs - fix later)
y_struct_path_og = 'C:\Users\joy20\Folder\FA_2023\LIMBS Presentations\SICB_2023\Code\data\legacy_fish_structs\';
oldFishStructNames = {'HopeBigStruct.mat', 'lenBigStruct.mat', ...
    'dorisBigStruct.mat', 'finnBigStruct.mat', 'rubyBigStruct.mat'};

y_struct_path_clean = 'C:\Users\joy20\Folder\FA_2023\LIMBS Presentations\Data\';
all_fish_y_clean = load([y_struct_path_clean, 'bigStructYRecovered.mat']);
all_fish_y_clean = all_fish_y_clean.group;


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

    y_struct_og = load([y_struct_path_og, oldFishStructNames{i}]);
    y_struct_og = y_struct_og.fish;

    % Re-name fields and assign original data
    for il = 1:numel(og) 
        data(il).luminance = og(il).illumination;
        data(il).lux = og(il).luxTick;
        data(il).luxMeasured = og(il).luxTickActual;
    
        data(il).trID = og(il).testID;
        data(il).repID = og(il).repID;
    
        data(il).shuttleX = og(il).shuttleX;
        data(il).fishX = og(il).fishX;

        % Recover y values
        data(il).fishY = y_struct_og(il).fishY;

    end

    h(i).data = data;
    
end

save([out_path, 'data_raw_head.mat'], 'h')
disp('SUCCESS: data_raw_head.mat is saved.')

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

        % [NEW] Time-domain y
        data(il).fishY = all_fish_y_clean(i).fishData(il).fishY;
        data(il).fishYMean = all_fish_y_clean(i).fishData(il).fishYMean;
        
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

save([out_path, 'data_clean_head.mat'], 'h')
disp('SUCCESS: data_clean_head.mat is saved.')




