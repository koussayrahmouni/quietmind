import { useEffect, useState } from "react";
import { getChildById } from "../services/api";
import { useParams, useHistory } from "react-router-dom";
import DashboardLayout from "examples/LayoutContainers/DashboardLayout";
import DashboardNavbar from "examples/Navbars/DashboardNavbar";
import Card from "@mui/material/Card";
import { Box, Button } from "@mui/material";
import "./ChildDetail.css"; // Importez le fichier CSS

const ChildDetail = () => {
  const { id } = useParams();
  const history = useHistory();
  const [child, setChild] = useState(null);

  useEffect(() => {
    fetchChild();
  }, [id]);

  const fetchChild = async () => {
    try {
      const childData = await getChildById(id);
      console.log("Données de l'enfant :", childData);

      // Convertir le Buffer en chaîne de caractères si l'image est présente
      if (childData.image && childData.image.type === "Buffer") {
        childData.image = Buffer.from(childData.image.data).toString('utf-8');
        console.log("Chemin de l'image (converti) :", childData.image);
      } else {
        console.log("Aucune image reçue.");
      }

      setChild(childData);
    } catch (error) {
      console.error("Erreur lors du chargement de l'enfant :", error);
    }
  };

  if (!child) {
    return <p className="white-text">Chargement...</p>;
  }

  return (
    <DashboardLayout>
      <DashboardNavbar />
      <Card sx={{ maxWidth: 800, margin: "auto", mt: 4, p: 3 }}>
        <div className="max-w-2xl mx-auto p-4">
          <h2 className="text-2xl font-bold mb-4 white-text">Détails de l'enfant</h2>
          <div className="dark-background shadow-md rounded px-8 pt-6 pb-8 mb-4">
            {/* Affichage de l'image */}
            {child.image ? (
  <div className="child-image-container mb-4">
    <img
      src={child.image} // Utilise directement l'URL reçue
      alt={`${child.FirstName} ${child.LastName}`}
      className="child-image"
      onError={(e) => { 
        console.error("Erreur lors du chargement de l'image :", e.target.src);
        e.target.style.display = 'none'; 
      }}
    />
  </div>
) : (
  <p className="white-text">Aucune image disponible</p>
)}

            <p className="mb-2 white-text">
              <strong>Nom :</strong> {child.LastName}
            </p>
            <p className="mb-2 white-text">
              <strong>Prénom :</strong> {child.FirstName}
            </p>
            <p className="mb-2 white-text">
              <strong>Âge :</strong> {child.Age} ans
            </p>
            <p className="mb-2 white-text">
              <strong>Genre :</strong> {child.Gender}
            </p>
            <p className="mb-2 white-text">
              <strong>Niveau d'autonomie :</strong> {child.AutonomyLevel}
            </p>
            <p className="mb-2 white-text">
              <strong>Préférences sensorielles :</strong> {child.SensoryPreferences}
            </p>
            <p className="mb-2 white-text">
              <strong>Intérêts favoris :</strong> {child.FavoriteInterests}
            </p>
            <p className="mb-2 white-text">
              <strong>Mode de communication :</strong> {child.ModeOfCommunication}
            </p>
            <p className="mb-2 white-text">
              <strong>Stratégies calmantes :</strong> {child.CalmingStrategies}
            </p>
            <p className="mb-2 white-text">
              <strong>Allergies ou restrictions alimentaires :</strong> {child.AllergiesOrDietaryRestrictions}
            </p>
          </div>
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
              onClick={() => history.push(`/edit/${child.id}`)}
            >
              ✏️ Modifier
            </Button>
          </Box>
        </div>
      </Card>
    </DashboardLayout>
  );
};

export default ChildDetail;