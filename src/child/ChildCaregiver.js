import { useEffect, useState } from "react";
import { useHistory } from "react-router-dom";
import DashboardLayout from "examples/LayoutContainers/DashboardLayout";
import DashboardNavbar from "examples/Navbars/DashboardNavbar";
import Card from "@mui/material/Card";
import { Box, Button, Typography } from "@mui/material";
import "./ChildDetail.css"; // Import du fichier CSS

const ChildDetail = () => {
  const history = useHistory();
  const [children, setChildren] = useState([]); // Un tableau pour stocker les enfants

  // ID du caregiver (à remplacer dynamiquement si besoin)
  const caregiverId = 9; // Exemple d'ID caregiver à remplacer selon les besoins

  useEffect(() => {
    fetchChildren();
  }, []);

  const fetchChildren = async () => {
    try {
      const url = `http://localhost:3001/api/child/Caregiver/${caregiverId}`;
      const response = await fetch(url);
      if (!response.ok) {
        throw new Error("Erreur lors du chargement des données");
      }
      const childrenData = await response.json();
      console.log("Données des enfants :", childrenData);
      setChildren(childrenData); // Mettre à jour l'état avec la liste d'enfants
    } catch (error) {
      console.error("Erreur lors du chargement des enfants :", error);
    }
  };

  if (children.length === 0) {
    return <p className="white-text">Chargement...</p>;
  }

  return (
    <DashboardLayout>
      <DashboardNavbar />
      <Card sx={{ maxWidth: 800, margin: "auto", mt: 4, p: 3 }}>
        <div className="max-w-2xl mx-auto p-4">
          <Typography variant="h5" className="text-2xl font-bold mb-4 white-text">
            Détails des enfants
          </Typography>

          {/* Cartes pour chaque enfant */}
          <div className="child-cards-container">
            {children.map((child) => (
              <Card
                key={child.id}
                sx={{
                  marginBottom: 3,
                  padding: 2,
                  backgroundColor: "#f4f6f8",
                  boxShadow: 3,
                  borderRadius: 2,
                }}
                className="child-card"
              >
                <Typography variant="h6" className="white-text">
                  <strong>Nom :</strong> {child.LastName}
                </Typography>
                <Typography className="white-text">
                  <strong>Prénom :</strong> {child.FirstName}
                </Typography>
                <Typography className="white-text">
                  <strong>Âge :</strong> {child.Age} ans
                </Typography>
                <Typography className="white-text">
                  <strong>Genre :</strong> {child.Gender}
                </Typography>
                <Typography className="white-text">
                  <strong>Niveau d'autonomie :</strong> {child.AutonomyLevel}
                </Typography>
                <Typography className="white-text">
                  <strong>Préférences sensorielles :</strong> {child.SensoryPreferences}
                </Typography>
                <Typography className="white-text">
                  <strong>Intérêts favoris :</strong> {child.FavoriteInterests}
                </Typography>
                <Typography className="white-text">
                  <strong>Mode de communication :</strong> {child.ModeOfCommunication}
                </Typography>
                <Typography className="white-text">
                  <strong>Stratégies calmantes :</strong> {child.CalmingStrategies}
                </Typography>
                <Typography className="white-text">
                  <strong>Allergies ou restrictions alimentaires :</strong> {child.AllergiesOrDietaryRestrictions}
                </Typography>
              </Card>
            ))}
          </div>

        </div>
      </Card>
    </DashboardLayout>
  );
};

export default ChildDetail;
