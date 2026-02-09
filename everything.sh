#!/bin/bash

# Define Paths
SERVER_PATH="/home/ewacku/Desktop/Joana/Server/Server/"
PLAYIT_PATH="/home/ewacku/Desktop/Joana/Server/playit-linux-amd64"
CLIENT_PATH="/home/ewacku/Desktop/Joana/Client/JorgeXD/"

echo "1. Starting Playit Tunnel..."
# Start playit in a new window
konsole --noclose -e "$PLAYIT_PATH" &

echo "Waiting 20 seconds for tunnel to stabilize..."
sleep 15

echo "2. Launching LÖVE Server..."
konsole --noclose -e love "$SERVER_PATH" &

echo "3. Launching LÖVE Client..."
konsole --noclose -e love "$CLIENT_PATH" &

echo "Done! Environment is ready."
