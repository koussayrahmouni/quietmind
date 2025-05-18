import face_recognition
import cv2
import os
import json
import time
from deepface import DeepFace
import sys

# Configure paths
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
KNOWN_FACES_DIR = r"C:\Users\koussay\Desktop\TP0\chappiPidev\utils\ml\known_faces"


# Load known faces
known_encodings = []
known_names = []

print(json.dumps({"status": "Initializing face recognition..."}), flush=True)

if not os.path.exists(KNOWN_FACES_DIR):
    print(json.dumps({"error": f"Known faces directory not found: {KNOWN_FACES_DIR}"}), flush=True)
    sys.exit(1)

for filename in os.listdir(KNOWN_FACES_DIR):
    if filename.lower().endswith((".jpg", ".png")):
        image_path = os.path.join(KNOWN_FACES_DIR, filename)
        image = face_recognition.load_image_file(image_path)
        encodings = face_recognition.face_encodings(image)
        
        if encodings:
            known_encodings.append(encodings[0])
            known_names.append(os.path.splitext(filename)[0])

print(json.dumps({"status": f"Loaded {len(known_names)} known faces"}), flush=True)

# Initialize camera
camera = cv2.VideoCapture(1, cv2.CAP_DSHOW)  # Try 0 if 1 doesn't work
if not camera.isOpened():
    print(json.dumps({"error": "Failed to open camera"}), flush=True)
    sys.exit(1)

print(json.dumps({"status": "Camera initialized"}), flush=True)

last_sent_time = 0  # Place this before the loop

try:
    while True:
        ret, frame = camera.read()
        if not ret:
            print(json.dumps({"error": "Frame capture failed"}), flush=True)
            break

        small_frame = cv2.resize(frame, (0, 0), fx=0.25, fy=0.25)
        rgb_small = cv2.cvtColor(small_frame, cv2.COLOR_BGR2RGB)

        face_locations = face_recognition.face_locations(rgb_small)
        face_encodings = face_recognition.face_encodings(rgb_small, face_locations)

        for (top, right, bottom, left), face_encoding in zip(face_locations, face_encodings):
            top *= 4
            right *= 4
            bottom *= 4
            left *= 4

            matches = face_recognition.compare_faces(known_encodings, face_encoding, tolerance=0.5)
            name = "Unknown"
            if True in matches:
                name = known_names[matches.index(True)]

            try:
                face_roi = frame[top:bottom, left:right]
                if face_roi.size == 0:
                    continue
                    
                analysis = DeepFace.analyze(face_roi, actions=['emotion'], enforce_detection=False)
                emotion = analysis[0]['dominant_emotion']
            except Exception as e:
                emotion = "neutral"

            current_time = time.time()
            if current_time - last_sent_time >= 5:
                detection = {
                    "name": name,
                    "emotion": emotion,
                    "timestamp": int(current_time * 1000)
                }
                print(json.dumps(detection), flush=True)
                last_sent_time = current_time

        time.sleep(0.1)

except KeyboardInterrupt:
    pass
finally:
    camera.release()
    print(json.dumps({"status": "Camera released"}), flush=True)