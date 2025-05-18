// src/services/userService.js
import axios from 'axios';

const API_URL = 'http://localhost:3000/api/users';

// Sign up function
export const signUp = async (userData) => {
    try {
        const response = await axios.post(`${API_URL}/signup`, userData);
        return response.data;
    } catch (error) {
        throw error.response ? error.response.data : { message: 'Server Error' };
    }
};

// You can add other methods like login, getUser, etc.
