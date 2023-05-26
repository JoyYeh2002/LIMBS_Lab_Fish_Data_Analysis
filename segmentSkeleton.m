% Joy Yeh Eigen Luminance Tail Motion Analysis
% Helper: segmentSkeleton.m
%
% After redacting shuttle and pinning fish, we get "...vid_pre_processed.avi"
% 1) Contrast enhancement to brighten the fish
% 2) Use vertical line intersections to find skeleton notes
% 3) Save "y_tracked_data.csv" and "body_tracked_data.mat" at the input
% directory
%
% [04/02] Runtime: 19.5s
% [04/17] Runtime: 6.8s


function segmentSkeleton(input_dir, ...
    x_origin, y_origin, x_min, x_max, mid_range, gap, gap_small, probe_frame_num)

close all
tic()
input_vid_name = [input_dir, 'vid_pre_processed.avi'];
v = VideoReader(input_vid_name);
x_anchors = [x_min : gap : x_min + mid_range, ...
    x_min + mid_range + gap_small: gap_small : x_max];

all_outputs = zeros(v.NumFrames, size(x_anchors, 2) + 1);

% Loop through frames
for i = 1 : v.NumFrames  
 
    % Read and enhance frame img
    I = read(v, i);
    I = im2gray(I);
    I_adj = imadjust(I, [0.2 0.5], [0 1]);
    
    % Locate stars in a loop
    num_vertical_sections = 50;
    num_vertical_sections_tail = 50;
    y_start = 30; % skip some calculations at the top
    y_locations = [];
    
    % Iterate over vertical strips
    for x = x_anchors
        this_strip = I_adj(y_start : end, x : x + 5);
        thisStar = locateStar(this_strip, num_vertical_sections) + y_start;
        
        if x >= x_anchors(end - 2)
            thisStar = locateStar(this_strip, num_vertical_sections_tail) + y_start;
        end
        
        y_locations = [y_locations, thisStar];
    end
    
    % Update all_outputs
    all_outputs(i, :) = [y_locations(:, 1), y_origin, y_locations(:, 2:end)];

end

% Build the excel file
x_outputs = [x_anchors(:, 1), x_origin, x_anchors(:, 2:end)];
col_title = cell(1, length(x_outputs)+1);
col_title{1} = 'Frame#';

for i = 1:length(x_outputs)
    col_title{i+1} = ['y', num2str(i), ' (x = ', num2str(x_outputs(i)), ')'];
end

mat_name = [input_dir, 'pre_tracking_body.mat'];
save(mat_name, 'input_dir', 'v', 'x_outputs', 'col_title', 'all_outputs');

% [USE THIS FOR .CSV] Combine col_title and all_outputs into a single cell array
% indices = 1:v.NumFrames;
% combined_array = [col_title; num2cell(horzcat(indices', all_outputs))];

% Write the combined array to a CSV file
% csv_name = [input_dir, 'pre_tracking_y.csv'];
% writecell(combined_array, csv_name);

%% [Updated 04/17] Probe: return a labeled frame #1
probe = 0;

if probe == 1
    for idx = probe_frame_num
        I_sample = read(v, idx);
        fig = figure();
        imshow(I_sample);
        
        hold on
        scatter(x_outputs, all_outputs(idx, :), 'm', 'filled','SizeData', 9);
        title([input_dir, ' Frame #', num2str(idx)]);
        hold off
        
        pause(0.8)
    end
end

% [UPDATE 05/25] Don't savecsv, use .mat
% disp(['SUCCESS: ', csv_name, ' is saved.']);  
disp(['SUCCESS: ', mat_name, ' is saved.']); 
toc()
end
