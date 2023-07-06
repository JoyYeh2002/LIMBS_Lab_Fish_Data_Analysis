% Eigen Luminance Tail Beat Analysis
% processAllVideos.m
%
% A combined function that:
% 1. Removes the shuttle bright strips with 2 black boxes
% 2. Rotate image if necessary
% 3. Pins the fish at a given coordinate (x = 220, y = 110) for Head == 'L'
%
% Average Runtime: 11.35s 
%
% Updated 07/06/2023

%================================================================================%
% UNCOMMENT BELOW TO USE %
%processAllIllumination('F:\LIMBS_Hard_Drive\Doris_11_Il_SOS\Doris_parsed_videos');
%disp('Completed processing.');
%================================================================================%

% This function takes in a path to a specific fish's parsed videos, and
% processes the subfolders wrt. illumination levels. 
function processAllIllumination(parentPath)
    % Gather all illumination levels for a single fish
    dirList = dir(parentPath);
    dirList = dirList([dirList.isdir]);  
    dirList = dirList(3:end);
    
    % Loop through all illumination level folders
    for i = 1:numel(dirList)
        subfolderName = dirList(i).name;
        subfolderPath = fullfile(parentPath, subfolderName);
        processSingleIllumination(subfolderPath);
    end
end

% This function takes in a path to a specific fish's illumination folder, 
% and processes the subfolders wrt. individual trials. 
function processSingleIllumination(parentPath)
    % Within each illumination, get a list of all trial folders
    dirList = dir(parentPath);
    dirList = dirList([dirList.isdir]);  
    dirList = dirList(3:end);
    
    % Loop through each illumination for single trials
    for i = 1:numel(dirList)
        subfolderName = dirList(i).name;
        subfolderPath = fullfile(parentPath, subfolderName);
        processVideo(subfolderPath);
    end
end

% This function takes in a path to a specific trial folder, and
% processes the vid.avi file where it rotates the video if necessary,
% redacts the shuttles towards the upper and lower bound of the video, and
% pins the fish's head to the coordinate (220,110). The function returns
% the complete path to the outputted video and saves it as an .avi file.
function output_vid_name = processVideo(this_fish_dir)
    x_anchor = 220;
    y_anchor = 110;
    head_direction = '';
    
    if this_fish_dir(end-1:end) == "-1"
        head_direction = 'L';
    else
        head_direction = 'R';
    end
    tic()
    close all;
    
    % Open DLC file
    % path = ['..\data\', this_fish_dir];
    path = this_fish_dir; % [NEW] use this for population analysis
    data_csv = dir(fullfile(path, 'video*.csv'));
    file = fullfile(path, data_csv.name);
    tracked_data = readtable(file);
    
    % Extract shuttle, fish x, and y positions from DLC
    if head_direction == 'L'
        shuttle_x = tracked_data{:, 5};
        shuttle_y = tracked_data{:, 6};
        x_data = tracked_data{:, 2};
        y_data = tracked_data{:, 3};
    else
        shuttle_x = 952 - tracked_data{:, 5};
        shuttle_y = 81 - tracked_data{:, 6};
        x_data = 1 + 640 - tracked_data{:, 2};
        y_data = 1 + 190 - tracked_data{:, 3};
    end

    % saving processed data to a new .mat file
    grid = [shuttle_x, shuttle_y, x_data, y_data];
    columnNames = {'shuttle_x', 'shuttle_y', 'x_data', 'y_data'};
    gridData = struct();
    for i = 1:size(grid, 2)
        gridData.(columnNames{i}) = grid(:, i);
    end
    filepath = [this_fish_dir, '/processedData.mat'];
    save(filepath, 'gridData');
    
    v = VideoReader([path, '/vid.avi']);
    
    % Create the output video
    outputVid = VideoWriter([path, '/vid_pre_processed.avi']);
    outputVid.FrameRate = 25;
    open(outputVid);
    
    % Setting params for this video
    for i = 1: v.NumFrames
        set(gcf,'visible','off')
        I = read(v, i);
        I = rgb2gray(I);
    
        if head_direction == 'R'
            I = imrotate(I, 180);  % Rotate the frame by 180 degrees
        end
    
        s_x = ceil(shuttle_x(i));
        s_y = ceil(shuttle_y(i));
    
        stretch_L = 360;
        stretch_R = 50;
    
        stretch_y = 110;
        half_height = 7;
    
        % Create 2 black rectangle masks
        rect_mask = zeros(size(I, 1), size(I, 2));
        rect_mask(1 : s_y + half_height, ...
            max(1, s_x - stretch_L) : min(640, s_x + stretch_R)) = 1;
        rect_mask(s_y + stretch_y - half_height : size(I, 1), ...
            max(1, s_x - stretch_L) : min(640, s_x + stretch_R)) = 1;
    
        % Apply the mask to the image
        I(rect_mask == 1) = 0;
    
        % Apply colormap to figure
        map = gray(256);
        colormap(gray(256));
    
        % Pin fish by shifting
        x = ceil(x_data(i));
        y = ceil(y_data(i));
        I_shifted = imtranslate(I, [x_anchor - x, y_anchor - y]);
    
        % Write to outputVid
        frame = ind2rgb(I_shifted, map);
        writeVideo(outputVid, frame);
    end
    
    close(outputVid)
    disp(['SUCCESS: ', path, '/vid_pre_processed.avi is saved']);
    output_vid_name = [path, 'vid_pre_processed.avi'];
    toc()
end
