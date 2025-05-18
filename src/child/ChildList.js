import React, { useEffect, useState } from "react";
import axios from "axios";
import { useHistory } from "react-router-dom";

// Vision UI components
import VuiBox from "components/VuiBox";
import VuiTypography from "components/VuiTypography";
import Table from "examples/Tables/Table";
import DashboardLayout from "examples/LayoutContainers/DashboardLayout";
import DashboardNavbar from "examples/Navbars/DashboardNavbar";
import Footer from "examples/Footer";
import Card from "@mui/material/Card";
import Pagination from "@mui/material/Pagination";
import Button from "@mui/material/Button";

const ChildList = () => {
  const [children, setChildren] = useState([]); // Always an array
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [currentPage, setCurrentPage] = useState(1);
  const [itemsPerPage, setItemsPerPage] = useState(6); // Items per page
  const history = useHistory();

  useEffect(() => {
    fetchChildren();
  }, [currentPage]);

  const fetchChildren = async () => {
    try {
      const token = localStorage.getItem("token");
      const response = await axios.get("http://localhost:3000/api/children", {
        headers: { Authorization: `Bearer ${token}` },
        params: {
          page: currentPage,
          limit: itemsPerPage,
        },
      });

      if (response.data.success) {
        setChildren(Array.isArray(response.data.data) ? response.data.data : []);
      } else {
        setError("Erreur lors du chargement des enfants.");
      }
    } catch (error) {
      console.error("Error fetching children:", error);
      setError("Impossible de récupérer les données.");
    } finally {
      setLoading(false);
    }
  };

  const handleDelete = async (id) => {
    if (window.confirm("Êtes-vous sûr de vouloir supprimer cet enfant ?")) {
      try {
        const token = localStorage.getItem("token");
        await axios.delete(`http://localhost:3000/api/children/${id}`, {
          headers: { Authorization: `Bearer ${token}` },
        });
        setChildren((prevChildren) => prevChildren.filter((child) => child.id !== id));
      } catch (error) {
        console.error("Erreur lors de la suppression de l'enfant :", error);
        alert("Impossible de supprimer l'enfant.");
      }
    }
  };

  const handlePageChange = (event, page) => {
    setCurrentPage(page);
  };

  const columns = [
    { name: "enfant", align: "left" },
    { name: "genre", align: "left" },
    { name: "actions", align: "center" },
  ];

  const rows = children.map((child) => ({
    enfant: `${child.FirstName} ${child.LastName}`,
    genre: child.Gender,
    actions: (
      <VuiBox display="flex" gap={2}>
         <Button
                      variant="contained"
                      color="secondary"
                      onClick={() => history.push(`/rapport/${child.id}`)}
                    >
                      Etat
                    </Button>
        <VuiTypography
          component="a"
          href="#"
          variant="caption"
          color="warning"
          fontWeight="medium"
          onClick={(e) => {
            e.preventDefault();
            history.push(`/edit/${child.id}`);
          }}
          sx={{ cursor: "pointer" }}
        >
          Modifier
        </VuiTypography>
        <VuiTypography
          component="a"
          href="#"
          variant="caption"
          color="error"
          fontWeight="medium"
          onClick={(e) => {
            e.preventDefault();
            handleDelete(child.id);
          }}
          sx={{ cursor: "pointer" }}
        >
          Supprimer
        </VuiTypography>
      </VuiBox>
    ),
  }));

  return (
    <DashboardLayout>
      <DashboardNavbar />
      <VuiBox py={3}>
        <VuiBox mb={3}>
          <Card>
            <VuiBox display="flex" justifyContent="space-between" alignItems="center" mb="22px">
              <VuiTypography variant="lg" color="white">
                Liste des enfants
              </VuiTypography>
              <VuiTypography
                component="a"
                href="#"
                variant="caption"
                color="text"
                fontWeight="medium"
                onClick={(e) => {
                  e.preventDefault();
                  history.push("/add");
                }}
                sx={{ cursor: "pointer", textDecoration: "underline" }}
              >
                Ajouter un enfant
              </VuiTypography>
            </VuiBox>

            {/* Loading & Error Handling */}
            {loading ? (
              <VuiTypography color="white" textAlign="center">
                Chargement...
              </VuiTypography>
            ) : error ? (
              <VuiTypography color="error" textAlign="center">
                {error}
              </VuiTypography>
            ) : children.length === 0 ? (
              <VuiTypography color="white" textAlign="center">
                Aucun enfant trouvé.
              </VuiTypography>
            ) : (
              <VuiBox>
                <Table columns={columns} rows={rows} />
                <VuiBox display="flex" justifyContent="center" mt={3}>
                  <Pagination
                    count={Math.ceil(children.length / itemsPerPage)}
                    page={currentPage}
                    onChange={handlePageChange}
                    color="primary"
                  />
                </VuiBox>
              </VuiBox>
            )}
          </Card>
        </VuiBox>
      </VuiBox>
      <Footer />
    </DashboardLayout>
  );
};

export default ChildList;