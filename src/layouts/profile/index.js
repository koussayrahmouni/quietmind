import React, { useEffect, useState } from "react";
import { Button, TextField } from "@mui/material";
import axios from "axios";
import './components/Welcome/index';
import './profile.css'; // Make sure this imports the updated CSS

const Profile = () => {
  const [user, setUser] = useState(null);
  const [editedUser, setEditedUser] = useState({
    firstName: "",
    lastName: "",
    email: "",
    phone: "",
    role: "",
  });
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [editMode, setEditMode] = useState(false);
  const [successMessage, setSuccessMessage] = useState(null);

  useEffect(() => {
    const fetchUserProfile = async () => {
      try {
        const token = localStorage.getItem("token");
        if (!token) {
          setError("No authentication token found. Please log in.");
          setLoading(false);
          return;
        }
        // Decode token to get user ID
        const decodedToken = JSON.parse(atob(token.split(".")[1]));
        const userId = decodedToken?.user?.id;
        if (!userId) {
          setError("User ID not found in token.");
          setLoading(false);
          return;
        }
        // Fetch user data using axios
        const response = await axios.get(`http://localhost:3000/api/users/${userId}`, {
          headers: { Authorization: `Bearer ${token}` },
        });
        if (response.data.success) {
          setUser(response.data.data);
          setEditedUser({
            firstName: response.data.data.firstName || "",
            lastName: response.data.data.lastName || "",
            email: response.data.data.email || "",
            phone: response.data.data.phone || "",
            role: response.data.data.role || "",
          });
        } else {
          setError(response.data.message || "Failed to fetch user profile.");
        }
      } catch (err) {
        setError(err.message);
      } finally {
        setLoading(false);
      }
    };

    fetchUserProfile();
  }, []);

  const handleLogout = () => {
    localStorage.removeItem("token");
    window.location.href = "/login";
  };

  const handleChange = (e) => {
    const { name, value } = e.target;
    setEditedUser({
      ...editedUser,
      [name]: value,
    });
  };

  const handleUpdate = async () => {
    try {
      const token = localStorage.getItem("token");
      if (!token) {
        setError("No authentication token found. Please log in.");
        return;
      }
      const userId = user?.id;
      if (!userId) {
        setError("User ID not found.");
        return;
      }
      const response = await axios.patch(
        `http://localhost:3000/api/users/${userId}`,
        editedUser,
        { headers: { Authorization: `Bearer ${token}` } }
      );
      if (response.data.success) {
        const updatedUser = response.data.data ? response.data.data : { ...user, ...editedUser };
        setUser(updatedUser);
        setEditMode(false);
        setSuccessMessage("Profile updated successfully!");
        setTimeout(() => {
          setSuccessMessage(null);
        }, 3000);
      } else {
        setError(response.data.message || "Failed to update profile.");
      }
    } catch (err) {
      setError(err.message);
    }
  };

  return (
    <div className="profile-container">
      {loading ? (
        <p className="loading-message">Loading profile...</p>
      ) : error ? (
        <p className="error-message">{error}</p>
      ) : user ? (
        <div className="profile-section">
          <h2>Profile Information</h2>
          {successMessage && <p className="success-message">{successMessage}</p>}
          
          {editMode ? (
            <div className="edit-form">
              <TextField
                label="First Name"
                name="firstName"
                value={editedUser.firstName}
                onChange={handleChange}
                fullWidth
              />
              <TextField
                label="Last Name"
                name="lastName"
                value={editedUser.lastName}
                onChange={handleChange}
                fullWidth
              />
              <TextField
                label="Email"
                name="email"
                value={editedUser.email}
                onChange={handleChange}
                fullWidth
              />
              <TextField
                label="Phone Number"
                name="phone"
                value={editedUser.phone}
                onChange={handleChange}
                fullWidth
              />
              <TextField
                label="Role"
                name="role"
                value={editedUser.role}
                onChange={handleChange}
                fullWidth
              />
              <div className="button-group">
                <Button variant="contained" color="primary" onClick={handleUpdate}>
                  Save Changes
                </Button>
                <Button variant="outlined" onClick={() => setEditMode(false)}>
                  Cancel
                </Button>
              </div>
            </div>
          ) : (
            <div className="profile-display">
              <p><strong>First Name:</strong> {user.firstName || "N/A"}</p>
              <p><strong>Last Name:</strong> {user.lastName || "N/A"}</p>
              <p><strong>Email:</strong> {user.email}</p>
              <p><strong>Phone Number:</strong> {user.phone || "N/A"}</p>
              <p><strong>Role:</strong> {user.role || "N/A"}</p>
              <div className="button-group">
                <Button variant="outlined" onClick={() => setEditMode(true)}>
                  Edit Profile
                </Button>
              </div>
            </div>
          )}
          
          <Button
            variant="contained"
            color="secondary"
            onClick={handleLogout}
            className="logout-button"
          >
            Logout
          </Button>
        </div>
      ) : (
        <p className="loading-message">User data not available.</p>
      )}
    </div>
  );
};

export default Profile;