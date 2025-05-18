import { useParams, useHistory } from "react-router-dom";
import { MapContainer, TileLayer, Marker, Popup } from "react-leaflet";
import "leaflet/dist/leaflet.css";
import React, { useState, useEffect } from "react";
import { Card, CardContent } from "@mui/material";
import { motion, AnimatePresence } from "framer-motion";
import { PieChart, Pie, Cell, Tooltip, Legend } from "recharts";
import DashboardLayout from "examples/LayoutContainers/DashboardLayout";
import DashboardNavbar from "examples/Navbars/DashboardNavbar";
import "./styles.css";
import RealtimeAlert from "./RealTimeAlert";
import { Box, Button } from "@mui/material";
import L from "leaflet";
import './ReportGenerator.css';

const customIcon = new L.Icon({
  iconUrl: "https://unpkg.com/leaflet@1.7.1/dist/images/marker-icon.png",
  iconRetinaUrl: "https://unpkg.com/leaflet@1.7.1/dist/images/marker-icon-2x.png",
  iconSize: [25, 41],
  iconAnchor: [12, 41],
  popupAnchor: [1, -34],
  shadowUrl: "https://unpkg.com/leaflet@1.7.1/dist/images/marker-shadow.png",
  shadowSize: [41, 41],
});
// MapComponent avec validation des coordonnées
const MapComponent = ({ latitude, longitude }) => {
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
      <Marker position={[latitude, longitude]} icon={customIcon}>
        <Popup>Position actuelle</Popup>
      </Marker>
    </MapContainer>
  );
};

const ReportGenerator = () => {
  const childid = 10;
  const [reports, setReports] = useState([]);
  const [chartData, setChartData] = useState([]);
  const [measurementId, setMeasurementId] = useState(null);
  const history = useHistory();

  const handleNewMeasurement = (id) => {
    setMeasurementId(id);
  };

  // Récupération des données en temps réel
  useEffect(() => {
    const eventSource = new EventSource(`http://localhost:3005/api/sensors/sensors/realtime/${childid}`);

    eventSource.onmessage = (event) => {
      const newData = JSON.parse(event.data);

      if (newData && typeof newData === "object") {
        setReports((prevReports) => [
          {
            id: prevReports.length + 1,
            timestamp: new Date().toLocaleString(),
            data: [newData],
          },
        ]);
      } else {
        console.error("Données reçues invalides :", newData);
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

  // Récupération des données historiques
  useEffect(() => {
    const fetchHistoricalData = async () => {
      try {
        const response = await fetch(`http://localhost:3005/api/sensors/history/${childid}`);
        if (!response.ok) {
          throw new Error("Erreur lors de la récupération des données historiques");
        }
        const data = await response.json();

        // Formater les données pour recharts
        const formattedData = data.map((measurement) => ({
          id: measurement.id,
          name: new Date(measurement.timestamp).toLocaleString(),
          heart_beat: measurement.Heartbeat,
          temperature: measurement.Temperature,
          sound: parseFloat(measurement.sound) || 0, // Convertir le son en nombre
        }));

        setChartData(formattedData);
      } catch (error) {
        console.error("Erreur :", error);
      }
    };

    fetchHistoricalData();
  }, [childid]);

  // Calculer les pourcentages pour le PieChart
  const calculatePercentages = (data) => {
    if (!data || data.length === 0) return [];

    const latestData = data[data.length - 1]; // Prendre les dernières données
    const total = latestData.heart_beat + latestData.temperature + latestData.sound;

    return [
      { name: "Heart Beat", value: (latestData.heart_beat / total) * 100 },
      { name: "Temperature", value: (latestData.temperature / total) * 100 },
      { name: "Sound", value: (latestData.sound / total) * 100 },
    ];
  };

  const pieData = calculatePercentages(chartData);

  // Couleurs pour les segments du PieChart
  const COLORS = ["#0088FE", "#00C49F", "#FFBB28"];

  const getEmotionalState = (heartBeat, temperature) => {
    if (heartBeat > 100 && temperature > 37) return "Stressé";
    if (heartBeat < 60 && temperature < 36) return "Détendu";
    if (heartBeat >= 60 && heartBeat <= 70 && temperature >= 36 && temperature <= 37) return "Joyeux";
    if (heartBeat > 70 && heartBeat <= 80 && temperature > 37) return "Triste";
    if (heartBeat >= 60 && heartBeat <= 80 && temperature < 36) return "Seul";
    return "Normal";
  };

  const getHealthStatus = (heartBeat, temperature) => {
    if (heartBeat > 100 || temperature > 38) return "État critique : Consulter un médecin";
    if (heartBeat > 90 || temperature > 37.5) return "État préoccupant : Surveiller de près";
    if (heartBeat < 60 || temperature < 36) return "État faible : Prendre des précautions";
    return "État stable : Tout va bien";
  };

  return (
    <DashboardLayout>
      <DashboardNavbar id={measurementId} />
      <RealtimeAlert idChild={childid} onNewMeasurement={handleNewMeasurement} />
      <div className="container mx-auto p-4 dark-background">
      <h2 className="text-2xl font-bold text-black mb-8">Rapport en temps réel</h2>


        {reports.length > 0 && reports[0].data && reports[0].data[0] ? (
          <div className="flex flex-wrap gap-8">
            <br></br>
            {/* Cadre pour les données en temps réel */}
            <Card className="dark-background flex-1 min-w-[300px]">
              <CardContent className="p-8">
                <AnimatePresence mode="wait">
                  <motion.div
                    key={reports[0].id}
                    initial={{ opacity: 0, y: 20 }}
                    animate={{ opacity: 1, y: 0 }}
                    exit={{ opacity: 0, y: -20 }}
                    transition={{ duration: 0.5 }}
                    className="space-y-8"
                  >
                    <motion.div
                      className="text-xl font-medium text-center white-text"
                      initial={{ scale: 0.8 }}
                      animate={{ scale: 1 }}
                      transition={{ duration: 0.5 }}
                    >
                      Date: {reports[0].timestamp}
                    </motion.div>

                    <div className="space-y-6">
                      <motion.div
                        className="text-4xl font-bold text-center white-text"
                        initial={{ scale: 0.5, opacity: 0 }}
                        animate={{ scale: 1, opacity: 1 }}
                        transition={{ duration: 0.5, delay: 0.2 }}
                      >
                        {reports[0].data[0].Heartbeat}
                        <span className="text-xl ml-2">bpm</span>
                      </motion.div>

                      <motion.div
                        className="text-3xl font-semibold text-center white-text"
                        initial={{ scale: 0.5, opacity: 0 }}
                        animate={{ scale: 1, opacity: 1 }}
                        transition={{ duration: 0.5, delay: 0.4 }}
                      >
                        {reports[0].data[0].Temperature}
                        <span className="text-xl ml-2">°C</span>
                      </motion.div>

                      <motion.div
                        className="text-3xl font-semibold text-center white-text"
                        initial={{ scale: 0.5, opacity: 0 }}
                        animate={{ scale: 1, opacity: 1 }}
                        transition={{ duration: 0.5, delay: 0.6 }}
                      >
                        {reports[0].data[0].sound}
                        <span className="text-xl ml-2">dB</span>
                      </motion.div>
                    </div>
                  </motion.div>
                </AnimatePresence>
              </CardContent>
            </Card>
            <br></br>
            {/* Cadre pour l'état émotionnel */}
            <Card className="dark-background flex-1 min-w-[300px]">
              <CardContent className="p-8">
                <AnimatePresence mode="wait">
                  <motion.div
                    key={reports[0].id}
                    initial={{ opacity: 0, y: 20 }}
                    animate={{ opacity: 1, y: 0 }}
                    exit={{ opacity: 0, y: -20 }}
                    transition={{ duration: 0.5 }}
                    className="space-y-8"
                  >
                    <motion.div
                      className="text-2xl font-bold text-center white-text"
                      initial={{ scale: 0.8 }}
                      animate={{ scale: 1 }}
                      transition={{ duration: 0.5 }}
                    >
                      État Émotionnel
                    </motion.div>

                    <motion.div
                      className="text-4xl font-bold text-center white-text"
                      initial={{ scale: 0.5, opacity: 0 }}
                      animate={{ scale: 1, opacity: 1 }}
                      transition={{ duration: 0.5, delay: 0.2 }}
                    >
                      {getEmotionalState(reports[0].data[0].Heartbeat, reports[0].data[0].Temperature)}
                    </motion.div>
                  </motion.div>
                </AnimatePresence>
              </CardContent>
            </Card>
            <br></br>
            {/* Cadre pour l'état de santé */}
            <Card className="dark-background flex-1 min-w-[300px]">
              <CardContent className="p-8">
                <AnimatePresence mode="wait">
                  <motion.div
                    key={reports[0].id}
                    initial={{ opacity: 0, y: 20 }}
                    animate={{ opacity: 1, y: 0 }}
                    exit={{ opacity: 0, y: -20 }}
                    transition={{ duration: 0.5 }}
                    className="space-y-8"
                  >
                    <motion.div
                      className="text-2xl font-bold text-center white-text"
                      initial={{ scale: 0.8 }}
                      animate={{ scale: 1 }}
                      transition={{ duration: 0.5 }}
                    >
                      État de Santé
                    </motion.div>

                    <motion.div
                      className="text-4xl font-bold text-center white-text"
                      initial={{ scale: 0.5, opacity: 0 }}
                      animate={{ scale: 1, opacity: 1 }}
                      transition={{ duration: 0.5, delay: 0.2 }}
                    >
                      {getHealthStatus(reports[0].data[0].Heartbeat, reports[0].data[0].Temperature)}
                    </motion.div>
                  </motion.div>
                </AnimatePresence>
              </CardContent>
            </Card>
            <br></br>
            {/* Cadre pour la carte OpenStreetMap */}
            <Card className="w-full">
              <CardContent className="p-8">
                <h4 style={{ color: "white" }} className="graph-title">
                  Localisation
                </h4>
                <MapComponent latitude={reports[0].data[0].Latitude} longitude={reports[0].data[0].Longitude} />
              </CardContent>
            </Card>
            <br></br>
            {/* Cadre pour le graphique circulaire */}
            <Card className="pie-chart-card">
  <CardContent className="p-8">
    <h4 className="pie-chart-title">Données en pourcentage</h4>
    <div className="pie-chart-container">
      <PieChart width={600} height={400}>
        <Pie
          data={pieData}
          cx="50%"
          cy="50%"
          labelLine={false}
          label={({ name, percent }) => `${name}: ${(percent * 100).toFixed(2)}%`}
          outerRadius={150}
          fill="#8884d8"
          dataKey="value"
        >
          {pieData.map((entry, index) => (
            <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
          ))}
        </Pie>
        <Tooltip />
        <Legend />
      </PieChart>
    </div>
  </CardContent>
</Card>
            {/* Bouton de retour */}
            <Box sx={{ display: "flex", justifyContent: "space-between", mt: 4 }}>
              <Button variant="contained" color="secondary" onClick={() => history.push("/child/ChildDetailParent")}>
                ⬅ Retour
              </Button>
            </Box>
          </div>
        ) : (
          <div className="text-white">En attente de données...</div>
        )}
      </div>
    </DashboardLayout>
  );
};

export default ReportGenerator;