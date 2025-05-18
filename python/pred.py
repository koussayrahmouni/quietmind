import sys
import json
import pandas as pd
from sklearn.preprocessing import LabelEncoder, StandardScaler
from sklearn.svm import SVC
import joblib
import os

# Constants
MODEL_DIR = "model"
os.makedirs(MODEL_DIR, exist_ok=True)

def train_and_save_models():
    """Train models and save artifacts if they don't exist"""
    # Load and preprocess data
    df = pd.read_csv("scripts/bpm_crise.csv")
    
    # Encode activity
    le = LabelEncoder()
    df['activite'] = le.fit_transform(df['activite'])  # Repos=2, Stress=1, Marche=0
    
    # Prepare features
    X = df[['bpm', 'activite', 'temperature']]
    y = df['crise']
    
    # Scale features
    scaler = StandardScaler()
    X_scaled = scaler.fit_transform(X)
    
    # Train SVM model (primary model)
    svm_model = SVC(kernel='rbf', probability=True)
    svm_model.fit(X_scaled, y)
    
    # Save artifacts
    joblib.dump(le, f'{MODEL_DIR}/encoder.pkl')
    joblib.dump(scaler, f'{MODEL_DIR}/scaler.pkl')
    joblib.dump(svm_model, f'{MODEL_DIR}/model.pkl')
    
    return le, scaler, svm_model

def load_models():
    """Load pre-trained models"""
    try:
        return (
            joblib.load(f'{MODEL_DIR}/encoder.pkl'),
            joblib.load(f'{MODEL_DIR}/scaler.pkl'), 
            joblib.load(f'{MODEL_DIR}/model.pkl')
        )
    except:
        return train_and_save_models()

# Main prediction function
def predict(input_data):
    """Make prediction for input data"""
    le, scaler, model = load_models()
    
    # Prepare input DataFrame
    input_df = pd.DataFrame([{
        'bpm': input_data['bpm'],
        'activite': le.transform([input_data['activite']])[0],
        'temperature': input_data['temperature']
    }])
    
    # Scale and predict
    scaled_data = scaler.transform(input_df)
    prediction = model.predict(scaled_data)[0]
    probability = model.predict_proba(scaled_data)[0][1]  # Probability of crisis
    
    return {
        'prediction': int(prediction),
        'probability': float(probability),
        'message': '⚠️ Crise' if prediction else '✅ Normal'
    }

# Handle command line execution
if __name__ == "__main__":
    # If called from Node.js via python-shell
    if len(sys.argv) > 1:
        input_data = json.loads(sys.argv[1])
        result = predict(input_data)
        print(json.dumps(result))
    
    # If run directly (for testing)
    else:
        # Example prediction when run directly
        test_data = {
            'bpm': 80,
            'activite': 'Repos',
            'temperature': 37
        }
        print("Test prediction:", predict(test_data))
        
        # Train and save models if they don't exist
        train_and_save_models()
        print("Models trained and saved successfully")