
% To be merged with step07_SICB_Struct_Cleaning.m
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

% mBody = load([abs_path, 'ORIGINAL_FULL_LENGTH_DATA.mat']); % All the raw + cleaned data labels for Bode analyis
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

% 
% for il = 1 : size(h{i}, 2)
%     h(il).luxTick = h{i}(il).luxTick;
%     h(il).luxTickActual = h{i}(il).luxTickActual;
%     h(il).testID_all = h{i}(il).testID;
%     h(il).repID_all = h{i}(il).repID;
% 
%     % Get the trial numbers grouping by il
%     % h(il).expIdx_all = unique(cell2mat(h(il).testID_all));
%     h(il).expIdx_all = hb(il).trial_indices;
% 
%     h(il).shuttleX_all = h{i}(il).shuttleX;
%     % Get the raw x-data of the head (head doesn't have y?)
%     h(il).headX_all = h{i}(il).fishX;
%     % [TODO: STILL MISSING Y VALUES. ADD THEM HERE]
% 
%     body = hb(il).data;
%     h(il).bodyX_all = {};
% 
%     for tr_idx = 1 : size(body, 2)
%         h(il).bodyX_all = [h(il).bodyX_all, body(tr_idx).x_rep1, body(tr_idx).x_rep2, body(tr_idx).x_rep3];
%     end
% 
% 
%     % Time domain tags and clean head data
%     h(il).xTr = h{i}(il).xClean02Tr;
%     h(il).xRep = h{i}(il).xClean02Rep;
% 
%     h(il).x = h{i}(il).xClean02;
%     h(il).xMean = h{i}(il).xClean02Mean;
% 
%     % [TODO] Populate head y and head y mean (clean)
% 
%     % CP fields renamed
%     h(il).cp = h{i}(il).cpClean02;
%     h(il).cpGain = h{i}(il).cpGain02;
%     h(il).cpPhase = h{i}(il).cpPhase02;
% 
%     % GM fields renamed
%     h(il).gm = h{i}(il).GM02;
%     h(il).gmGain= h{i}(il).gainMean02;
%     h(il).gmPhase = h{i}(il).phaseMean02;
% 
% end
% 


