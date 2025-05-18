import { useState, useEffect } from "react";
import { useParams, useHistory } from "react-router-dom";
import { getChildById, updateChildGeneral } from "../services/api";
import DashboardLayout from "examples/LayoutContainers/DashboardLayout";
import DashboardNavbar from "examples/Navbars/DashboardNavbar";
import { Box, Button } from "@mui/material"; // Importation de Box et Button

const UpdateChildForm = () => {
  const { id, parentId } = useParams(); // Récupération de l'ID de l'enfant et du parent
  const history = useHistory();
  const [formData, setFormData] = useState({
    LastName: "",
    FirstName: "",
    Age: "",
    Gender: "",
    AutonomyLevel: "",
    SensoryPreferences: "",
    FavoriteInterests: "",
    ModeOfCommunication: "",
    CalmingStrategies: "",
    AllergiesOrDietaryRestrictions: "",
    id_userParent: "", // Ajout pour vérifier le bon parent
  });

  useEffect(() => {
    const fetchChildData = async () => {
      try {
        const data = await getChildById(id);
        setFormData(data);
      } catch (error) {
        console.error("Erreur de récupération des données de l'enfant", error);
      }
    };
    fetchChildData();
  }, [id]);

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      const updatedFields = {
        SensoryPreferences: formData.SensoryPreferences,
        FavoriteInterests: formData.FavoriteInterests,
        ModeOfCommunication: formData.ModeOfCommunication,
        CalmingStrategies: formData.CalmingStrategies,
        AllergiesOrDietaryRestrictions: formData.AllergiesOrDietaryRestrictions,
      };
      await updateChildGeneral(id, parentId, updatedFields); // Appel avec ID enfant et ID parent
      alert("Enfant mis à jour avec succès");
      history.push("/child/ChildList");
    } catch (error) {
      console.error("Erreur lors de la mise à jour", error);
      alert("Erreur lors de la mise à jour de l'enfant");
    }
  };

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData((prevData) => ({
      ...prevData,
      [name]: value,
    }));
  };

  return (
    <DashboardLayout>
      <DashboardNavbar />
      <div className="container">
        <div className="text">{id ? "Mettre à jour un enfant" : "Ajouter un enfant"}</div>
        <form onSubmit={handleSubmit}>
          {/* Champs spécifiques */}
          <div className="form-row">
            <div className="input-data">
              <input
                type="text"
                name="SensoryPreferences"
                value={formData.SensoryPreferences}
                onChange={handleChange}
                required
              />
              <div className="underline"></div>
              <label>Préférences sensorielles</label>
            </div>
            <div className="input-data">
              <input
                type="text"
                name="FavoriteInterests"
                value={formData.FavoriteInterests}
                onChange={handleChange}
                required
              />
              <div className="underline"></div>
              <label>Centres d'intérêt favoris</label>
            </div>
          </div>
          <div className="form-row">
            <div className="input-data">
              <select
                name="ModeOfCommunication"
                value={formData.ModeOfCommunication}
                onChange={handleChange}
                required
              >
                <option value="Verbal">Verbal</option>
                <option value="Pictograms">Pictograms</option>
                <option value="Sign Language">Sign Language</option>
                <option value="PECS">PECS</option>
              </select>
              <div className="underline"></div>
              <label>Mode de communication</label>
            </div>
            <div className="input-data">
              <input
                type="text"
                name="CalmingStrategies"
                value={formData.CalmingStrategies}
                onChange={handleChange}
                required
              />
              <div className="underline"></div>
              <label>Stratégies de régulation</label>
            </div>
          </div>
          <div className="form-row">
            <div className="input-data">
              <input
                type="text"
                name="AllergiesOrDietaryRestrictions"
                value={formData.AllergiesOrDietaryRestrictions}
                onChange={handleChange}
                required
              />
              <div className="underline"></div>
              <label>Allergies ou restrictions alimentaires</label>
            </div>
          </div>
          <br />
          <Box sx={{ display: "flex", justifyContent: "space-between", mt: 4 }}>
            <Button
              variant="contained"
              color="secondary"
              onClick={() => history.push("/child/ChildDetailParent")}
            >
              ⬅ Retour
            </Button>
            <Button variant="contained" color="primary" type="submit">
              ✏️ Modifier
            </Button>
          </Box>
        </form>
      </div>
    </DashboardLayout>
  );
};

export default UpdateChildForm;