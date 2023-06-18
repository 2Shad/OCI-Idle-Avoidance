#!/bin/bash

RED='\033[0;31m'      # For errors or important actions
GREEN='\033[0;32m'    # For successful actions
YELLOW='\033[0;33m'   # For information
NC='\033[0m'          # No Color

# Check if sysstat package is installed
if ! command -v mpstat &> /dev/null
then
    echo -e "${RED}sysstat could not be found. Install it with 'sudo apt-get install sysstat'${NC}"
    exit
fi

load_pids=()

# Function to stop child processes and exit
function cleanup {
    echo -e "${RED}Stopping load generators and exiting...${NC}"
    for pid in "${load_pids[@]}"; do
        kill $pid
    done
    exit
}

# Catch interrupt signal (Ctrl+C) and terminate signal
trap cleanup SIGINT SIGTERM

while true; do
    output=$(mpstat -P ALL 5 1)
    avg_usage=$(echo "$output" | awk '/Average:/ && $2 ~ /[0-9]/ {total+=$NF; count++} END {print 100 - total/count}')
    echo -e "${YELLOW}Average CPU Usage: $avg_usage%. Current number of load generators: ${#load_pids[@]}${NC}"

    if (( $(echo "$avg_usage < 12.0" | bc -l) )); then
        echo -e "${GREEN}CPU usage is below 12%, starting additional load generators...${NC}"
        for i in {1..5}; do
            python3 load_generator.py 0.01 & load_pid=$!
            load_pids+=($load_pid)
        done
    elif (( $(echo "$avg_usage >= 12.0 && $avg_usage < 15.0" | bc -l) )); then
        echo -e "${GREEN}CPU usage is below 15%, starting additional load generator...${NC}"
        python3 load_generator.py 0.01 & load_pid=$!
        load_pids+=($load_pid)
    elif (( $(echo "$avg_usage > 20.0" | bc -l) )); then
        if (( ${#load_pids[@]} > 0 )); then
            echo -e "${RED}CPU usage is above 20%, stopping one load generator...${NC}"
            kill ${load_pids[-1]} # kill the last load generator
            unset 'load_pids[${#load_pids[@]}-1]' # remove it from the array
        else
            echo -e "${RED}CPU usage is above 20%, no load generators are running...${NC}"
        fi
    elif (( $(echo "$avg_usage > 80.0" | bc -l) )); then
        if (( ${#load_pids[@]} > 0 )); then
            echo -e "${RED}CPU usage is above 80%, stopping all load generators...${NC}"
            for pid in "${load_pids[@]}"; do
                kill $pid
            done
            load_pids=()
            echo -e "${GREEN}Current number of load generators: 0${NC}"
        else
            echo -e "${RED}CPU usage is above 80%, no load generators are running...${NC}"
        fi
    fi
    sleep 5
done
