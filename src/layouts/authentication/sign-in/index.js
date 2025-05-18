import React, { useState } from 'react';
import axios from 'axios';
import { useHistory } from 'react-router-dom';
// Vision UI Dashboard React components
import VuiBox from "components/VuiBox";
import VuiTypography from "components/VuiTypography";
import VuiInput from "components/VuiInput";
import VuiButton from "components/VuiButton";
import VuiSwitch from "components/VuiSwitch";
import GradientBorder from "examples/GradientBorder";
import './LoginPage.css';
// Vision UI Dashboard assets
import radialGradient from "assets/theme/functions/radialGradient";
import palette from "assets/theme/base/colors";
import borders from "assets/theme/base/borders";

// Authentication layout components
import CoverLayout from "layouts/authentication/components/CoverLayout";

// Images
import bgSignIn from "assets/images/signInImage.png";
const LoginPage = () => {
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [status, setStatus] = useState('');
    const history = useHistory();

    const handleLogin = async (e) => {
        e.preventDefault();
        try {
            const response = await axios.post('http://localhost:3000/api/users/login', {
                email,
                password,
            });

            const { token } = response.data; // Extract token from response

            if (token) {
                localStorage.setItem('token', token); // Store token in localStorage
                setStatus('✅ Login successful!');
                setTimeout(() => {
                    history.push('/profile'); // Redirect after successful login
                }, 1500);
            }
        } catch (error) {
            setStatus(error.response?.data?.message || '❌ Invalid email or password.');
        }
    };
    
    return (
        
        <CoverLayout
    title="Nice to see you!"
    color="white"
    description="Enter your email and password to sign in"
    premotto="INSPIRED BY THE FUTURE:"
    motto="FOR A BETTER LIFE TO OUR CHILDREN"
    image={bgSignIn}
    className="login-page-background" // Add this class for background animation
>
    <VuiBox component="form" role="form" onSubmit={handleLogin} className="login-form-container">
        <VuiBox mb={2}>
            <VuiTypography component="label" variant="button" color="white" fontWeight="medium">
                Email
            </VuiTypography>
            <GradientBorder
                minWidth="100%"
                padding="1px"
                borderRadius={borders.borderRadius.lg}
                backgroundImage={radialGradient(palette.gradients.borderLight.main, palette.gradients.borderLight.state, palette.gradients.borderLight.angle)}
                className="gradient-border-animation" // Add this class for gradient animation
            >
                <VuiInput
                    type="email"
                    placeholder="Your email..."
                    fontWeight="500"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    required
                    className="login-input" // Add this class for input styling
                />
            </GradientBorder>
        </VuiBox>
        <VuiBox mb={2}>
            <VuiTypography component="label" variant="button" color="white" fontWeight="medium">
                Password
            </VuiTypography>
            <GradientBorder
                minWidth="100%"
                borderRadius={borders.borderRadius.lg}
                padding="1px"
                backgroundImage={radialGradient(palette.gradients.borderLight.main, palette.gradients.borderLight.state, palette.gradients.borderLight.angle)}
                className="gradient-border-animation" // Add this class for gradient animation
            >
                <VuiInput
                    type="password"
                    placeholder="Your password..."
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    required
                    className="login-input" // Add this class for input styling
                />
            </GradientBorder>
        </VuiBox>
        <VuiBox mt={4} mb={1}>
            <VuiButton color="info" fullWidth type="submit" className="login-button">
                LOGIN
            </VuiButton>
        </VuiBox>
        <VuiBox mt={2} textAlign="center">
            <VuiTypography variant="button" color="white">
                Don't have an account? 
                <VuiButton color="info" variant="text" onClick={() => history.push('/admin/SignUpPage')} className="sign-up-link">
                    Sign Up
                </VuiButton>
            </VuiTypography>
        </VuiBox>
        {status && (
            <VuiTypography
                variant="button"
                color={status.includes('✅') ? "success" : "error"}
                fontWeight="bold"
                textAlign="center"
                mt={2}
                className={`status-message ${status.includes('✅') ? 'success' : 'error'}`} // Add this class for status message styling
            >
                {status}
            </VuiTypography>
        )}
    </VuiBox>
</CoverLayout>);

};

export default LoginPage;
