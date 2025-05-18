import { useState, useEffect } from "react";
import { useParams, useHistory } from "react-router-dom";
import { getChildById, updateChild } from "../services/api";
import DashboardLayout from "examples/LayoutContainers/DashboardLayout";
import DashboardNavbar from "examples/Navbars/DashboardNavbar";
import Card from "@mui/material/Card";
import { Box, Button } from "@mui/material"; // Importation de Box et Button

const UpdateChildForm = () => {
  const { id } = useParams();
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
    id_userParent: "", // Ce champ ne sera pas affiché
    created_at: "", // Ce champ ne sera pas affiché ni modifié
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
      await updateChild(id, formData);
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
          <div className="form-row">
            <div className="input-data">
              <label><strong>Nom</strong></label>
              <br></br>
              <input
                type="text"
                id="LastName"
                name="LastName"
                value={formData.LastName}
                onChange={handleChange}
                required
              />
             
              <div className="underline"></div>
              
            </div>
            <div className="input-data">
              <label><strong>Prénom</strong></label>

              <br></br>
              <input
                type="text"
                id="FirstName"
                name="FirstName"
                value={formData.FirstName}
                onChange={handleChange}
                required
              />
              <div className="underline"></div>
            </div>
          </div>
          <div className="form-row">
            <div className="input-data">
              <label><strong>Âge</strong></label>
              <br></br>
              <input
                type="number"
                id="Age"
                name="Age"
                value={formData.Age}
                onChange={handleChange}
                required
              />
              <div className="underline"></div>
            </div>
            <div className="input-data">
              <label><strong>Genre</strong></label>
              <br></br>
              <select
                id="Gender"
                name="Gender"
                value={formData.Gender}
                onChange={handleChange}
                required
              >
                <option value="Male">Garçon</option>
                <option value="Female">Fille</option>
              </select>
              <div className="underline"></div>
            </div>
          </div>
          <div className="form-row">
            <div className="input-data">
              <label><strong>Niveau d'autonomie</strong></label>
              <br></br>
              <select
                id="AutonomyLevel"
                name="AutonomyLevel"
                value={formData.AutonomyLevel}
                onChange={handleChange}
                required
              >
                <option value="Low">Low</option>
                <option value="Medium">Medium</option>
                <option value="High">High</option>
              </select>
              <div className="underline"></div>
            </div>
            <div className="input-data">
              <label><strong>Préférences sensorielles</strong></label>
              <br></br>
              <input
                type="text"
                id="SensoryPreferences"
                name="SensoryPreferences"
                value={formData.SensoryPreferences}
                onChange={handleChange}
              />
              <div className="underline"></div>
            </div>
          </div>
          <div className="form-row">
            <div className="input-data">
              <label><strong>Centres d'intérêt favoris</strong></label>
              <br></br>
              <input
                type="text"
                id="FavoriteInterests"
                name="FavoriteInterests"
                value={formData.FavoriteInterests}
                onChange={handleChange}
              />
              <div className="underline"></div>
            </div>
            <div className="input-data">
              <label><strong>Mode de communication</strong></label>
              <br></br>
              <select
                id="ModeOfCommunication"
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
            </div>
          </div>
          <div className="form-row">
            <div className="input-data">
              <label><strong>Stratégies de régulation</strong></label>
              <br></br>
              <input
                type="text"
                id="CalmingStrategies"
                name="CalmingStrategies"
                value={formData.CalmingStrategies}
                onChange={handleChange}
              />
              <div className="underline"></div>
            </div>
            <div className="input-data">
              <label><strong>Allergies ou restrictions alimentaires</strong></label>
              <br></br>
              <input
                type="text"
                id="AllergiesOrDietaryRestrictions"
                name="AllergiesOrDietaryRestrictions"
                value={formData.AllergiesOrDietaryRestrictions}
                onChange={handleChange}
              />
              <div className="underline"></div>
            </div>
          </div>
          <br></br>
          {/* Boutons Retour et Modifier */}
          <Box sx={{ display: "flex", justifyContent: "space-between", mt: 4 }}>
            <Button
              variant="contained"
              color="secondary"
              onClick={() => history.push("/child/ChildList")}
            >
              ⬅ Retour
            </Button>
            <Button
              variant="contained"
              color="primary"
              type="submit" // Le bouton "Modifier" soumet le formulaire
            >
              ✏️ Modifier
            </Button>
          </Box>
        </form>
      </div>
    </DashboardLayout>
  );
};

export default UpdateChildForm;