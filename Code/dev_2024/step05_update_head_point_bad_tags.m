%% Step05_update_head_point_bad_tags
% Updated 02.15.2024
% LIMBS Lab
% Author: Huanying (Joy) Yeh

% Experiment Name: Eigenmannia Virescens Luminance + Locomotion Comparisons
%
% Content:
% - Load both the "body" and "head" structs and find the clean trial tags
% - We update the bad_tags.mat and save three sets of validity tags: valid_body,
% valid_head, valid_both
% Next step: populate tags in step06


% Make the clean tags out of the "clean_data_head_point.mat"
abs_path = 'C:\Users\joy20\Folder\FA_2023\LIMBS Presentations\Data\fish_structs_2024\';

raw_data = load([abs_path, 'raw_data_head_point.mat']);
clean_data = load([abs_path, 'clean_data_head_point.mat']);
raw_body = load([abs_path, 'raw_data_full_body.mat']);

file = load([abs_path, 'body_bad_tags.mat']);
body_bad_tags = file.body_bad_tags;

fishNames = {'Hope', 'Len', 'Doris', 'Finn', 'Ruby'}; % consistent with SICB
numFish = 5;
ID = struct();

% Loop through all the fish
for i = 1 : numFish
    ID(i).name = fishNames{i};

    % Go into the head point struct to find all clean tags
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

    % Get the "il, trID, repID" array elements
    for il = 1:numel(this_fish)
        clean_trials = cell2mat(this_fish(il).trID);
        clean_reps = cell2mat(this_fish(il).repID);
        this_il = il * ones(1, size(clean_trials, 2));
        tags_clean_head = [tags_clean_head; [this_il; clean_trials; clean_reps]'];
    end

    % Clean body tags: subtract the bad body tags from everything
    rows_to_keep = ~ismember(tags_all, body_bad_tags(i).tags, 'rows');
    tags_clean_body = tags_all(rows_to_keep, :);

    % Clean head + body: both are good
    intersection_rows = ismember(tags_clean_head, tags_clean_body, 'rows');
    tags_clean_both = tags_clean_head(intersection_rows, :);

    % Assign back into structs
    ID(i).tags_all = tags_all;
    ID(i).tags_clean_head = tags_clean_head;
    ID(i).tags_clean_body = tags_clean_body;
    ID(i).tags_clean_both = tags_clean_both;

end

save([abs_path, 'trial_id.mat'], 'ID');
disp("SUCCESS: trial_id.mat is saved.")

