%% Step06_populate_all_validity.m
% Updated 02.15.2024
% LIMBS Lab
% Author: Huanying (Joy) Yeh

% Experiment Name: Eigenmannia Virescens Luminance + Locomotion Comparisons
%
% Content:
% - Now, we include bad tags from the "clean_data_head_point.mat" from
% step05
% - There will be three sets of validity tags: valid_body,
% valid_head, valid_both
% Next step: clean tags for both head and body will be populated.

%% 1. Load the full body + rotated struct
abs_path = 'C:\Users\joy20\Folder\FA_2023\LIMBS Presentations\data\fish_structs_2024\';
load([abs_path, 'raw_data_full_body.mat']);
load([abs_path, 'trial_id.mat']);

fishNames = {'Hope', 'Len', 'Doris', 'Finn', 'Ruby'}; % consistent with SICB

%% 4. Populate validity tags
for i = 1 : numel(fishNames)
    fish_name = fishNames{i}; % Hope
    fish_idx = queryStruct(all_fish, 'fish_name', fish_name);
    fish = all_fish(fish_idx);

    % Assign all zeros by defualt
    for il = 1: numel(fish.luminance) % Through all il levels

        % fields_to_remove = {'validity_head', 'validity_body', 'validity_both'};  % List of fields to remove
        % for f = 1:numel(fields_to_remove)
        %     all_fish(fish_idx).luminance(il).data = rmfield(all_fish(fish_idx).luminance(il).data, fields_to_remove{f});
        % end

        for idx = 1 : numel(fish.luminance(il).data) % through all data
            all_fish(fish_idx).luminance(il).data(idx).valid_head = [0, 0, 0];
            all_fish(fish_idx).luminance(il).data(idx).valid_body = [0, 0, 0];
            all_fish(fish_idx).luminance(il).data(idx).valid_both = [0, 0, 0];
        end
    end

    % Get the clean tags
    tags_head = ID(i).tags_clean_head;

    for row = 1 : size(tags_head, 1)
        good_il = tags_head(row, 1);
        good_tr = tags_head(row, 2);
        good_rep = tags_head(row, 3);

        % Get the dataset in the target luminance
        target_il = fish.luminance(good_il);
        dataset = target_il.data;

        target_idx = find(target_il.trial_indices == good_tr);
        if ~isempty(target_idx)
            % Make valid tag turn into 1
            all_fish(fish_idx).luminance(good_il).data(target_idx).valid_head(good_rep) = 1;
        end
    end

    tags_body = ID(i).tags_clean_body;

    for row = 1 : size(tags_body, 1)
        good_il = tags_body(row, 1);
        good_tr = tags_body(row, 2);
        good_rep = tags_body(row, 3);

        % Get the dataset in the target luminance
        target_il = fish.luminance(good_il);
        dataset = target_il.data;

        target_idx = find(target_il.trial_indices == good_tr);
        if ~isempty(target_idx)
            % Make valid tag turn into 1
            all_fish(fish_idx).luminance(good_il).data(target_idx).valid_body(good_rep) = 1;
        end
    end

    tags_both = ID(i).tags_clean_both;

    for row = 1 : size(tags_both, 1)
        good_il = tags_both(row, 1);
        good_tr = tags_both(row, 2);
        good_rep = tags_both(row, 3);

        % Get the dataset in the target luminance
        target_il = fish.luminance(good_il);
        dataset = target_il.data;

        target_idx = find(target_il.trial_indices == good_tr);
        if ~isempty(target_idx)
            % Make valid tag turn into 1
            all_fish(fish_idx).luminance(good_il).data(target_idx).valid_both(good_rep) = 1;
        end
    end

    disp(['fish ', num2str(i), ' body validity tags are updated.'])
end

save([abs_path, 'raw_data_full_body.mat'], 'all_fish');
disp("SUCCESS: all 3 validity tags are saved in 'raw_data_full_body.mat'.")

%% Helper: Find struct by field name
function i = queryStruct(struct, fieldName, query)
for i = 1:numel(struct)
    if isfield(struct(i), fieldName) && isequal(struct(i).(fieldName), query)
        return;
    end
end
end

