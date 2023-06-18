import time
import sys

usage = float(sys.argv[1])
sleep_time = 1 - usage

while True:
    start_time = time.time()

    # Use CPU for the specified amount of time
    while time.time() - start_time < usage:
        pass

    # Sleep for the rest of the time
    time.sleep(sleep_time)