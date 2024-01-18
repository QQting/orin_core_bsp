#!/usr/bin/env python3

import os
import sys

def check_cam_log_done(LOG_DIR, LOG_PREFIX, STREAM_COUNT):
    for filename in os.listdir(LOG_DIR):
        if filename.startswith(LOG_PREFIX) and "result" not in filename:
            with open(os.path.join(LOG_DIR, filename), 'r') as file:
                lines = file.readlines()
                last_line = lines[-1].strip()
                if not last_line:  # if the last line is empty or contains only spaces
                    last_line = lines[-2]  # read the second last line
                if "error" not in last_line and "resource busy" not in last_line:
                    seq_value = int(last_line.split("seq:")[1].split()[0])
                    if seq_value + 1 < STREAM_COUNT:
                        # print(f"filename={filename}")
                        # print(f"last_line={last_line}")
                        # print(f"Error: seq value + 1 does not reach STREAM_COUNT({STREAM_COUNT})")
                        return seq_value
    return 0

if __name__ == "__main__":
    LOG_DIR = sys.argv[1]
    LOG_PREFIX = sys.argv[2]
    STREAM_COUNT = int(sys.argv[3])
    result = check_cam_log_done(LOG_DIR, LOG_PREFIX, STREAM_COUNT)
    sys.exit(result)
    
