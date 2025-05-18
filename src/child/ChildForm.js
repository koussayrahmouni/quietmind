import React, { useState } from 'react';
import axios from 'axios';
import { useHistory } from 'react-router-dom';
import "./ChildForm.css"; // Make sure to update styles if needed
import 'bootstrap/dist/css/bootstrap.min.css';

const ChildForm = () => {
    const [firstName, setFirstName] = useState('');
    const [lastName, setLastName] = useState('');
    const [age, setAge] = useState('');
    const [gender, setGender] = useState('');
    const [autonomyLevel, setAutonomyLevel] = useState('');
    const [sensoryPreferences, setSensoryPreferences] = useState('');
    const [favoriteInterests, setFavoriteInterests] = useState('');
    const [modeOfCommunication, setModeOfCommunication] = useState('');
    const [calmingStrategies, setCalmingStrategies] = useState('');
    const [allergiesOrDietaryRestrictions, setAllergiesOrDietaryRestrictions] = useState('');
    const [parentId, setParentId] = useState('');
    const [status, setStatus] = useState('');

    const history = useHistory();

    const handleSubmit = async (e) => {
        e.preventDefault();

        const childData = { 
            FirstName: firstName, 
            LastName: lastName, 
            Age: age, 
            Gender: gender, 
            AutonomyLevel: autonomyLevel,
            SensoryPreferences: sensoryPreferences,
            FavoriteInterests: favoriteInterests,
            ModeOfCommunication: modeOfCommunication,
            CalmingStrategies: calmingStrategies,
            AllergiesOrDietaryRestrictions: allergiesOrDietaryRestrictions,
            parent_id: parentId
        };

        try {
            const token = localStorage.getItem('token');

            const response = await axios.post(
                'http://localhost:3000/api/children/', // Update URL according to backend routing
                childData,
                {
                    headers: { Authorization: `Bearer ${token}` }
                }
            );

            setStatus('✅ Child created successfully!');
            setFirstName('');
            setLastName('');
            setAge('');
            setGender('');
            setAutonomyLevel('');
            setSensoryPreferences('');
            setFavoriteInterests('');
            setModeOfCommunication('');
            setCalmingStrategies('');
            setAllergiesOrDietaryRestrictions('');
            setParentId('');
        } catch (error) {
            setStatus(error.response?.data?.message || '❌ An error occurred.');
        }
    };

    return (
        <div className="container">
        <div className="form-container">
            <h2>Create New Child</h2>
            <form onSubmit={handleSubmit}>
                <div className="form-group">
                    <input
                        type="text"
                        placeholder="First Name"
                        value={firstName}
                        onChange={(e) => setFirstName(e.target.value)}
                        required
                    />
                </div>
                <div className="form-group">
                    <input
                        type="text"
                        placeholder="Last Name"
                        value={lastName}
                        onChange={(e) => setLastName(e.target.value)}
                        required
                    />
                </div>
                <div className="form-group">
                    <input
                        type="number"
                        placeholder="Age"
                        value={age}
                        onChange={(e) => setAge(e.target.value)}
                        required
                    />
                </div>
                <div className="form-group">
                    <input
                        type="text"
                        placeholder="Gender"
                        value={gender}
                        onChange={(e) => setGender(e.target.value)}
                        required
                    />
                </div>
                <div className="form-group">
                    <input
                        type="text"
                        placeholder="Autonomy Level"
                        value={autonomyLevel}
                        onChange={(e) => setAutonomyLevel(e.target.value)}
                        required
                    />
                </div>
                <div className="form-group">
                    <input
                        type="text"
                        placeholder="Sensory Preferences"
                        value={sensoryPreferences}
                        onChange={(e) => setSensoryPreferences(e.target.value)}
                        required
                    />
                </div>
                <div className="form-group">
                    <input
                        type="text"
                        placeholder="Favorite Interests"
                        value={favoriteInterests}
                        onChange={(e) => setFavoriteInterests(e.target.value)}
                        required
                    />
                </div>
                <div className="form-group">
                    <input
                        type="text"
                        placeholder="Mode of Communication"
                        value={modeOfCommunication}
                        onChange={(e) => setModeOfCommunication(e.target.value)}
                        required
                    />
                </div>
                <div className="form-group">
                    <input
                        type="text"
                        placeholder="Calming Strategies"
                        value={calmingStrategies}
                        onChange={(e) => setCalmingStrategies(e.target.value)}
                        required
                    />
                </div>
                <div className="form-group">
                    <input
                        type="text"
                        placeholder="Allergies or Dietary Restrictions"
                        value={allergiesOrDietaryRestrictions}
                        onChange={(e) => setAllergiesOrDietaryRestrictions(e.target.value)}
                        required
                    />
                </div>
                <button type="submit" className="submit-btn">Create Child</button>
            </form>
    
            {status && <p className={`status-message ${status.startsWith('✅') ? 'success' : 'error'}`}>{status}</p>}
        </div>
    </div>
    );
};

export default ChildForm;
