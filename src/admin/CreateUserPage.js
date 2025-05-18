import React, { useState } from 'react';
import axios from 'axios';
import { useHistory } from 'react-router-dom';
import './CreateUserPage.css';
import 'bootstrap/dist/css/bootstrap.min.css';
const CreateUserPage = () => {
    const [firstName, setFirstName] = useState('');
    const [lastName, setLastName] = useState('');
    const [email, setEmail] = useState('');
    const [role, setRole] = useState('');
    const [phone, setPhone] = useState('');
    const [password, setPassword] = useState('');
    const [status, setStatus] = useState('');

    const history = useHistory();

    const handleSubmit = async (e) => {
        e.preventDefault();

        const userData = { firstName, lastName, email, role, phone, password };

        try {
            const token = localStorage.getItem('token');

            const response = await axios.post(
                'http://localhost:3000/api/users/',
                userData,
                {
                    headers: { Authorization: `Bearer ${token}` }
                }
            );

            setStatus('✅ User created successfully. Please check your email.');
            setFirstName('');
            setLastName('');
            setEmail('');
            setRole('');
            setPhone('');
            setPassword('');
        } catch (error) {
            setStatus(error.response?.data?.message || '❌ An error occurred.');
        }
    };

  

    return (
<div className="create-user-page-container">
    <div className="create-user-form-container">
        <h2>Create New Caregiver</h2>
        <form onSubmit={handleSubmit}>
            <div className="create-user-form-group">
                <input
                    type="text"
                    placeholder="First Name"
                    value={firstName}
                    onChange={(e) => setFirstName(e.target.value)}
                    required
                />
            </div>
            <div className="create-user-form-group">
                <input
                    type="text"
                    placeholder="Last Name"
                    value={lastName}
                    onChange={(e) => setLastName(e.target.value)}
                    required
                />
            </div>
            <div className="create-user-form-group">
                <input
                    type="email"
                    placeholder="Email"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    required
                />
            </div>
            <div className="create-user-form-group">
                <input
                    type="text"
                    placeholder="Role"
                    value={role}
                    onChange={(e) => setRole(e.target.value)}
                    required
                />
            </div>
            <div className="create-user-form-group">
                <input
                    type="text"
                    placeholder="Phone"
                    value={phone}
                    onChange={(e) => setPhone(e.target.value)}
                    required
                />
            </div>
            <div className="create-user-form-group">
                <input
                    type="password"
                    placeholder="Password"
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    required
                />
            </div>
            <div className="create-user-submit-container">
                <button type="submit" className="create-user-submit-btn">Create User</button>
            </div>
        </form>

        {status && (
            <p className={`create-user-status-message ${status.startsWith('✅') ? 'success' : 'error'}`}>
                {status}
            </p>
        )}
    </div>
</div>);
};

export default CreateUserPage;
