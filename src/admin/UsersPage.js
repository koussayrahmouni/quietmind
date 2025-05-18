import React, { useEffect, useState } from "react";
import { IoPencilSharp, IoTrashSharp } from "react-icons/io5";
import axios from "axios";
import { Button, Table, Modal, Form, Pagination } from "react-bootstrap";
//import "./Users.css";
import 'bootstrap/dist/css/bootstrap.min.css';

const UsersPage = () => {
    const [users, setUsers] = useState([]);
    const [showModal, setShowModal] = useState(false);
    const [selectedUser, setSelectedUser] = useState(null);
    const [formData, setFormData] = useState({ firstName: "", lastName: "", email: "", phone: "", role: "" });
    const [currentPage, setCurrentPage] = useState(1);
    const [itemsPerPage, setItemsPerPage] = useState(6);

    useEffect(() => {
        fetchUsers();
    }, [currentPage]);

    const fetchUsers = async () => {
        try {
            const token = localStorage.getItem("token");
            const response = await axios.get("http://localhost:3000/api/users", {
                headers: { Authorization: `Bearer ${token}` },
                params: {
                    page: currentPage,
                    limit: itemsPerPage
                }
            });
            if (response.data.success) {
                setUsers(response.data.data);
            }
        } catch (error) {
            console.error("Error fetching users:", error);
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

    const handleEdit = (user) => {
        setSelectedUser(user);
        setFormData({ firstName: user.firstName, lastName: user.lastName, email: user.email, phone: user.phone, role: user.role });
        setShowModal(true);
    };

    const handleChange = (e) => {
        setFormData({ ...formData, [e.target.name]: e.target.value });
    };

    const handleUpdate = async () => {
        try {
            const token = localStorage.getItem("token");
            await axios.patch(`http://localhost:3000/api/users/${selectedUser.id}`, formData, {
                headers: { Authorization: `Bearer ${token}` }
            });
            setUsers(users.map(user => user.id === selectedUser.id ? { ...user, ...formData } : user));
            setShowModal(false);
        } catch (error) {
            console.error("Error updating user:", error);
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
                        <th>Role</th> {/* Added Role column */}
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
                            <td>{user.role}</td> {/* Displaying the role */}
                            <td>
                                <Button variant="warning" onClick={() => handleEdit(user)}>Edit</Button>{' '}
                                <Button variant="danger" onClick={() => handleDelete(user.id)}>Delete</Button>
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

            <Modal show={showModal} onHide={() => setShowModal(false)}>
                <Modal.Header closeButton>
                    <Modal.Title>Edit User</Modal.Title>
                </Modal.Header>
                <Modal.Body>
                    <Form>
                        <Form.Group>
                            <Form.Label>First Name</Form.Label>
                            <Form.Control type="text" name="firstName" value={formData.firstName} onChange={handleChange} />
                        </Form.Group>
                        <Form.Group>
                            <Form.Label>Last Name</Form.Label>
                            <Form.Control type="text" name="lastName" value={formData.lastName} onChange={handleChange} />
                        </Form.Group>
                        <Form.Group>
                            <Form.Label>Email</Form.Label>
                            <Form.Control type="email" name="email" value={formData.email} onChange={handleChange} />
                        </Form.Group>
                        <Form.Group>
                            <Form.Label>Phone</Form.Label>
                            <Form.Control type="text" name="phone" value={formData.phone} onChange={handleChange} />
                        </Form.Group>
                        <Form.Group>
                            <Form.Label>Role</Form.Label>
                            <Form.Control as="select" name="role" value={formData.role} onChange={handleChange}>
                                <option value="admin">Admin</option>
                                <option value="user">User</option>
                                <option value="parent">Parent</option>
                            </Form.Control>
                        </Form.Group>
                    </Form>
                </Modal.Body>
                <Modal.Footer>
                <Button variant="warning" onClick={() => handleEdit(user)}>
    <IoPencilSharp /> {/* Edit Icon */}
  </Button>{" "}

  {/* Delete Button */}
  <Button variant="danger" onClick={() => handleDelete(user.id)}>
    <IoTrashSharp /> {/* Delete Icon */}
  </Button>
                </Modal.Footer>
            </Modal>
        </div>
    );
};

export default UsersPage;
