from flask import Flask, request, jsonify
import pandas as pd
import joblib
import numpy as np

app = Flask(__name__)

# Load model artifacts at startup
le = joblib.load('model/encoder.pkl')
scaler = joblib.load('model/scaler.pkl')
model = joblib.load('model/svm_model.pkl')
@app.route('/predict', methods=['POST'])
def predict():
    try:
        # Get JSON data from request
        data = request.json
        
        # Create DataFrame from input
        input_data = pd.DataFrame([{
            'bpm': data['bpm'],
            'activite': le.transform([data['activite']])[0],
            'temperature': data['temperature']
        }])
        
        # Scale the features
        scaled_data = scaler.transform(input_data)
        
        # Make prediction
        prediction = model.predict(scaled_data)
        
        # Return response
        return jsonify({
            'prediction': int(prediction[0]),
            'message': '⚠️ Crise' if prediction[0] else '✅ Normal'
        })
    
    except Exception as e:
        return jsonify({'error': str(e)}), 400

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)   
    