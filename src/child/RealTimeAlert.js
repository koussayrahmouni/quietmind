import { useEffect } from "react";

const RealtimeAlert = ({ idChild=10, onNewMeasurement }) => {
  const homeLocation = { latitude: 48.8566, longitude: 2.3522 };

  const sendAlertToBackend = async (message, type, id_mesure, sound = null) => {
    if (!id_mesure) {
      console.error("ID de mesure invalide :", id_mesure);
      return;
    }
  
    try {
      // Vérifier si une alerte similaire existe déjà aujourd'hui
      const checkResponse = await fetch(
        `http://localhost:3005/api/sensors/alerts/check/${type}/${id_mesure}`
      );
  
      if (!checkResponse.ok) {
        console.error("Erreur lors de la vérification de l'alerte :", checkResponse.statusText);
        return;
      }
  
      const checkData = await checkResponse.json();
  
      if (checkData.exists) {
        console.log("Alerte déjà enregistrée aujourd'hui.");
        return;
      }
  
      // Insérer la nouvelle alerte
      const insertResponse = await fetch("http://localhost:3005/api/sensors/alerts", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          message,
          type,
          id_mesure,
          sound: sound !== null ? String(sound) : null,
        }),
      });
  
      if (!insertResponse.ok) {
        console.error("Erreur lors de l'enregistrement de l'alerte :", insertResponse.statusText);
      } else {
        const responseData = await insertResponse.json();
        console.log("Alerte enregistrée avec succès :", responseData);
      }
    } catch (error) {
      console.error("Erreur lors de l'envoi de la requête :", error);
    }
  };

  const isWithinSafeZone = (lat, lon) => {
    const latThreshold = 0.05;
    const lonThreshold = 0.05;

    return (
      Math.abs(lat - homeLocation.latitude) <= latThreshold &&
      Math.abs(lon - homeLocation.longitude) <= lonThreshold
    );
  };

  useEffect(() => {
    if (!("Notification" in window)) {
      console.warn("Ce navigateur ne prend pas en charge les notifications.");
      return;
    }

    if (Notification.permission === "default") {
      Notification.requestPermission().then((permission) => {
        if (permission !== "granted") {
          console.warn("Permission de notification refusée.");
          return;
        }
      });
    }

    let eventSource = new EventSource(`http://localhost:3005/api/sensors/realtime/${idChild}`);

    eventSource.onopen = () => {
      console.log("Connexion SSE établie");
    };

    eventSource.onmessage = (event) => {
      if (!event.data) {
        console.error("Aucune donnée reçue ou valeur invalide :", event.data);
        return;
      }

      try {
        const data = JSON.parse(event.data);
        const { id, Heartbeat, Temperature, Latitude, Longitude, sound } = data; // Utiliser les bonnes clés

        if (
          id === undefined ||
          Heartbeat === undefined ||
          Temperature === undefined ||
          Latitude === undefined ||
          Longitude === undefined ||
          sound === undefined
        ) {
          console.error("Données SSE incomplètes :", data);
          return;
        }

        if (onNewMeasurement) {
          onNewMeasurement(id);
        }

        // Vérifier les conditions pour envoyer une alerte
        if (Heartbeat > 140 || Temperature > 38.5) {
          const message = `⚠️ Crise détectée ! FC: ${Heartbeat} bpm | Temp: ${Temperature}°C`;
          sendAlertToBackend(message, "crise", id);

          // Envoyer un e-mail d'alerte
          const subject = "Alerte : Crise détectée";
          const text = `Une crise a été détectée pour l'enfant ${idChild}. Détails : ${message}`;
          // Ajouter ici la logique pour envoyer un e-mail
        }

        if (!isWithinSafeZone(Latitude, Longitude)) {
          const message = `⚠️ Enfant hors zone sécurisée ! 📍 Localisation : ${Latitude}, ${Longitude}`;
          sendAlertToBackend(message, "hors_zone", id);

          // Envoyer un e-mail d'alerte
          const subject = "Alerte : Enfant hors zone sécurisée";
          const text = `L'enfant ${idChild} est hors de la zone sécurisée. Détails : ${message}`;
          // Ajouter ici la logique pour envoyer un e-mail
        }

        // Vérifier le niveau sonore
        if (sound > 80) { // Seuil de niveau sonore pour déclencher une alerte
          const message = `⚠️ Niveau sonore élevé détecté ! 🔊 Niveau : ${sound} dB`;
          sendAlertToBackend(message, "sonore", id, sound);

          // Envoyer un e-mail d'alerte
          const subject = "Alerte : Niveau sonore élevé";
          const text = `Un niveau sonore élevé a été détecté pour l'enfant ${idChild}. Détails : ${message}`;
          // Ajouter ici la logique pour envoyer un e-mail
        }
      } catch (error) {
        console.error("Erreur lors de l'analyse JSON des données SSE :", error, event.data);
      }
    };

    eventSource.onerror = (error) => {
      console.error("Erreur de connexion au serveur SSE :", error);
      eventSource.close();

      setTimeout(() => {
        console.log("Tentative de reconnexion au serveur SSE...");
        eventSource = new EventSource(`http://localhost:3005/api/sensors/realtime/${idChild}`);
      }, 5000);
    };

    return () => {
      eventSource.close();
      console.log("Connexion SSE fermée");
    };
  }, [idChild, onNewMeasurement]);

  return null;
};

export default RealtimeAlert;