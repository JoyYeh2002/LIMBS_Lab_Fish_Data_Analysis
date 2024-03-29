% Step20: Exp Clean Up Once Again.m
% Try to resolve the DLC randomly drawing tail issue
% For example the Hope Il = 1, trial = 8, rep 1, 2 has the tail not
% pictured in the camera, but it still hallucinates the tail

% Content:
% - Recover head point X value
% - Extimate where the tail should be
% - Flag the "valid regions"
% - Populate the validity tags

abs_path = 'C:\Users\joy20\Folder\FA_2023\LIMBS Presentations\Data\fish_structs_2024\';
excel_path = 'C:\Users\joy20\Folder\FA_2023\LIMBS Presentations\Data\fish\DLC_excel_all_fish\';
destination_path = 'C:\Users\joy20\Folder\FA_2023\LIMBS Presentations\Data\fish\';
load([abs_path, 'data_clean_head.mat']);

fishNames = {'Hope', 'Len', 'Doris', 'Finn', 'Ruby'}; % consistent with SICB
num_fish = 5;

for i = 5 %: num_fish
    fish_name = fishNames{i};
    dir_parent = [excel_path, fish_name];

    files = dir(fullfile(dir_parent, '*.csv')); % Change '*.txt' to match the file extension you're interested in

    % Loop through each file in the folder
    missing = {};
    for i = 1 : numel(files)
        filename = files(i).name;
        filepath = fullfile(dir_parent, filename);

        match = regexp(filename, '^(.*?)_DLC', 'tokens', 'once');
        if ~isempty(match)
            trial_prefix = match{1};

            % Split each string based on the "_" delimiter
            parts1 = split(trial_prefix, '_');
            luminance = parts1{end};

            trial_suffix = strsplit(filename, match{1}, 'CollapseDelimiters', false);
            trial_suffix = trial_suffix{end};
        end

        % Copy files to: ...fish/hope/1/trial03_il1_1
        target_try = [destination_path, lower(fish_name), '\', luminance, '\', trial_prefix, '_*'];
        target_destination = dir(fullfile(target_try));

        target_try2 = [destination_path, lower(fish_name), '\', luminance, '\', trial_prefix, '_-*'];
        target_destination2 = dir(fullfile(target_try2));


        % Check if any matching items were found
        if isempty(target_destination) && isempty(target_destination2)
            % No matching items found, handle the error or display a message
            missing{end + 1} = trial_prefix;
        else
            % Matching items were found, process them or display the list
            disp(['Matching Files or Folders: ', {target_destination.name}]);

            if ~isempty(target_destination)
                target_filename = [target_destination.folder, '\', target_destination.name, '\', trial_prefix, '_head', trial_suffix];
            elseif ~isempth(target_destination02)
                target_filename = [target_destination02.folder, '\', target_destination.name, '\', trial_prefix, '_head', trial_suffix];
            end

            copyfile(filepath, target_filename);
        end



        % Process the file or do other operations as needed

        % Save the target filename to the list

    end
    disp(["SUCCESS: ", filepath, " is saved."])
end

% Loop through each subdirectory and open it
% for j = 1:numel(dir_parent) % 47 x 1
%     trial_path = fullfile(dir_parent, dir_sub(j).name);
%
%     DLC_target = [trial_path '/' DLC_file_suffix];
%     DLC_filename = dir(DLC_target).name;
%     DLC_out_name = strcat(DLC_filename(21:23), '_', DLC_filename(7:20), '.csv');
%     DLC_fullname = [trial_path '/' DLC_filename];
%
%     out_filename = [out_path fish_name '\' trial_prefix '_' DLC_out_name];
%     copyfile(DLC_fullname, out_filename);
% end

%
% num_il_levels = numel(h(i).data);
%

%
% for il = 14 % : num_il_levels
%
%     num_trials = numel(h(i).data(il).fishX);
%     close all;
%     figure;
%     hold on
%
%     for trial_idx = 1 : num_trials
%          data = cell2mat(h(i).data(il).fishX(trial_idx));
%          plot(time, data)
%     end
%
% end



