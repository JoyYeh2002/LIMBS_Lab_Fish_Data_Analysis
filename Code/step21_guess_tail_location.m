% Step21: Guess_Tail_Point.m
%% 1. Load the Excel file data
out_path = 'C:\Users\joy20\Folder\FA_2023\LIMBS Presentations\Data\fish_structs_2024\'; % [INPUT] could modify or add more fish

close all;

fishNames = {'Hope', 'Len', 'Doris', 'Finn', 'Ruby'}; % consistent with SICB
numIls = [14, 9, 11, 9, 9];
numFish = 5;
thresh = 360;

%% 1. Get luminance levels in the body struct
head_file = load([out_path, 'data_raw_body.mat']);
all_fish = head_file.all_fish;
time = 1:500;

tally = [];
for i = 1  %: numFish

    name = fishNames{i};
    num_il_levels = numel(all_fish(i).luminance);

    for il = 1 %: num_il_levels

        num_trials = numel(all_fish(i).luminance(il).data);

 
        for trial_idx = 1 : num_trials
            validity_tail = zeros(1, 3);
            tail_tags = zeros(1, 3);

            for rep = 1 %: 3
                field_name = ['x_origin', num2str(rep)];
                origin_x = all_fish(i).luminance(il).data(trial_idx).(field_name);

                
                logicalIndex = origin_x < thresh;

                % Assign 1 to elements less than 340 and 0 otherwise using logical indexing
                resultArray = zeros(size(origin_x));
                resultArray(logicalIndex) = 1;
                good_percentage = sum(resultArray)/500 * 100;
                
                validity_tail(rep) = round(good_percentage, 0);
                tail_tags(rep) = round(good_percentage, 0) == 100;

                fig = figure;
                hold on
                plot(time, origin_x)
                plot(time, resultArray * 100)
                title('Blue: fish head origin point, red: valid = 1, not valid = 0')
               
                
                tally(end+1) = good_percentage;
              

            end
            % all_fish(i).luminance(il).data(trial_idx).validity_tail = validity_tail;
            % all_fish(i).luminance(il).data(trial_idx).tail_tags = tail_tags;
        end
    end
end

tally = tally';
summation = sum(tally == 100);

%% 2. Save the struct as it. In later scripts, just load this
% out_struct_filename = [out_path, 'data_raw_body.mat'];
% save(out_struct_filename, 'all_fish');
% disp(['SUCCESS: ', out_struct_filename, ' is saved.'])


