close all;

abs_path = 'C:\Users\joy20\Folder\FA_2023\LIMBS Presentations\Data\fish_structs_2024\';



load([abs_path, 'raw_data_head_point.mat']); % All the raw + cleaned data, stored in "all_fish"
head_raw = h;

load([abs_path, 'clean_data_head_point_with_freq.mat']);
head_new = h;


%% 2. Create "raw_data_head_point.mat": (Trial IDs, x-data, shuttle)

fishNames = {'Hope', 'Len', 'Doris', 'Finn', 'Ruby'}; % consistent with SICB 
numFish = 5;
