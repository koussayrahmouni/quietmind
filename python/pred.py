import sys
import json
import os
import pandas as pd
import joblib
from sklearn.preprocessing import LabelEncoder, StandardScaler
from sklearn.svm import SVC

# Répertoires de base
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SCRIPTS_DIR = os.path.join(BASE_DIR, "python", "scripts")
MODEL_DIR = os.path.join(BASE_DIR, "model")

# Helper pour logs de debug vers stderr
def log(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)


def train_and_save_models():
    log("Training models...")
    df = pd.read_csv(os.path.join(SCRIPTS_DIR, "bpm_crise.csv"))
    le = LabelEncoder()
    df["activite"] = le.fit_transform(df["activite"])
    X = df[["bpm", "activite", "temperature"]]
    y = df["crise"]
    scaler = StandardScaler()
    X_scaled = scaler.fit_transform(X)
    svm_model = SVC(kernel="rbf", probability=True)
    svm_model.fit(X_scaled, y)

    os.makedirs(MODEL_DIR, exist_ok=True)
    joblib.dump(le, os.path.join(MODEL_DIR, "encoder.pkl"))
    joblib.dump(scaler, os.path.join(MODEL_DIR, "scaler.pkl"))
    joblib.dump(svm_model, os.path.join(MODEL_DIR, "model.pkl"))
    log("Models trained and saved.")
    return le, scaler, svm_model


def load_models():
    try:
        log("Loading models...")
        le = joblib.load(os.path.join(MODEL_DIR, "encoder.pkl"))
        scaler = joblib.load(os.path.join(MODEL_DIR, "scaler.pkl"))
        model = joblib.load(os.path.join(MODEL_DIR, "model.pkl"))
        log("Models loaded successfully.")
        return le, scaler, model
    except Exception as e:
        log("Model load failed, training new models:", e)
        return train_and_save_models()


def predict(input_data):
    log("Received input data:", input_data)
    le, scaler, model = load_models()

    try:
        encoded_act = le.transform([input_data["activite"]])[0]
        log("Encoded activity:", encoded_act)
    except Exception as e:
        log("Error during activity encoding:", e)
        return {"error": "Activity encoding failed"}

    df = pd.DataFrame([{
        "bpm": input_data["bpm"],
        "activite": encoded_act,
        "temperature": input_data["temperature"]
    }])

    try:
        X_scaled = scaler.transform(df)
        pred = model.predict(X_scaled)[0]
        proba = model.predict_proba(X_scaled)[0][1]
        result = {
            "prediction": int(pred),
            "probability": float(proba),
            "message": "Crise" if pred else "Normal"
        }
        log("Prediction result:", result)
        return result
    except Exception as e:
        log("Error during prediction:", e)
        return {"error": "Prediction failed"}


if __name__ == "__main__":
    try:
        if len(sys.argv) > 1:
            data = json.loads(sys.argv[1])
            output = predict(data)
            # Seul output JSON sur stdout
            print(json.dumps(output))
        else:
            test_data = {"bpm": 80, "activite": "Repos", "temperature": 37}
            output = predict(test_data)
            print(json.dumps(output))
    except Exception as e:
        log("Error during prediction:", str(e))
        sys.exit(1)