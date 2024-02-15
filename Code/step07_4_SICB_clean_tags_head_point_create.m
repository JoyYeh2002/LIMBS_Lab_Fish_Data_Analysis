% Make the clean tags out of the "clean_data_head_point.mat"

abs_path = 'C:\Users\joy20\Folder\FA_2023\LIMBS Presentations\Data\fish_structs_2024\';

raw_data = load([abs_path, 'raw_data_head_point.mat']);
clean_data = load([abs_path, 'clean_data_head_point.mat']);

fishNames = {'Hope', 'Len', 'Doris', 'Finn', 'Ruby'}; % consistent with SICB 
numFish = 5;

% Loop through all the fish
for i = 1 % : numFish

    % Caculate all tags

    this_fish_all = raw_data.h(i).data;
    tags_all = [];
    tags_clean_head = [];

    for il = 1:numel(this_fish_all) 
        trials= cell2mat(this_fish_all(il).trID);
        reps = cell2mat(this_fish_all(il).repID);
        ils = il * ones(1, size(trials, 2));
        tags_all = [tags_all; [ils; trials; reps]'];
    end
    
    this_fish = clean_data.h(i).data;
    % These are all the clean data from head point bode
    for il = 1:numel(this_fish) 
        clean_trials = cell2mat(this_fish(il).trID);
        clean_reps = cell2mat(this_fish(il).repID);
        this_il = il * ones(1, size(clean_trials, 2));
        tags_clean_head = [tags_clean_head; [this_il; clean_trials; clean_reps]'];
    end
end


% This means il = 1, trial 3, rep 3
tags_bad_body = [1, 3, 3;
    1, 33, 3;
    1, 38, 3;
    1, 40, 2;
    1, 40, 3;
    2, 15, 3;
    2, 19, 1;
    2, 28, 3;
    3, 4, 2;
    3, 11, 2;
    3, 11, 3;
    3, 17, 1;
    3, 17, 3;
    3, 26, 3;
    3, 32, 3;
    4, 26, 1;
    4, 26, 3;
    6, 25, 1;
    6, 25, 2;
    7, 27, 3;
    8, 22, 2;
    9, 5, 3;
    10, 23, 1;
    10, 30, 2;
    10, 30, 3;
    10, 31, 1;
    10, 31, 2;];


% Clean body tags: subtract the bad body tags from everything
rows_to_keep = ~ismember(tags_all, tags_bad_body, 'rows');
tags_clean_body = tags_all(rows_to_keep, :);

% Clean head + body: both are good
intersection_rows = ismember(tags_clean_head, tags_clean_body, 'rows');
tags_clean_both = tags_clean_head(intersection_rows, :);

