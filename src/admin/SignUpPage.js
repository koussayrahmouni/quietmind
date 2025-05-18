import { useState } from "react";
import { useHistory } from "react-router-dom";
import axios from "axios";
import VuiBox from "components/VuiBox";
import VuiTypography from "components/VuiTypography";
import VuiInput from "components/VuiInput";
import VuiButton from "components/VuiButton";
import GradientBorder from "examples/GradientBorder";
import radialGradient from "assets/theme/functions/radialGradient";
import palette from "assets/theme/base/colors";
import borders from "assets/theme/base/borders";
import CoverLayout from "layouts/authentication/components/CoverLayout";
import bgSignUp from "assets/images/signUpImage.png";
import './SignUp.css';
function SignUp() {
    const [formData, setFormData] = useState({
        firstName: '',
        lastName: '',
        email: '',
        phone: '',
        password: '',
    });
    const [errors, setErrors] = useState({});
    const [status, setStatus] = useState('');
    const history = useHistory();

    const handleChange = (e) => {
        const { name, value } = e.target;
        setFormData({ ...formData, [name]: value });
    };

    const validateForm = () => {
        const validationErrors = {};
        if (!formData.firstName) validationErrors.firstName = "First name is required";
        if (!formData.lastName) validationErrors.lastName = "Last name is required";
        if (!formData.email) validationErrors.email = "Email is required";
        if (!formData.phone) validationErrors.phone = "Phone number is required";
        if (!formData.password) validationErrors.password = "Password is required";
        setErrors(validationErrors);
        return Object.keys(validationErrors).length === 0;
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        if (!validateForm()) return;
        setStatus('');
        try {
            const response = await axios.post('http://localhost:3000/api/users/signup', formData);
            if (response.data.success === 1) {
                setStatus(`✅ ${response.data.message}`);
                setTimeout(() => history.push('/authentication/sign-in'), 2000);
            } else {
                setStatus(`❌ ${response.data.message}`);
            }
        } catch (error) {
            setStatus("❌ An error occurred during signup. Please try again later.");
        }
    };

    return (
        <CoverLayout
        title="Create an Account"
        description="Fill in the details to sign up"
        image={bgSignUp}
        color="white"
        premotto="INSPIRED BY THE FUTURE"
        motto="FOR A BETTER LIFE TO OUR CHILDREN"
        className="sign-up-page-background" // Add this class for background animation
    >
        <VuiBox component="form" role="form" onSubmit={handleSubmit} className="sign-up-form-container">
            {Object.entries(formData).map(([key, value]) => (
                <VuiBox mb={2} key={key}>
                    <VuiTypography component="label" variant="button" color="white" fontWeight="medium">
                        {key.charAt(0).toUpperCase() + key.slice(1)}
                    </VuiTypography>
                    <GradientBorder
                        minWidth="100%"
                        padding="1px"
                        borderRadius={borders.borderRadius.lg}
                        backgroundImage={radialGradient(palette.gradients.borderLight.main, palette.gradients.borderLight.state, palette.gradients.borderLight.angle)}
                        className="gradient-border-animation" // Add this class for gradient animation
                    >
                        <VuiInput
                            type={key === "password" ? "password" : "text"}
                            placeholder={`Your ${key}...`}
                            name={key}
                            value={value}
                            onChange={handleChange}
                            required
                            className="sign-up-input" // Add this class for input styling
                        />
                    </GradientBorder>
                    {errors[key] && (
                        <VuiTypography variant="caption" color="error" fontWeight="bold">
                            {errors[key]}
                        </VuiTypography>
                    )}
                </VuiBox>
            ))}
            <VuiBox mt={4} mb={1}>
                <VuiButton color="info" fullWidth type="submit" className="sign-up-button">
                    SIGN UP
                </VuiButton>
            </VuiBox>
            <VuiBox mt={2} textAlign="center">
                <VuiTypography variant="button" color="white">
                    Already have an account?
                    <VuiButton color="info" variant="text" onClick={() => history.push('/authentication/sign-in')} className="sign-in-link">
                        Sign In
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
}

export default SignUp;








