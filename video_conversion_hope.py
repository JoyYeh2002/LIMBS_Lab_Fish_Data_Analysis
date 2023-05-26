# hello
# Python program to save a 
# video using OpenCV
  
import cv2
import pandas as pd
import glob
import xlrd

import os
from os import listdir
import re

# Helper: Returns the video file name in a directory
# sample call:
# rootdir = r"E:\Summer_2021\LIMBS_Lab\Data\Hope_New\Video\Trial01_il"
# dir_list = []
# returns: populates dir_list with all the folders in the root_dir. 
def findVideoName(rootdir):
    for file in os.listdir(rootdir):
        if file.endswith(".avi"):
            return (os.path.join(rootdir, file))
    
def locateRootDirectory(top_level_directory_name):
    script_directory = os.path.dirname(os.path.abspath(__file__))
    os.chdir(script_directory)
    current_directory = os.getcwd()  # Get the current working directory
    parent_directory = os.path.dirname(current_directory)  # Get the parent directory
    root_directory = parent_directory + top_level_directory_name # Root directory name
    return root_directory

def process_and_save_video(root_dir):
    this_video_name = findVideoName(root_dir)
    video = cv2.VideoCapture(this_video_name)

    # Check if file is properly opened
    if not video.isOpened():
        print("Error reading video file")
        return
    
    # Set resolutions
    frame_width = int(video.get(3))
    frame_height = int(video.get(4))
    size = (frame_width, frame_height)
    file_name_to_save = os.path.join(root_dir, 'vid.avi')

    # VideoWriter object to write frames into the output file
    result = cv2.VideoWriter(file_name_to_save,
                             cv2.VideoWriter_fourcc(*'MJPG'),
                             25, size)

    num_frames = int(video.get(cv2.CAP_PROP_FRAME_COUNT))

    for i in range(num_frames):
        ret, frame = video.read()

        if ret:
            # Write the frame into the output file
            result.write(frame)
            # cv2.imshow('Frame', frame)

            # Press S on keyboard to stop the process
            if cv2.waitKey(1) & 0xFF == ord('s'):
                break
        else:
            break

    # Release the video capture and video write objects
    video.release()
    result.release()

    # Close all frames
    cv2.destroyAllWindows()

    print("SUCCESS: The video of", root_dir, "was saved.")

''' MAIN STARTS HERE '''
root_directory = locateRootDirectory("/data/hope_population_analysis/")
work_with_all_videos = False

# Default: Work with all videos
if work_with_all_videos == True:
    folder_count = 6  # Total number of folders
    num_frames = 1777

    # for i in range(5, folder_count + 1):
    folder_name = os.path.join(root_directory, "L{}".format(2))
    subdirectories = [subdir for subdir in os.listdir(folder_name) if os.path.isdir(os.path.join(folder_name, subdir))]

    # Loop through subdirectories and process each one
    for subdirectory in subdirectories:
        this_path = os.path.join(folder_name, subdirectory)

        # Process the subdirectory with the generated full path
        print("Processing:", this_path)
        process_and_save_video(this_path)

# In case something didn't work, convert indivitual videos again
else:
    this_path = root_directory + "L2/trial04_il_2/"
    print("Processing:", this_path)
    process_and_save_video(this_path)
    

       