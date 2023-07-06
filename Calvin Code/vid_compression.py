import cv2
import os
import time

def loop_folder(root_folder):
    result = []
    for root, dirs, files in os.walk(root_folder):
        for dir in dirs:
            subfolder_path = os.path.join(root, dir)
            result.append(subfolder_path)
    return result

def findVideoName(root_dir):
    for file in os.listdir(root_dir):
        if file.endswith(".avi"):
            return os.path.join(root_dir, file)

def compress(root_dir):
    num_frames = 1777
    this_video_name = findVideoName(root_dir)

    video = cv2.VideoCapture(this_video_name)
    if not video.isOpened():
        print("Error reading video file")
        exit()

    frame_width = int(video.get(3))
    frame_height = int(video.get(4))
    size = (frame_width, frame_height)
    file_name_to_save = os.path.join(root_dir, 'vid.avi')

    result = cv2.VideoWriter(
        file_name_to_save, cv2.VideoWriter_fourcc(*'MJPG'), 25, size)

    for _ in range(int(num_frames)):
        ret, frame = video.read()

        if ret:
            result.write(frame)
            if cv2.waitKey(1) & 0xFF == ord('s'):
                break
        else:
            break
    print("Saved to", root_dir)

    video.release()
    result.release()


def main():
    print("Currently running Ruby")
    root_folder = r"F:\LIMBS_Hard_Drive\Ruby_9\Ruby_parsed_videos"
    il_level = 9
    for i in range(1, il_level + 1):
        sub_folder = os.path.join(root_folder, str(i))
        # a list of folders under a single illumination level, i.e. all valid trial folders.
        current_folder_list = loop_folder(sub_folder)
        for folder in current_folder_list:
            start_time = time.time()
            compress(folder)
            elapsed_time = time.time() - start_time  
            print("Runtime: {:.3f} seconds".format(elapsed_time))
            
main()