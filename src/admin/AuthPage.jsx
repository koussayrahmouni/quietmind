// AuthPage.jsx
import React, { useState } from 'react';
import axios from 'axios';
import './style.css'; // Import the CSS from your HTML/CSS files
import { signUp } from 'services/userService';
// If needed, import Boxicons (or include via index.html) for the icons

const AuthPage = () => {
  // "active" state controls whether the container shows the Register form (active=true)
  // or the Login form (active=false)
  const [active, setActive] = useState(false);

  // States for login form
  const [loginData, setLoginData] = useState({
    email: '',
    password: '',
  });

  // States for register form
  const [signupData, setSignupData] = useState({
    username: '',
    email: '',
    password: '',
  });

  // A common status message (could be success or error)
  const [status, setStatus] = useState('');

  // Handle login form submission
  const handleLoginSubmit = async (e) => {
    e.preventDefault();
    setStatus('');
    try {
      const response = await axios.post('http://localhost:3000/api/users/login', {
        email: loginData.email,
        password: loginData.password,
      });
      const { token } = response.data;
      if (token) {
        localStorage.setItem('token', token);
        setStatus('✅ Login successful!');
        // Redirect as needed (for example, using react-router)
      }
    } catch (error) {
      setStatus(error.response?.data?.message || '❌ Invalid email or password.');
    }
  };

  // Handle signup form submission
  const handleSignupSubmit = async (e) => {
    e.preventDefault();
    setStatus('');
    try {
      const response = await axios.post('http://localhost:3000/api/users/signup', {
        username: signupData.username,
        email: signupData.email,
        password: signupData.password,
      });
      if (response.data.success) {
        setStatus(`✅ ${response.data.message}`);
        // Optionally switch back to login view after successful signup:
        setTimeout(() => setActive(false), 2000);
      } else {
        setStatus(`❌ ${response.data.message}`);
      }
    } catch (error) {
      setStatus("❌ An error occurred during signup. Please try again later.");
    }
  };

  return (
    <div className={`container ${active ? 'active' : ''}`}>
      {/* Curved background shapes */}
      <div className="curved-shape"></div>
      <div className="curved-shape2"></div>

      {/* -------- LOGIN FORM -------- */}
      <div className="form-box Login">
        <h2 className="animation" style={{ "--D": 0, "--S": 21 }}>Login</h2>
        <form onSubmit={handleLoginSubmit}>
          <div className="input-box animation" style={{ "--D": 1, "--S": 22 }}>
            <input
              type="text"
              required
              value={loginData.email}
              onChange={(e) =>
                setLoginData({ ...loginData, email: e.target.value })
              }
            />
            <label>Username / Email</label>
            {/* Optionally add an icon: 
                <box-icon type='solid' name='user'></box-icon>
            */}
          </div>

          <div className="input-box animation" style={{ "--D": 2, "--S": 23 }}>
            <input
              type="password"
              required
              value={loginData.password}
              onChange={(e) =>
                setLoginData({ ...loginData, password: e.target.value })
              }
            />
            <label>Password</label>
            {/* Optionally add an icon:
                <box-icon name='lock-alt' type='solid'></box-icon>
            */}
          </div>

          <div className="input-box animation" style={{ "--D": 3, "--S": 24 }}>
            <button className="btn" type="submit">Login</button>
          </div>

          <div className="regi-link animation" style={{ "--D": 4, "--S": 25 }}>
            <p>
              Don't have an account? <br />
              <a
                href="#"
                className="SignUpLink"
                onClick={(e) => {
                  e.preventDefault();
                  setActive(true);
                }}
              >
                Sign Up
              </a>
            </p>
          </div>
        </form>
      </div>

      <div className="info-content Login">
        <h2 className="animation" style={{ "--D": 0, "--S": 20 }}>WELCOME BACK!</h2>
        <p className="animation" style={{ "--D": 1, "--S": 21 }}>
          We are happy to have you with us again. If you need anything, we are here to help.
        </p>
      </div>

      {/* -------- REGISTER FORM -------- */}
      <div className="form-box Register">
        <h2 className="animation" style={{ "--li": 17, "--S": 0 }}>Register</h2>
        <form onSubmit={handleSignupSubmit}>
          <div className="input-box animation" style={{ "--li": 18, "--S": 1 }}>
            <input
              type="text"
              required
              value={signupData.username}
              onChange={(e) =>
                setSignupData({ ...signupData, username: e.target.value })
              }
            />
            <label>Username</label>
            {/* Optionally add an icon */}
          </div>

          <div className="input-box animation" style={{ "--li": 19, "--S": 2 }}>
            <input
              type="email"
              required
              value={signupData.email}
              onChange={(e) =>
                setSignupData({ ...signupData, email: e.target.value })
              }
            />
            <label>Email</label>
            {/* Optionally add an icon */}
          </div>

          <div className="input-box animation" style={{ "--li": 19, "--S": 3 }}>
            <input
              type="password"
              required
              value={signupData.password}
              onChange={(e) =>
                setSignupData({ ...signupData, password: e.target.value })
              }
            />
            <label>Password</label>
            {/* Optionally add an icon */}
          </div>

          <div className="input-box animation" style={{ "--li": 20, "--S": 4 }}>
            <button className="btn" type="submit">Register</button>
          </div>

          <div className="regi-link animation" style={{ "--li": 21, "--S": 5 }}>
            <p>
              Already have an account? <br />
              <a
                href="#"
                className="SignInLink"
                onClick={(e) => {
                  e.preventDefault();
                  setActive(false);
                }}
              >
                Sign In
              </a>
            </p>
          </div>
        </form>
      </div>

      <div className="info-content Register">
        <h2 className="animation" style={{ "--li": 17, "--S": 0 }}>WELCOME!</h2>
        <p className="animation" style={{ "--li": 18, "--S": 1 }}>
          We’re delighted to have you here. If you need any assistance, feel free to reach out.
        </p>
      </div>

      {/* Optionally display a status message */}
      {status && <div className="status">{status}</div>}
    </div>
  );
};

export default AuthPage;