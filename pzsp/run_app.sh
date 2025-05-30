#!/bin/bash

cd backend
pip install -r requirements.txt

python3 run.py &
BACKEND_PID=$!


cd ../build/web 
python3 -m http.server 8080 &
WEB_PID=$!

sleep 2

open http://localhost:8080


cleanup() {
  echo "Stopping servers..."
  kill $WEB_PID
  kill $FRONTEND_PID
  exit 0
}

trap cleanup SIGINT SIGTERM

echo "Web server started on http://localhost:8080"
echo "Press Ctrl+C to stop."

while true; do sleep 1; done
