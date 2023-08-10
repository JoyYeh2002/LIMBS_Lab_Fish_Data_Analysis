import os

# Define parameters
fish_name = 'Doris'
exp_name = 'Stuff'

config_path = r'E:\Summer_2021\LIMBS_Lab\Deep_Lab_Cut\YY_Hope_Zip\Hope_cond_3-YY-2021-08-23\config.yaml'
video_path = r'F:\LIMBS_Hard_Drive\Doris_Stuff'
file_save_name = 'anaconda_script.txt'

def clean_up_backslashes(input_string):
    cleaned_string = ''
    prev_char = ''
    for char in input_string:
        if char == '\\' and prev_char == '\\':
            # Skip adding the consecutive backslash
            continue
        cleaned_string += char
        prev_char = char
    return cleaned_string


# Function to find trial folders
def find_trial_folders(this_folder):
    dir_list = os.listdir(this_folder)
    dir_list = [item for item in dir_list if os.path.isdir(os.path.join(this_folder, item)) and not item.startswith('.')]
    return dir_list


# Find trial folders
trial_folder_list = find_trial_folders(video_path)
actual_video_names_list = []


# Create a list of actual video names
for folder in trial_folder_list:
    video_file = os.path.join(video_path, folder, 'vid_*.avi')
    file_struct = [f for f in os.listdir(os.path.join(video_path, folder)) if f.startswith('vid_') and f.endswith('.avi')]
    this_actual_name = folder + '/' + file_struct[0]
    actual_video_names_list.append(this_actual_name)


# Beginning instructions
prompt = (f"Here are the DLC commands for tracking {fish_name} {exp_name} videos.\n"
          f"There will be 3 commands below: one for analyzing/labeling videos, one for plotting graphs and the other for"
          f" creating labeled videos. Copy and paste the commands in the Anaconda iPython prompt"
          f" after the following steps:\n"
          f" 1. Open Anaconda prompt and type \"conda activate deeplabcut\"\n"
          f" 2. Type \"ipython\"\n"
          f" 3. Type \"import deeplabcut\"\n"
          f" Then, paste the following command:\n\n")

function_name_analyze = 'deeplabcut.analyze_videos('
function_name_plot = 'deeplabcut.plot_trajectories('
function_name_create = 'deeplabcut.create_labeled_video('


# Create the video list string
video_list_string_all = []

for i in range(0, len(actual_video_names_list)):
    this_string = video_path + '/' + actual_video_names_list[i]
    video_list_string_all.append(this_string)

size = len(video_list_string_all)
# Define the function call endings
video_list_string_analyze = clean_up_backslashes(str(video_list_string_all[:size]) + ', save_as_csv=True)')
video_list_string_plot = clean_up_backslashes(str(video_list_string_all[:size]) + ', showfigures=False)')
video_list_string_create = clean_up_backslashes(str(video_list_string_all[:size]) + ', save_frames=False)')

command_string_analyze = f"{function_name_analyze}'{config_path}', {video_list_string_analyze}"
between_text_one = "\n\nThis is SECOND command. Paste it after the first one is finished:\n\n"
command_string_plot = f"{function_name_plot}'{config_path}', {video_list_string_plot}\n"
between_text_two = "\nThis is THIRD command. Paste it after the second one is finished:\n\n"
command_string_create = f"{function_name_create}'{config_path}', {video_list_string_create}\n"

after_text = (f"\nIf all commands complete without errors, the tracked .csv and videos should be"
              f" in the original directory.")

all_text_content = f"{prompt}\n{command_string_analyze}\n{between_text_one}\n{command_string_plot}\n{between_text_two}\n{command_string_create}\n{after_text}"

full_save_path = video_path + '/' + file_save_name
with open(full_save_path, 'w') as f:
    f.write(all_text_content)
