% Manually select the clean trials - take out tracking loss

% Fish
close all;
abs_path = 'C:\Users\joy20\Folder\FA_2023\LIMBS Presentations\data\fish\';
out_dir_figures = 'C:\Users\joy20\Folder\FA_2023\LIMBS Presentations\Outputs\';

struct_file = load([abs_path, 'rotated_fish.mat']); % All the raw + cleaned data labels for Bode analyis
all_fish_data = struct_file.mBody.all_fish_data;



fish_names = {'Hope', 'Len', 'Doris', 'Finn', 'Ruby'};

for k = 1 %:numel(fishNames)
    fish_name = fishNames{k}; % Hope
    fish_idx = queryStruct(all_fish_data, 'fish_name', fish_name);

    for il = 1 : numel(all_fish_data(fish_idx).luminance) 
        for idx = 1 : numel(all_fish_data(fish_idx).luminance(il).data
            data = all_fish_data(fish_idx).luminance(il).data(idx);
            trial_idx = all_fish_data(fish_idx).luminance(il).trial_indices(idx);



            % Put code here
        end
    end
end

end




%% Helper: Find struct by field name
function i = queryStruct(struct, fieldName, query)
for i = 1:numel(struct)
    if isfield(struct(i), fieldName) && isequal(struct(i).(fieldName), query)
        return;
    end
end
end

