import React, { useState } from 'react';
import axios from 'axios';
import { useHistory } from 'react-router-dom';

const SignUpPage = () => {
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [firstName, setFirstName] = useState('');
    const [lastName, setLastName] = useState('');
    const [role, setRole] = useState('parents');
    const [status, setStatus] = useState('');
    const history = useHistory();

    const handleSignUp = async (e) => {
        e.preventDefault();
        try {
            const response = await axios.post('localhost:3000/users/signup', {
                email,
                password,
                firstName,
                lastName,
                role,
            });
            setStatus(response.data.message);
            history.push('/login'); // Redirect to login page after successful signup
        } catch (error) {
            setStatus(error.response?.data?.message || 'Something went wrong.');
        }
    };

    return (
        <div style={{ padding: '20px' }}>
            <h2>Sign Up</h2>

            <form onSubmit={handleSignUp}>
                <div>
                    <label>Email:</label>
                    <input
                        type="email"
                        value={email}
                        onChange={(e) => setEmail(e.target.value)}
                        required
                    />
                </div>
                <div>
                    <label>First Name:</label>
                    <input
                        type="text"
                        value={firstName}
                        onChange={(e) => setFirstName(e.target.value)}
                        required
                    />
                </div>
                <div>
                    <label>Last Name:</label>
                    <input
                        type="text"
                        value={lastName}
                        onChange={(e) => setLastName(e.target.value)}
                        required
                    />
                </div>
                <div>
                    <label>Role:</label>
                    <input
                        type="text"
                        value={role}
                        onChange={(e) => setRole(e.target.value)}
                        required
                    />
                </div>
                <div>
                    <button type="submit">Sign Up</button>
                </div>
            </form>

            {status && <p>{status}</p>}
        </div>
    );
};

export default SignUpPage;
