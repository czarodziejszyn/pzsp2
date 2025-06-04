#!/bin/bash

cd backend
pip install -r requirements.txt

pip install -r requirements.txt || {
  echo "pip install failed!"
  exit 1
}

python3 run.py &
BACKEND_PID=$!
sleep 2


cd ..
flutter run -d chrome &
FLUTTER_PID=$!



cleanup() {
  echo "Stopping backend and flutter..."
  kill $BACKEND_PID
  kill $FLUTTER_PID
  exit 0
}

trap cleanup SIGINT SIGTERM

echo "Flutter started with PID $FLUTTER_PID"
echo "Backend started with PID $BACKEND_PID"
echo "Press Ctrl+C to stop."

while true; do sleep 1; done
