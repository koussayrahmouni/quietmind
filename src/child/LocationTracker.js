import React, { useEffect, useState } from "react";
import { useParams } from "react-router-dom";
import { MapContainer, TileLayer, Marker, Popup } from "react-leaflet";
import "leaflet/dist/leaflet.css";
import { Card, CardContent, Typography } from "@mui/material";
import DashboardLayout from "examples/LayoutContainers/DashboardLayout";
import DashboardNavbar from "examples/Navbars/DashboardNavbar";
import L from "leaflet";
import markerIcon from "leaflet/dist/images/marker-icon.png";
import markerIconShadow from "leaflet/dist/images/marker-shadow.png";
const childid = 10;
// Correction pour les icônes de marqueur
delete L.Icon.Default.prototype._getIconUrl;
L.Icon.Default.mergeOptions({
  iconUrl: markerIcon,
  shadowUrl: markerIconShadow,
});

// Composant MapComponent pour afficher la localisation
const MapComponent = ({ latitude, longitude }) => {
  // Vérifier que latitude et longitude sont valides
  const isValidLatitude = typeof latitude === "number" && latitude >= -90 && latitude <= 90;
  const isValidLongitude = typeof longitude === "number" && longitude >= -180 && longitude <= 180;

  if (!isValidLatitude || !isValidLongitude) {
    return <div>Données de localisation non disponibles.</div>;
  }

  return (
    <MapContainer
      center={[latitude, longitude]}
      zoom={13}
      style={{ height: "400px", width: "100%" }}
    >
      <TileLayer
        url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
        attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
      />
      <Marker position={[latitude, longitude]}>
        <Popup>Position actuelle</Popup>
      </Marker>
    </MapContainer>
  );
};

const LocationTracker = () => {
  const childid = 10;
  const [locationData, setLocationData] = useState({ latitude: null, longitude: null });

  useEffect(() => {
    // Connexion au SSE pour récupérer les données de localisation
    const eventSource = new EventSource(`http://localhost:3000/api/sensors/sensors/realtime/${childid}`);

    eventSource.onmessage = (event) => {
      const newData = JSON.parse(event.data);
      console.log("Données reçues du backend :", newData); // Affiche l'objet complet

      // Mettre à jour les données de localisation
      if (newData.Latitude && newData.Longitude) {
        console.log("Latitude reçue :", newData.Latitude); // Affiche la latitude
        console.log("Longitude reçue :", newData.Longitude); // Affiche la longitude

        setLocationData({
          latitude: newData.Latitude,
          longitude: newData.Longitude,
        });

        // Afficher les valeurs après la mise à jour de l'état
        console.log("Latitude mise à jour :", newData.Latitude);
        console.log("Longitude mise à jour :", newData.Longitude);
      }
    };

    eventSource.onerror = (error) => {
      console.error("Erreur SSE :", error);
      eventSource.close();
    };

    return () => {
      eventSource.close();
    };
  }, [childid]);

  return (
    <DashboardLayout>
      <DashboardNavbar />
      <div className="container mx-auto p-4">
        <Card>
          <CardContent>
            <Typography variant="h5" className="text-2xl font-bold mb-4">
              Suivi de localisation en temps réel
            </Typography>
            {locationData.latitude && locationData.longitude ? (
              <MapComponent latitude={locationData.latitude} longitude={locationData.longitude} />
            ) : (
              <Typography>En attente des données de localisation...</Typography>
            )}
          </CardContent>
        </Card>
      </div>
    </DashboardLayout>
  );
};

export default LocationTracker;