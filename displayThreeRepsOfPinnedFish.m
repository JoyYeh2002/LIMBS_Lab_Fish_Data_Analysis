% Helper: temporary
% Given any fish directory, find the pinned video and stack the 3
% repetitions vertically.
% Later, interface it with the tracked traces. 
% 60FPS, could slow down.

% Load the video

function displayThreeRepsOfPinnedFish(input_dir)
tic()
% input_dir = '..\data\hope_population_analysis\L1\trial19_il_1\';
input_vid_name = [input_dir, 'vid_pre_processed.avi'];

pattern = 'L(\d+\\trial\d+)';
matches = regexp(input_dir, pattern, 'match', 'once');
output_title_start = strrep(matches, '\', '_');

video = VideoReader(input_vid_name);

% Define the frame ranges for the three clips
frameRange1 = [251,(251+499)];
frameRange2 = [(251+500),(251+999)];
frameRange3 = [(251+1000),(251+1499)];

% Read and store the frames for each clip
clip1Frames = read(video, frameRange1);
clip2Frames = read(video, frameRange2);
clip3Frames = read(video, frameRange3);

% Create a new figure for the subplots
figure;

% Set the figure size and position
figurePos = get(gcf, 'Position');
figurePos(3) = 640;
figurePos(4) = 570;
set(gcf, 'Position', figurePos);
set(gcf, 'Visible', 'off');
axis off;

% % Create the first subplot for clip 1
subplot('Position', [0, 2/3, 1, 1/3]);
imshow(clip1Frames(:,:,:,1));
axis off;

% Create the second subplot for clip 2
subplot('Position', [0, 1/3, 1, 1/3]);
imshow(clip2Frames(:,:,:,1));
axis off;

% Create the third subplot for clip 3
subplot('Position', [0, 0, 1, 1/3]);
imshow(clip3Frames(:,:,:,1));
axis off;

% Create a new video writer
vidFileName = ['../outputs/', output_title_start, '_tail_pinned_original.avi'];
outputVideo = VideoWriter(vidFileName, 'MPEG-4');
outputVideo.FrameRate = 60;
open(outputVideo);

% Loop through the frames and write them to the output video
for i = 1:min([size(clip1Frames, 4), size(clip2Frames, 4), size(clip3Frames, 4)])
    % Update the subplots with the corresponding frames
    subplot('Position', [0, 2/3, 1, 1/3]);
    imshow(clip1Frames(:,:,:,i));
    subplot('Position', [0, 1/3, 1, 1/3]);
    imshow(clip2Frames(:,:,:,i));
    subplot('Position', [0, 0, 1, 1/3]);
    imshow(clip3Frames(:,:,:,i));

    % Write the current frame to the output video
    frame = getframe(gcf);
    writeVideo(outputVideo, frame);
end

% Close the output video
close(outputVideo);

% Close the figure
close;

disp("SUCCESS: Stacked original video saved.");
toc()
end