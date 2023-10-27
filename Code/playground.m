% Playground 10.06.2023

% Define an empty structure with the specified fields
% 

    % % Create a figure for the plot
    % figure;
    % 
    % % x_limits = [0, 640];
    % % y_limits = [0, 190];
    % % axis equal;
    % % axis([x_limits, y_limits]);
    % 
    % % Plot all 12 columns with the jet colormap
    % hold on;
    % for col = 1 : numPoints
    %     scatter(x(:, col), y(:, col), 10, myColorMap(col, :), 'filled');
    % end
    % 
    % hold off;
    % 
    % % Add colorbar
    % colormap(myColorMap);
    % colorbar;
    % 
    % % Set axis limits
    % xlim([0, 640]);
    % ylim([0, 190]);
    % 
    % % Add labels and title as needed
    % xlabel('X-axis');
    % ylabel('Y-axis');
    % 
    % title([fish_name, ' Il = ', num2str(il), ' Trial #',...
    %     num2str(trial_idx), ' (1777 Frames Total)'])
    % 
    % grid on;
    % 
    % fig_out_path = [abs_path, data_dir_name, out_dir_figures];
    % fig_out_filename = [fish_name, '_trial_', num2str(trial_idx), ...
    %     '_il_', num2str(il), '_', num2str(head_dir), '.png'];
    % 
    % saveas(gcf, [fig_out_path, fig_out_filename]);
    % disp(['SUCCESS: ', fig_out_filename, ' is saved.']);

    
% abs_path = 'C:\Users\joy20\Folder\FA_2023\LIMBS Presentations\Data\';
% data_dir_name = 'ruby_pilot_data_full_body\';
% fish_name = 'Ruby';
% 
% directories = {'trial10_il_9_1\', ...
%     'trial26_il_3_-1\', ...
%     'trial23_il_1_-1\', ...
%     'trial32_il_6_1\', ...
%     'trial40_il_1_-1\'};
% 
% trial_dir = directories{1};
% x_filename = 'x_interp_data.csv';
% 
% this_dir = [abs_path, data_dir_name, trial_dir]; 
% dataTable = readCSVFile(this_dir, x_filename);
% 
% 
% % Helper: read data csv files and return tables
% function dataTable = readCSVFile(directory, data_filename)
%     % Check if the directory exists
%     if exist(directory, 'dir')
%         % List all CSV files in the directory
%         filePattern = fullfile([directory, data_filename]);
%         csvFiles = dir(filePattern);
% 
%         if isempty(csvFiles)
%             error('No CSV files found in the directory.');
%         end
% 
%         % Select the first CSV file (you can modify this logic as needed)
%         filename = csvFiles(1).name;
%         fullFilePath = fullfile(directory, filename);
% 
%         % Read table (1777 x 12)
%         if exist(fullFilePath, 'file')
%             dataTable = readmatrix(fullFilePath);
%         else
%             error('Selected CSV file does not exist.');
%         end
%     else
%         error('Directory does not exist.');
%     end
% end
% 
% 


% % Sample struct array with a field "fishName"
% myStruct = {}
% myStruct(1).fishName = 'Hope';
% myStruct(2).fishName = 'Ruby';
% myStruct(3).fishName = 'Len';
% myStruct(4).fishName = 'Finn';
% myStruct(5).fishName = 'Doris';
% 
% 
% % Query the struct by "fishName"
% queryName = 'Finn';  % The name you want to search for
% matchingElements = queryStructByField(myStruct, 'fishName', queryName);
% 
% % Display the matching elements
% disp(matchingElements);
% 
% 
% function match = queryStructByField(struct, fieldName, query)
%     match = [];
%     for i = 1:numel(struct)
%         if isfield(struct(i), fieldName) && isequal(struct(i).(fieldName), query)
%             match = struct(i);
%             return;
%         end
%     end
% end
% 
% 
% 
% 

%% Build firh struct
% myStruct = struct('fish_idx', [], 'fish_name', []);
% for fishIndex = 1:numFish
%     myStruct(fishIndex).fish_idx = fishIndex;
%     myStruct(fishIndex).fish_name = fishNames(fishIndex);
% 
%     % Define the nested fields under each "il"
%     numIl = numIls(fishIndex);
% 
%     for il = 1:numIl
%         myStruct(fishIndex).luminance(il).il = il;
%         myStruct(fishIndex).luminance(il).trial_idx = zeros(5, 1);
%         % Define the nested fields under each "trial_num"
%         numTrials = 5;  % The actual number of trials
% 
%         % Add trial data for each trial_num (modify numTrials as needed)
%         for trial = 1:numTrials
%             myStruct(fishIndex).luminance(il).data(trial).trial_idx = [];  % -1 or 1
%             myStruct(fishIndex).luminance(il).data(trial).head_dir = [];  % -1 or 1
%             myStruct(fishIndex).luminance(il).data(trial).x_data_raw = zeros(1777, 1);
%             myStruct(fishIndex).luminance(il).data(trial).y_data_raw = zeros(1777, 1);
% 
%             myStruct(fishIndex).luminance(il).data(trial).x_rep1 = zeros(500, 1);
%             myStruct(fishIndex).luminance(il).data(trial).x_rep2 = zeros(500, 1);
%             myStruct(fishIndex).luminance(il).data(trial).x_rep3 = zeros(500, 1);
%             myStruct(fishIndex).luminance(il).data(trial).y_rep1 = zeros(500, 1);
%             myStruct(fishIndex).luminance(il).data(trial).y_rep2 = zeros(500, 1);
%             myStruct(fishIndex).luminance(il).data(trial).y_rep3 = zeros(500, 1);
%         end
%     end
% end
% 
% % Display the resulting structure
% disp(myStruct);
