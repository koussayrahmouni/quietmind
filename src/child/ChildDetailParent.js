import React, { useEffect, useState } from "react";
import axios from "axios";
import { Button, Table, Modal, Form, Pagination } from "react-bootstrap";
import 'bootstrap/dist/css/bootstrap.min.css';
import './ChildDetailParent.css';
import { IoPencilSharp, IoPersonAddSharp, IoTrashSharp } from "react-icons/io5";
const ChildDetailParent = () => {
  // States for users and children lists
  const [users, setUsers] = useState([]);
  const [children, setChildren] = useState([]);
  
  // State for the Edit modal
  const [showEditModal, setShowEditModal] = useState(false);
  const [selectedUser, setSelectedUser] = useState(null);
  const [editFormData, setEditFormData] = useState({
    firstName: "",
    lastName: "",
    email: "",
    phone: "",
    role: "",
    childId: ""
  });
  
  // State for the Assign Child modal
  const [showAssignModal, setShowAssignModal] = useState(false);
  const [assignFormData, setAssignFormData] = useState({ childId: "" });
  const [assignSelectedUser, setAssignSelectedUser] = useState(null);

  // Pagination states
  const [currentPage, setCurrentPage] = useState(1);
  const [itemsPerPage] = useState(6);

  

  useEffect(() => {
    fetchUsers();
    fetchChildren();
  }, [currentPage]);

  const fetchUsers = async () => {
    try {
      const token = localStorage.getItem("token");
      const response = await axios.get("http://localhost:3000/api/users/", {
        headers: { Authorization: `Bearer ${token}` },
        params: { page: currentPage, limit: itemsPerPage }
      });
      if (response.data.success) {
        setUsers(response.data.data);
      }
    } catch (error) {
      console.error("Error fetching users:", error);
    }
  };

  const fetchChildren = async () => {
    try {
      const token = localStorage.getItem("token");
      const response = await axios.get("http://localhost:3000/api/children", {
        headers: { Authorization: `Bearer ${token}` }
      });
      if (response.data.success) {
        setChildren(response.data.data);
        console.log("Fetched children:", response.data.data);
      }
    } catch (error) {
      console.error("Error fetching children:", error);
    }
  };

  const handleDelete = async (id) => {
    if (!window.confirm("Are you sure you want to delete this user?")) return;
    try {
      const token = localStorage.getItem("token");
      await axios.delete(`http://localhost:3000/api/users/${id}`, {
        headers: { Authorization: `Bearer ${token}` }
      });
      setUsers(users.filter(user => user.id !== id));
    } catch (error) {
      console.error("Error deleting user:", error);
    }
  };

  // ----- Edit Modal Logic -----
  const handleEdit = (user) => {
    setSelectedUser(user);
    setEditFormData({
      firstName: user.firstName,
      lastName: user.lastName,
      email: user.email,
      phone: user.phone,
      role: user.role,
      childId: user.childId || ""
    });
    setShowEditModal(true);
  };

  const handleEditChange = (e) => {
    setEditFormData({ ...editFormData, [e.target.name]: e.target.value });
  };

  const handleEditUpdate = async () => {
    try {
      const token = localStorage.getItem("token");
      const updateResponse = await axios.patch(
        `http://localhost:3000/api/users/${selectedUser.id}`,
        editFormData,
        { headers: { Authorization: `Bearer ${token}` } }
      );
      if (!updateResponse.data.success) {
        alert("Error updating user");
        return;
      }
      setUsers(
        users.map(user =>
          user.id === selectedUser.id ? { ...user, ...editFormData } : user
        )
      );
      setShowEditModal(false);
    } catch (error) {
      console.error("Error updating user:", error);
      alert("An error occurred while updating.");
    }
  };

  // ----- Assign Child Modal Logic -----
  const handleOpenAssignModal = (user) => {
    setAssignSelectedUser(user);
    // Reset the assign form
    setAssignFormData({ childId: "" });
    setShowAssignModal(true);
  };

  const handleAssignChange = (e) => {
    setAssignFormData({ ...assignFormData, [e.target.name]: e.target.value });
  };

  const handleAssignChild = async () => {
    if (!assignFormData.childId) {
      alert("Please select a child.");
      return;
    }
    try {
      const token = localStorage.getItem("token");
      const assignResponse = await axios.post(
        "http://localhost:3000/api/users/assignchild",
        { parent_id: assignSelectedUser.id, child_id: assignFormData.childId },
        { headers: { Authorization: `Bearer ${token}` } }
      );
      if (assignResponse.data.success) {
        alert("Child assigned successfully!");
        // Optionally update the local user record if needed
        setUsers(
          users.map(user =>
            user.id === assignSelectedUser.id ? { ...user, childId: assignFormData.childId } : user
          )
        );
        setShowAssignModal(false);
      } else {
        alert(assignResponse.data.message || "Error assigning child");
      }
    } catch (error) {
      console.error("Error assigning child:", error);
      alert("An error occurred while assigning the child.");
    }
  };

  const handleNextPage = () => {
    setCurrentPage(currentPage + 1);
  };

  const handlePreviousPage = () => {
    setCurrentPage(currentPage - 1);
  };

  const indexOfLastItem = currentPage * itemsPerPage;
  const indexOfFirstItem = indexOfLastItem - itemsPerPage;
  const currentItems = users.slice(indexOfFirstItem, indexOfLastItem);

  return (
    <div className="container mt-4">
      <Table striped bordered hover>
        <thead>
          <tr>
            <th>First Name</th>
            <th>Last Name</th>
            <th>Email</th>
            <th>Phone</th>
            <th>Role</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          {currentItems.map(user => (
            <tr key={user.id}>
              <td>{user.firstName}</td>
              <td>{user.lastName}</td>
              <td>{user.email}</td>
              <td>{user.phone}</td>
              <td>{user.role}</td>
              <td>
              <Button variant="warning" onClick={() => handleEdit(user)}>
    <IoPencilSharp /> {/* Edit Icon */}
  </Button>{" "}

  {/* Assign Child Button */}
  <Button variant="info" onClick={() => handleOpenAssignModal(user)}>
    <IoPersonAddSharp /> {/* Assign Child Icon */}
  </Button>{" "}

  {/* Delete Button */}
  <Button variant="danger" onClick={() => handleDelete(user.id)}>
    <IoTrashSharp /> {/* Delete Icon */}
  </Button>
              </td>
            </tr>
          ))}
        </tbody>
      </Table>

      <Pagination>
        <Pagination.Prev onClick={handlePreviousPage} disabled={currentPage === 1} />
        <Pagination.Item>{currentPage}</Pagination.Item>
        <Pagination.Next onClick={handleNextPage} disabled={currentItems.length < itemsPerPage} />
      </Pagination>

      {/* Edit Modal */}
      <Modal show={showEditModal} onHide={() => setShowEditModal(false)}>
        <Modal.Header closeButton>
          <Modal.Title>Edit User</Modal.Title>
        </Modal.Header>
        <Modal.Body>
          <Form>
            <Form.Group>
              <Form.Label>First Name</Form.Label>
              <Form.Control
                type="text"
                name="firstName"
                value={editFormData.firstName}
                onChange={handleEditChange}
              />
            </Form.Group>
            <Form.Group>
              <Form.Label>Last Name</Form.Label>
              <Form.Control
                type="text"
                name="lastName"
                value={editFormData.lastName}
                onChange={handleEditChange}
              />
            </Form.Group>
            <Form.Group>
              <Form.Label>Email</Form.Label>
              <Form.Control
                type="email"
                name="email"
                value={editFormData.email}
                onChange={handleEditChange}
              />
            </Form.Group>
            <Form.Group>
              <Form.Label>Phone</Form.Label>
              <Form.Control
                type="text"
                name="phone"
                value={editFormData.phone}
                onChange={handleEditChange}
              />
            </Form.Group>
            <Form.Group>
              <Form.Label>Role</Form.Label>
              <Form.Control
                as="select"
                name="role"
                value={editFormData.role}
                onChange={handleEditChange}
              >
                <option value="admin">Admin</option>
                <option value="user">User</option>
                <option value="parent">Parent</option>
              </Form.Control>
            </Form.Group>
            <Form.Group>
              <Form.Label>Assign Child (optional)</Form.Label>
              <Form.Control
                as="select"
                name="childId"
                value={editFormData.childId}
                onChange={handleEditChange}
              >
                <option value="">Select a child</option>
                {children && children.length > 0 ? (
                  children.map(child => (
                    <option key={child.id} value={child.id}>
                      {child.FirstName} {child.LastName}
                    </option>
                  ))
                ) : (
                  <option value="">No children available</option>
                )}
              </Form.Control>
            </Form.Group>
          </Form>
        </Modal.Body>
        <Modal.Footer>
          <Button variant="secondary" onClick={() => setShowEditModal(false)}>
            Close
          </Button>
          <Button variant="primary" onClick={handleEditUpdate}>
            Save Changes
          </Button>
        </Modal.Footer>
      </Modal>

      {/* Assign Child Modal */}
      <Modal show={showAssignModal} onHide={() => setShowAssignModal(false)}>
        <Modal.Header closeButton>
          <Modal.Title>Assign Child to Parent</Modal.Title>
        </Modal.Header>
        <Modal.Body>
          <Form>
            <Form.Group>
              <Form.Label>Select Child</Form.Label>
              <Form.Control
                as="select"
                name="childId"
                value={assignFormData.childId}
                onChange={handleAssignChange}
              >
                <option value="">Select a child</option>
                {children && children.length > 0 ? (
                  children.map(child => (
                    <option key={child.id} value={child.id}>
                      {child.FirstName} {child.LastName}
                    </option>
                  ))
                ) : (
                  <option value="">No children available</option>
                )}
              </Form.Control>
            </Form.Group>
          </Form>
        </Modal.Body>
        <Modal.Footer>
          <Button variant="secondary" onClick={() => setShowAssignModal(false)}>
            Cancel
          </Button>
          <Button variant="primary" onClick={handleAssignChild}>
            Assign Child
          </Button>
        </Modal.Footer>
      </Modal>
    </div>
  );
};

export default ChildDetailParent;
