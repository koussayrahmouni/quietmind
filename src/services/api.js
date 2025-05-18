import axios from "axios"

const API_URL = "http://localhost:3005/api/child"

export const addChild = async (childData) => {
  try {
    const response = await axios.post(API_URL, childData)
    return response.data
  } catch (error) {
    console.error("Erreur lors de l'ajout de l'enfant :", error.response?.data || error.message)
    throw error
  }
}

export const getChildren = async () => {
  try {
    const response = await axios.get(API_URL)
    return response.data
  } catch (error) {
    console.error("Erreur lors de la récupération des enfants :", error.response?.data || error.message)
    throw error
  }
}

export const getChildById = async (id) => {
  try {
    const response = await axios.get(`${API_URL}/${id}`)
    return response.data
  } catch (error) {
    console.error("Erreur lors de la récupération de l'enfant :", error.response?.data || error.message)
    throw error
  }
}

export const updateChild = async (id, childData) => {
  try {
    const response = await axios.put(`${API_URL}/${id}`, childData)
    return response.data
  } catch (error) {
    console.error("Erreur lors de la mise à jour de l'enfant :", error.response?.data || error.message)
    throw error
  }
}
export const updateChildGeneral = async (id, parentId, childData) => {
  try {
    const response = await axios.put(`${API_URL}/${id}/${parentId}`, childData);
    return response.data;
  } catch (error) {
    console.error("Erreur lors de la mise à jour de l'enfant :", error.response?.data || error.message);
    throw error;
  }
};

export const deleteChild = async (id) => {
  try {
    const response = await axios.delete(`${API_URL}/${id}`)
    return response.data
  } catch (error) {
    console.error("Erreur lors de la suppression de l'enfant :", error.response?.data || error.message)
    throw error
  }
}

