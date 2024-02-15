% Step 13.2: Include clean tags from head data.
% Load in the "clean tags" struct
% Slight modifications from step 13.
% Now we're using good trials

% Fish
close all;
abs_path = 'C:\Users\joy20\Folder\FA_2023\LIMBS Presentations\data\fish\';
out_dir_figures = 'C:\Users\joy20\Folder\FA_2023\LIMBS Presentations\Outputs\';
out_path = 'C:\Users\joy20\Folder\FA_2023\LIMBS Presentations\Outputs\';

struct_file = load([abs_path, 'rotated_fish.mat']); % All the raw + cleaned data labels for Bode analyis
all_fish = struct_file.mBody.all_fish_data;

fish_names = {'Hope', 'Ruby','Len', 'Finn', 'Doris'};

body_bad_tags = struct();

% This means il = 1, trial 3, rep 3
bad_trials_Hope = [1, 3, 3;
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

% Assign struct ---------------------------------
body_bad_tags(1).name = 'Hope';
body_bad_tags(1).tags = bad_trials_Hope;
all_fish(1).bad_trials = bad_trials_Hope;


% This means il = 1, trial 3, rep 3
bad_trials_Ruby = [1, 23, 2;
    1, 33, 2;
    1, 40, 3;
    2, 28, 1;
    2, 28, 3;
    4, 12, 2;
    4, 12, 3;
    4, 31, 3;
    6, 43, 2;
    9, 7, 1;];

% Assign struct
body_bad_tags(2).name = 'Ruby';
body_bad_tags(2).tags = bad_trials_Ruby;
all_fish(2).bad_trials = bad_trials_Ruby;

% This means il = 1, trial 3, rep 3
bad_trials_Len = [3, 26, 2;
    3, 26, 3;
    3, 35, 3;
    4, 12, 1;
    4, 12, 2;
    6, 22, 1;
    6, 22, 2;
    8, 19, 3;];

% Assign struct ------------------------------
body_bad_tags(3).name = 'Len';
body_bad_tags(3).tags = bad_trials_Len;
all_fish(3).bad_trials = bad_trials_Len;

% This means il = 1, trial 3, rep 3
bad_trials_Finn = [1, 23, 1;
    1, 23, 2;
    1, 23, 3;
    1, 33, 1;
    1, 33, 2;
    1, 33, 3;
    2, 9, 3;
    2, 27, 2;
    2, 28, 1;
    2, 28, 3;
    2, 36, 3;
    2, 47, 2;
    3, 21, 3;
    3, 35, 2;
    3, 39, 2;
    3, 39, 3;
    4, 31, 1;
    5, 4, 3;
    5, 17, 3;
    6, 43, 1;
    6, 43, 2;
    6, 43, 3;];

% Assign struct ------------------------------
body_bad_tags(4).name = 'Finn';
body_bad_tags(4).tags = bad_trials_Finn;
all_fish(4).bad_trials = bad_trials_Finn;


% This means il = 1, trial 3, rep 3
bad_trials_Doris = [
    1, 6, 3;
    1, 17, 2;
    1, 31, 2;
    1, 25, 2;
    2, 14, 3;
    2, 51, 2;
    2, 51, 3;
    3, 43, 1;
    3, 43, 3;
    4, 9, 2;
    6, 7, 3;
    7, 28, 2;
    7, 28, 3;
    8, 30, 3;
    9, 20, 2;];

% Assign struct ------------------------------
body_bad_tags(5).name = 'Doris';
body_bad_tags(5).tags = bad_trials_Doris;
all_fish(5).bad_trials = bad_trials_Doris;

save([out_path, 'body_bad_tags.mat'], 'body_bad_tags');

for k = 1 : numel(fish_names)
    fish_name = fish_names{k}; % Hope
    fish_idx = queryStruct(all_fish, 'fish_name', fish_name);
    fish = all_fish(fish_idx);
    bad_trials = fish.bad_trials; % need to loop through these

    % Assign all ones by defualt
    for il = 1: numel(fish.luminance) % Through all il levels
        for idx = 1 : numel(fish.luminance(il).data) % Through all data
            all_fish(fish_idx).luminance(il).data(idx).validity = [1, 1, 1]; 
        end
    end

    % Loop through each 3-tuple in the list
    for row = 1 : size(bad_trials, 1)
        bad_il = bad_trials(row, 1);
        bad_tr = bad_trials(row, 2);
        bad_rep = bad_trials(row, 3);

        % Get the dataset in the target luminance
        target_il = fish.luminance(bad_il);
        dataset = target_il.data;
        
        target_idx = find(target_il.trial_indices == bad_tr);
        if ~isempty(target_idx)
            % dataset(target_idx).validity(bad_rep) = 0;
            all_fish(fish_idx).luminance(bad_il).data(target_idx).validity(bad_rep) = 0;
        end
    end
    disp(['fish ', num2str(k), '  is saved.'])
end

% This is temp
save([out_path, 'rotated_fish_valid.mat'], 'all_fish');
disp("Validity tag for all fish saved.")

%% Helper: Find struct by field name
function i = queryStruct(struct, fieldName, query)
for i = 1:numel(struct)
    if isfield(struct(i), fieldName) && isequal(struct(i).(fieldName), query)
        return;
    end
end
end

