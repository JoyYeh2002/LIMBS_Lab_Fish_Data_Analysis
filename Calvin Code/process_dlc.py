import numpy as np
import pandas as pd
import os
import sys
from scipy.integrate import quad
import cv2
import matplotlib.pyplot as plt


# Gets curve length of a polynomial function with given coefficients and an
# interval of interest
def get_cubic_curve_length(coeff, x1, x2):
    function = np.poly1d(coeff)
    def integrand(x):
        dfdx = np.polyder(function)
        return np.sqrt(1 + (dfdx[2]*x**2 + dfdx[1]*x + dfdx[0])**2)

    # Integrate over interval x1 to x2
    length, _ = quad(integrand, x1, x2)
    return length


def cubic_arc_solver(coeff, x1, target):
    # roughly accurate estimate
    initial_guess = 45
    sig_figs = 100000

    def approximate(guess, step):
        current_length = get_cubic_curve_length(coeff, x1, x1 + guess)
        # if we are within desired accuracy
        if abs(current_length - target) <= 1 / sig_figs:
            return round(x1 + guess, 3)
        # if we overapproximated 
        elif current_length > target:
            return approximate(guess - step, step / 2)
        else:
            return approximate(guess + step, step / 2)

    return approximate(initial_guess, initial_guess / 2)


def get_fish_length(folder_path):
    target = 'Dataset02Jul26shuffle1_150000.csv'
    fish_length = 0

    items = os.listdir(folder_path)
    matching_file = [item for item in items if item.endswith(target)]
    dlc_csv_path = os.path.join(folder_path, matching_file[0])
    data = pd.read_csv(dlc_csv_path)

    x_columns = data.iloc[:, [1, 4, 7, 10, 13, 16, 19, 22]]
    y_columns = data.iloc[:, [2, 5, 8, 11, 14, 17, 20, 23]]

    x_data = x_columns.iloc[2:, :].values.tolist()
    y_data = y_columns.iloc[2:, :].values.tolist()
   

    for x_row, y_row in zip(x_data, y_data):
        x = np.array([float(elem) for elem in x_row])
        y = np.array([float(elem) for elem in y_row])

        coeff = np.polyfit(x, y, 3)
        current_length = get_cubic_curve_length(coeff, x[0], x[-1])
        if current_length > fish_length:
            fish_length = current_length

    return fish_length
        

def get_equidistant_points(folder_path, fish_length):
    num_points = 12
    target = 'Dataset02Jul26shuffle1_150000.csv'

    items = os.listdir(folder_path)
    matching_file = [item for item in items if item.endswith(target)]
    dlc_csv_path = os.path.join(folder_path, matching_file[0])
    data = pd.read_csv(dlc_csv_path)

    x_columns = data.iloc[:, [1, 4, 7, 10, 13, 16, 19, 22]]
    y_columns = data.iloc[:, [2, 5, 8, 11, 14, 17, 20, 23]]

    x_data = x_columns.iloc[2:, :].values.tolist()
    y_data = y_columns.iloc[2:, :].values.tolist()

    x_interp_data = []
    y_interp_data = [] 

    current_frame = 1
    total_frames = len(x_data)
    print('Progress: [', end='')
    progress = 0

    for x_row, y_row in zip(x_data, y_data):
        x = np.array([float(elem) for elem in x_row])
        y = np.array([float(elem) for elem in y_row])

        x_interp = []
        y_interp = []

        coeff = np.polyfit(x, y, 3)
        x_interp.append(round(x[0], 3))
        y_interp.append(round(y[0], 3))

        for i in range(num_points - 1):
            target_segment = 0
            if i < 4:
                target_segment = fish_length / 8
            else:
                target_segment = fish_length / 14

            x_value = cubic_arc_solver(coeff, x_interp[-1], target_segment)
            y_value = np.poly1d(coeff)(x_value)

            x_interp.append(x_value)
            y_interp.append(round(y_value, 3))

        x_interp_data.append(x_interp)
        y_interp_data.append(y_interp)

        new_progress = int((current_frame / total_frames) * 50)
        if new_progress > progress:
            print('.' * (new_progress - progress), end='')
            progress = new_progress

        current_frame += 1


    x_interp_df = pd.DataFrame(x_interp_data, columns=[f'x_interp_{i+1}' for i in range(num_points)])
    y_interp_df = pd.DataFrame(y_interp_data, columns=[f'y_interp_{i+1}' for i in range(num_points)])

    # Save dataframes to CSV files
    x_interp_df.to_csv(os.path.join(folder_path, 'x_interp_data.csv'), index=False)
    y_interp_df.to_csv(os.path.join(folder_path, 'y_interp_data.csv'), index=False)
    
    print('.' * (50 - progress),'] 100%')
    print(f"Interpolation Completed for {folder_path}")


def find_brightest_point(image, x_roi, y_roi):
    if image is None or image.shape[0] == 0 or image.shape[1] == 0:
        return (x_roi + 5, y_roi + 10)

    min_threshold = 10
    if image.max() < min_threshold:
        return (x_roi + 5, y_roi + 10)

    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    min_val, max_val, min_loc, max_loc = cv2.minMaxLoc(gray)
    absolute_brightest_point = (max_loc[0] + x_roi,  max_loc[1] + y_roi) 
    return absolute_brightest_point


def correct_trial(folder_path):
    num_points = 12
    # Read the CSV data
    x_data = pd.read_csv(f'{folder_path}/x_interp_data.csv')
    y_data = pd.read_csv(f'{folder_path}/y_interp_data.csv')

    # Load the video
    video_capture = cv2.VideoCapture(f'{folder_path}/vid_pre_processed.avi')

    current_frame = 0
    x_interp_data = []
    y_interp_data = []

    total_frames = min(len(x_data), int(video_capture.get(cv2.CAP_PROP_FRAME_COUNT)))
    print('Progress: [', end='')
    progress = 0

    for x_row, y_row in zip(x_data.iterrows(), y_data.iterrows()):
        x = x_row[1].values  
        y = y_row[1].values

        video_capture.set(cv2.CAP_PROP_POS_FRAMES, current_frame)
        ret, frame = video_capture.read()

        if not ret:
            break 

        for i in range(8, num_points - 1):
            x_point, y_point = x[i], y[i]

            # Define a region of interest (ROI) around the point
            roi_size = 10 
            horizontal_span = 2
            x_roi = int(x_point - horizontal_span / 2)
            y_roi = int(y_point - roi_size / 2)
            roi = frame[y_roi:y_roi + roi_size, x_roi:x_roi + horizontal_span]

            brightest_point = find_brightest_point(roi, x_roi, y_roi)

            x[i], y[i] = x_point, brightest_point[1]

        x_interp_data.append(x)
        y_interp_data.append(y)

        new_progress = int((current_frame / total_frames) * 50)
        if new_progress > progress:
            print('.' * (new_progress - progress), end='')
            progress = new_progress

        current_frame += 1
        
    x_interp_df = pd.DataFrame(x_interp_data, columns=[f'x_interp_{i+1}' for i in range(num_points)])
    y_interp_df = pd.DataFrame(y_interp_data, columns=[f'y_interp_{i+1}' for i in range(num_points)])

    # Save the updated CSV data
    x_interp_df.to_csv(os.path.join(folder_path, 'x_interp_data.csv'), index=False)
    y_interp_df.to_csv(os.path.join(folder_path, 'y_interp_data.csv'), index=False)

    print('.' * (50 - progress),'] 100%')
    video_capture.release()

    print(f'Correction completed for {folder_path}')




def plot_interpolation(folder_path):

    x_data = pd.read_csv(os.path.join(folder_path, 'x_interp_data.csv'))
    y_data = pd.read_csv(os.path.join(folder_path, 'y_interp_data.csv'))

    input_video_path = f'{folder_path}/vid_pre_processed.avi'
    output_video_path = f'{folder_path}/interpolated_output_video.avi'

    frame_rate = 25

    video_reader = cv2.VideoCapture(input_video_path)
    width = int(video_reader.get(cv2.CAP_PROP_FRAME_WIDTH))
    height = int(video_reader.get(cv2.CAP_PROP_FRAME_HEIGHT))

    fourcc = cv2.VideoWriter_fourcc(*'MJPG')
    output_video = cv2.VideoWriter(output_video_path, fourcc, frame_rate, (width, height))

    total_frames = min(len(x_data), int(video_reader.get(cv2.CAP_PROP_FRAME_COUNT)))
    print('Progress: [', end='')
    progress = 0

    for i in range(1, total_frames + 1):
        ret, frame = video_reader.read()
        
        if not ret:
            break
        x_coords = x_data.iloc[i - 1, :].values
        y_coords = y_data.iloc[i - 1, :].values

        # Draw smaller circles and connect lines to them
        for x, y in zip(x_coords, y_coords):
            cv2.circle(frame, (int(x), int(y)), 3, (0, 0, 255), -1)
            if len(x_coords) > 1:
                for j in range(len(x_coords) - 1):
                    cv2.line(frame, (int(x_coords[j]), int(y_coords[j])), (int(x_coords[j + 1]), int(y_coords[j + 1])), (0, 0, 255), 1)

        output_video.write(frame)

        new_progress = int((i / total_frames) * 50)
        if new_progress > progress:
            print('.' * (new_progress - progress), end='')
            progress = new_progress

    print('.' * (50 - progress),'] 100%')

    video_reader.release()
    output_video.release()

    print(f'Video saved to {output_video_path}')


path = r'F:\LIMBS_Hard_Drive_Completed\Doris\Doris_parsed_videos\11\trial53_il_11_1'

get_equidistant_points(path, 275)
correct_trial(path)
plot_interpolation(path)



def process_all_fish(root_dir, option):
    items = os.listdir(root_dir)
    fish_folders = [item for item in items if os.path.isdir(os.path.join(root_dir, item))]
    lengths = {"Doris": 275, "Finn": 285, "Hope": 305, "Len": 277, "Ruby": 270} 

    for fish in fish_folders:
        parsed_video_path = os.path.join(root_dir, fish, f"{fish}_parsed_videos")
        if not os.path.exists(parsed_video_path):
            print("Fish parsed video path missing. Terminating process.")
            sys.exit()
        else:
            items = os.listdir(parsed_video_path)
            illumination_folders = [item for item in items if os.path.isdir(os.path.join(parsed_video_path, item))]
        for illum in illumination_folders:
            if illum.isnumeric():
                illum_path = os.path.join(parsed_video_path, illum)
                items = os.listdir(illum_path)
                trials = [item for item in items if os.path.isdir(os.path.join(illum_path, item))]
                trial_folder_paths = [os.path.join(illum_path, subfolder) for subfolder in trials]
                for trial_path in trial_folder_paths:
                    if not os.path.exists(trial_path):
                        print('Invalid trial folder path. Terminating process.')
                        sys.exit()
                    else:
                        if option == 'all':
                            get_equidistant_points(trial_path, lengths[fish])
                            correct_trial(trial_path)
                            plot_interpolation(trial_path)
                        elif option == 'interpolation':
                            get_equidistant_points(trial_path, lengths[fish])
                        elif option == 'correction':
                            correct_trial(trial_path)
                        elif option == 'plot':
                            plot_interpolation(trial_path)
                        else:
                            print('Invalid option selected. Terminating process.')
                            sys.exit()


def main():
    root_dir = r'F:\LIMBS_Hard_Drive_All_Spaced'
    option = 'all'

    if option == 'all':
        print('Currently running all operations')
    elif option == 'interpolation':
        print('Currently only running get_equidistant_points()')
    elif option == 'correction':
        print('Currently only running correct_trial()')
    elif option == 'plot':
        print('Currently onlyrunning plot_interpolation()')
    else:
        print('Invalid option selected. Terminating process.')
        sys.exit()
    
    print("Starting...")
    process_all_fish(root_dir, option)
    print("Completed.")

#if __name__ == "__main__":
    #main()
