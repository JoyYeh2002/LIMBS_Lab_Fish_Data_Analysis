%% Step01: Refuge-Frame_TD_X-Positions
% Updated 02.16.2024
% LIMBS Lab
% Author: Huanying (Joy) Yeh

% Experiment Name: Eigenmannia Virescens Luminance + Locomotion Comparisons
%
% Content:
% - time-domain variances for x
% - log illuminance scale vs. x-position variances
% - 

%% 1. Load the data
abs_path = 'C:\Users\joy20\Folder\FA_2023\LIMBS Presentations\data\fish_structs_2024\';
head_file = load([abs_path, 'clean_data_head_point.mat']);
all_fish = head_file.h;

fishNames = {'Hope', 'Len', 'Doris', 'Finn', 'Ruby'}; % consistent with SICB
numFish = 5;
num_body_pts = 1;


%% 2. Calculate x variances and save to struct
res = struct();

for i = 1 : numFish
    res(i).name = fishNames{i};

   
    num_il_levels = numel(all_fish(i).data);

    this_fish_varX = cell(num_il_levels, 1);
    this_fish_varX_avg = zeros(num_il_levels, 1);

    for il = 1 : num_il_levels

        % make a container for this il level
        num_trials = numel(all_fish(i).data(il).fishX);

        this_il_varX = zeros(num_trials, num_body_pts);
        x_mean = cell2mat(all_fish(i).data(il).fishXMean);
        
        for trial_idx = 1 : num_trials
            x_data = cell2mat(all_fish(i).data(il).fishX(trial_idx)); % 500 x 1
  
            %% 3. Populate the struct [TODO] Add var y in the future      
            res(i).luminance(il).trID = all_fish(i).data(il).trID;
            res(i).luminance(il).repID = all_fish(i).data(il).repID;
            this_il_varX(trial_idx, :) = var((x_data - x_mean),'omitnan');   
        end

        % Populate at high level 
        this_fish_varX{il} = this_il_varX;
        res(i).lux(il) = all_fish(i).data(il).luxMeasured;

        res(i).luminance(il).varX = this_il_varX;
        this_fish_varX_avg(il, :) = nanmean(this_il_varX, 1);
    end
    res(i).varX_mean = this_fish_varX_avg;
end

outfile_name = 'res_head_variances.mat';
save([abs_path, outfile_name], 'res');
disp(['SUCCESS: ', outfile_name, ' saved.'])
