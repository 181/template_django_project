#!/bin/bash

PORT=8000

# Check if port is in use
PID=$(lsof -t -i:$PORT)
if [ -n "$PID" ]; then
  echo "Port $PORT is in use by PID $PID. Killing..."
  kill -9 $PID
else
  echo "Port $PORT is free."
fi

# Run Django server
echo "Starting Django server on port $PORT..."
python3 manage.py runserver $PORT

# save this file under root directory of your Django project
# then change permissions of this file using command "chmod +x runserver.sh" (done)
# then run this file using command "./runserver.sh", instead of "python3 manage.py runserver"