#!/usr/bin/env python3

import sys
import os
import glob
import csv
import re
from collections import Counter
from datetime import datetime

# input: log file name
# output: frame_drop_cnt and frame_rate_err
def cam_log_analysys(file_path, tolerance=0.02, verbose=False):
    frame_drop_cnt = 0
    frame_rate_err = 0
    max_seq_value = -1
    min_delta_value = float('inf')
    max_delta_value = float('-inf')
    fps_values = []
    try:
        with open(file_path, 'r') as file:
            for line in file:
                frame_drop_detected = False
                frame_rate_error_detected = False
                if 'ts:' in line and 'delta:' in line:
                    ts_value = float(line.split('ts:')[1].split()[0])
                    if ts_value == 0.0:
                        frame_drop_cnt += 1
                        frame_drop_detected = True
                if 'delta:' in line:
                    delta_value = float(line.split('delta:')[1].split()[0])
                    if delta_value > 0:
                        min_delta_value = min(min_delta_value, delta_value)
                        max_delta_value = max(max_delta_value, delta_value)
                        if not (33.33-tolerance) <= delta_value <= (33.33+tolerance):
                            frame_rate_err += 1
                            frame_rate_error_detected = True
                if 'seq:' in line and 'error' not in line:
                    seq_value = int(line.split('seq:')[1].split()[0])
                    max_seq_value = max(max_seq_value, seq_value)
                if 'fps:' in line:
                    fps_value = float(line.split('fps:')[1].split()[0])
                    fps_values.append(fps_value)
                if (frame_drop_detected or frame_rate_error_detected):
                    with open(file_path+'_result', 'a') as result_file:
                        result_file.write(line)
                    if verbose == True:
                        print(f'Error detected: {line}')
    except:
        print("Failed to open `" + file_path + "`!")
        sys.exit(1)
        
    most_fps = Counter(fps_values).most_common(1)[0][0] if fps_values else 0

    # # Write the results to a file
    # result_file_path = os.path.join(file_path + '_result')
    # with open(result_file_path, 'w') as f:
    #     f.write(f'Frame Drop Count: {frame_drop_cnt}\n')
    #     f.write(f'Frame Rate Error: {frame_rate_err}\n')
    #     f.write(f'Max seq: {max_seq_value}\n')
    #     f.write(f'Min delta: {min_delta_value}\n')
    #     f.write(f'Max delta: {max_delta_value}\n')
    #     f.write(f'Average fps: {avg_fps}\n')
    
    return frame_drop_cnt, frame_rate_err, max_seq_value, min_delta_value, max_delta_value, most_fps

def usage():
    print("Usage:")
    print("./analyze_cam_log.py file_dir file_prefix [-v] [tolerance]")
    print("file_dir: The directory of the files to be analyzed")
    print("file_prefix: The prefix of the files to be analyzed")
    print("-v: Optional parameter, if this parameter is entered, the line will be output when a frame drop or frame rate error occurs")
    print("tolerance: Optional parameter, if this parameter is entered, it will be used to adjust the tolerance range of delta")

if __name__ == "__main__":

    verbose = False
    tolerance = 0.02
    file_dir = None
    file_prefix = None
    for arg in sys.argv[1:]:
        try:
            tolerance = float(arg)
        except ValueError:
            if arg == '-v':
                verbose = True
            elif file_dir is None:
                file_dir = arg
            else:
                file_prefix = arg
    if file_dir is None or file_prefix is None:
        print("Error! Please enter the file_dir and file_prefix")
        usage()
        sys.exit(1)
    
    # Search for all files in the directory that start with the prefix. The regex will match the last number
    files = sorted(glob.glob(os.path.join(file_dir, file_prefix + '*')), key=lambda x: int(re.search(r'(\d+)(?!.*\d)', x).group()))
        
    # Analyze each file and write the results to a CSV file
    result_file=os.path.join(file_dir, file_prefix+'_result.csv')
    with open(result_file, 'w', newline='') as csvfile:
        fieldnames = ['Date/Time', 'File', 'Result', 'Total Frames', 'Frame Drop Count', 'Frame Rate Error', 'FPS', 'Min delta', 'Max delta', 'Tolerance']
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()
        for file_path in files:
            print(f"Analyzing the log: {file_path}")
            frame_drop_cnt, frame_rate_err, max_seq_value, min_delta_value, max_delta_value, most_fps = cam_log_analysys(file_path, tolerance, verbose)
            # Extract the date and time from the file_path
            datetime_str = file_path.split('/')[-1].split('_video')[0][-14:]
            datetime_obj = datetime.strptime(datetime_str, "%Y%m%d%H%M%S")
            datetime_formatted = datetime_obj.strftime("%Y/%m/%d %H:%M:%S")
            result = 'PASS' if frame_drop_cnt == 0 and frame_rate_err == 0 and most_fps > 0 else 'FAIL'
            total_frames = max_seq_value + 1
            writer.writerow({'Date/Time': datetime_formatted, 'File': file_path, 'Result': result, 'Total Frames': total_frames, 'Frame Drop Count': frame_drop_cnt, 'Frame Rate Error': frame_rate_err, 'FPS': most_fps, 'Min delta': min_delta_value, 'Max delta': max_delta_value, 'Tolerance': tolerance})
            if verbose:
                print(f'Total Frames: {total_frames}')
                print(f"Frame Drop Count: {frame_drop_cnt}")
                print(f"Frame Rate Error: {frame_rate_err}")
                print(f'Min delta: {min_delta_value}')
                print(f'Max delta: {max_delta_value}')
                print(f'FPS: {most_fps}')
        print(f'The result file can be found at {result_file}')
            