% Step 14: Histogram of tail point travelled distance

close all;
abs_path = 'C:\Users\joy20\Folder\FA_2023\LIMBS Presentations\data\fish\';
out_dir_figures = 'C:\Users\joy20\Folder\FA_2023\LIMBS Presentations\Outputs\';
out_path = 'C:\Users\joy20\Folder\FA_2023\LIMBS Presentations\Outputs\';

struct_file = load([out_path, 'rotated_fish_valid.mat']); % All the raw + cleaned data labels for Bode analyis
all_fish = struct_file.all_fish;

fish_names = {'Hope', 'Ruby', 'Len', 'Finn', 'Doris'};

% Look at Ruby for now.

% Video settings
p2m = 0.002;
frame_rate = 25; 
% results = struct('luminance', {}, 'trial', {}, 'total_distance', {}, 'average_speed', {});

results = struct('Hope', [], 'Ruby', [], 'Len', [], 'Finn', [], 'Doris', []);

loop_create_struct = 1;
if loop_create_struct == 1
for fish_idx = 1 % : 5% Now looking at fish #2
    fish_name = fish_names{fish_idx};
    this_fish = struct('luminance', [], 'trial', [], 'tr_idx', [], 'dist1', [], 'dist2', [],'dist3', [],'avg_speed', []);

    for il = 1 : numel(all_fish(fish_idx).luminance)
        for i = 1 : numel(all_fish(fish_idx).luminance(il).data)
            data = all_fish(fish_idx).luminance(il).data(i); % Trial fish_idx = 2
            idx = all_fish(fish_idx).luminance(il).data(i).trial_idx;
            v = all_fish(fish_idx).luminance(il).data(i).validity;

            dist1 = sum(get_distances(data, 'x_rep1', 'y_rep1', v(1)));
            dist2 = sum(get_distances(data, 'x_rep2', 'y_rep2', v(2)));
            dist3 = sum(get_distances(data, 'x_rep3', 'y_rep3', v(3)));

            num_valid_reps = sum(v);
            avg_speed = (dist1 + dist2 + dist3) / (20 * num_valid_reps); % trial has 60 seconds
        
            % Find the index for the current iteration
            index = numel(this_fish) + 1;

            % Store results in the structure at the specified index
            this_fish(index).luminance = il;
            this_fish(index).trial = i;
            this_fish(index).tr_idx = idx;
            this_fish(index).dist1 = dist1;
            this_fish(index).dist2 = dist2;
            this_fish(index).dist3 = dist3;
            this_fish(index).avg_speed = avg_speed;

      
        end
    end
    results.(fish_name) = this_fish(2:end);
end
end

% Convert the struct to a table
name = 'Hope';
tableResults = struct2table(results.(name));

excelFileName = [out_path, 'distance_results_', name, '.xlsx'];

% Write the table to an Excel file
writetable(tableResults, excelFileName);


% 
% % Extract luminance and total distance for plotting
% luminance_values = [results.luminance];
% distance_values = [results.total_distance];
% 
% % Define a colormap with a color for each luminance level
% colormap_values = parula(max(luminance_values));
% 
% % Create a grouped bar plot with different colors for each luminance
% figure;
% h = bar(1:numel(luminance_values), distance_values, 'grouped');
% colormap(colormap_values);
% xticks(1:numel(luminance_values));
% xticklabels(cellstr(num2str(luminance_values')));
% xlabel('Luminance');
% ylabel('Total Distance Traveled (m)');
% title('Luminance vs. Total Distance Traveled');
% legend(h, cellstr(num2str((1:max(luminance_values))')));
% grid on;
% 
% % Save the figure if needed
% saveas(gcf, [out_dir_figures, 'colored_luminance_distance_plot.png']);


% Helper: if this rep is valid, calculate the distance. Otherwise, return 0
function dist = get_distances(data, x, y, validity)
    if validity == 1
        p2m = 0.002;
        x_target = data.(x)(:, 12) * p2m;
        y_target = data.(y)(:, 12) * p2m;
        dist = sqrt(diff(x_target).^2  + diff(y_target).^2 );
    else
        dist = 0;
    end
end

