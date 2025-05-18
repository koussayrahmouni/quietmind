const { 
    create, 
    getUsersById,
    updateUser,
    deleteUser,
    getUsers,
    getUserByEmail ,
    verifyUserEmail,
    resetPassword ,
    getUserByEmailLogin,
    getParents , 
    getAllUserss,
    getUserss,
    assignCaregiverToParent ,
    getCaregiversByParentId ,
    getAllParents,
    assignChildToParent,
    getChildrenByParentId,
    getParentsByChildId ,
    assignParentChildRelation ,  
    } = require("../service/user.service");
const { genSaltSync, hashSync ,compareSync} = require("bcrypt");
const { json } = require("express");
const {sign} = require("jsonwebtoken");
const { sendVerificationEmail } = require("../service/email.service");
const jwt = require("jsonwebtoken");




module.exports = {
    createUser: (req, res) => {
        const body = req.body;
    
        if (!body.password) {
            return res.status(400).json({
                success: 0,
                message: "Password is required",
            });
        }
    
        const salt = genSaltSync(10);
        body.password = hashSync(body.password, salt);
    
        create(body, (err, results) => {
            if (err) {
                console.error("Database Error:", err);
                return res.status(500).json({
                    success: 0,
                    message: "Database connection error",
                });
            }
    
            if (results.emailExists) {
                return res.status(400).json({
                    success: 0,
                    message: "L'email existe déjà. Veuillez utiliser un autre email.",
                });
            }
    
            return res.status(200).json({
                success: 1,
                message: "Utilisateur créé avec succès",
                data: results,
            });
        });
    },
    getUserById: (req, res) => {
        const id = req.params.id;

        getUsersById(id, (err, result) => {
            if (err) {
                console.error("Database Error:", err);
                return res.status(500).json({
                    success: 0,
                    message: "Database connection error",
                });
            }

            if (!result) {
                return res.status(404).json({
                    success: 0,
                    message: "User not found",
                });
            }

            return res.status(200).json({
                success: 1,
                data: result,
            });
        });
    },
    getAllUsers: (req, res) => {
        getUsers((err, results) => {
            if (err) {
                console.error("Database Error:", err);
                return res.status(500).json({
                    success: 0,
                    message: "Database connection error",
                });
            }

            return res.status(200).json({
                success: 1,
                data: results,
            });
        });
    },
    getAllUserss: (req, res) => {
        getUserss((err, results) => {
            if (err) {
                console.error("Database Error:", err);
                return res.status(500).json({
                    success: 0,
                    message: "Database connection error",
                });
            }

            return res.status(200).json({
                success: 1,
                data: results,
            });
        });
    },
    updateUser: (req, res) => {
        const body = req.body;
        const id = req.params.id; // Get ID from URL params
        body.id = id; // Assign the ID to the request body
    
        updateUser(body, (err, results) => {
            if (err) {
                console.error("Database Error:", err);
                return res.status(500).json({
                    success: 0,
                    message: "Database connection error",
                });
            }
    
            if (!results) {
                return res.status(404).json({
                    success: 0,
                    message: "User not found",
                });
            }
    
            return res.status(200).json({
                success: 1,
                message: "User updated successfully",
            });
        });
    },
    deleteUser: (req, res) => {
        const id = req.params.id;

        deleteUser(id, (err, results) => {
            if (err) {
                console.error("Database Error:", err);
                return res.status(500).json({
                    success: 0,
                    message: "Database connection error",
                });
            }

            if (results.affectedRows === 0) {
                return res.status(404).json({
                    success: 0,
                    message: "User not found",
                });
            }

            return res.status(200).json({
                success: 1,
                message: "User deleted successfully",
            });
        });
    },
    login: (req, res) => {
        const body = req.body;
    
        getUserByEmail(body.email, (err, user) => {
            if (err) {
                console.error("Database Error:", err);
                return res.status(500).json({
                    success: 0,
                    message: "Database connection error",
                });
            }
    
            if (!user) {
                return res.status(401).json({
                    success: 0,
                    message: "Invalid email or password",
                });
            }
    
            const isPasswordValid = compareSync(body.password, user.password);
            if (isPasswordValid) {
                user.password = undefined; // Ne pas renvoyer le mot de passe
    
                const token = sign({ user }, "qwe1234", { expiresIn: "1h" });
    
                return res.status(200).json({
                    success: 1,
                    message: "Login successful",
                    token: token,
                    user: {  // 🔥 Ajout de la clé "user" avec le rôle !
                        id: user.id,
                        email: user.email,
                        role: user.role // Assurez-vous que cette colonne existe dans la base de données
                        
                    }
                    
                });
            } else {
                return res.status(401).json({
                    success: 0,
                    message: "Invalid email or password",
                });
            }
        });
    },
    signup: (req, res) => {
        const body = req.body;
    
        if (!body.email) { // Remove password check since we're setting a default one
            return res.status(400).json({
                success: 0,
                message: "Email is required",
            });
        }
    
        // Set default password if not provided
        body.password = body.password || "ChangeMePlease";
    
        // Check if email already exists
        getUserByEmail(body.email, (err, user) => {
            if (err) {
                console.error("Database Error:", err);
                return res.status(500).json({
                    success: 0,
                    message: "Database connection error",
                });
            }
    
            if (user) {
                return res.status(400).json({
                    success: 0,
                    message: "L'email existe déjà. Veuillez utiliser un autre email.",
                });
            }
    
            // Hash password
            const salt = genSaltSync(10);
            body.password = hashSync(body.password, salt);
    
            // Set role to 'parents'
            body.role = "parent";
            body.etat=0;
    
            // Create the user
            create(body, (err, results) => {
                if (err) {
                    console.error("Database Error:", err);
                    return res.status(500).json({
                        success: 0,
                        message: "Database connection error",
                    });
                }
    
                // Generate email verification token
                const token = jwt.sign({ email: body.email }, process.env.JWT_SECRET, { expiresIn: "1h" });
    
                // Send email verification
                sendVerificationEmail(body.email, token)
                    .then(() => {
                        return res.status(201).json({
                            success: 1,
                            message: "Utilisateur créé avec succès. Veuillez vérifier votre email.",
                        });
                    })
                    .catch((emailErr) => {
                        console.error("Email Error:", emailErr);
                        return res.status(500).json({
                            success: 0,
                            message: "Utilisateur créé, mais échec de l'envoi de l'email.",
                        });
                    });
            });
        });
    },   
    verifyEmail: (req, res) => {
        const { token } = req.params; // Extract token from URL

        if (!token) {
            return res.status(400).json({
                success: 0,
                message: "Token manquant.",
            });
        }

        // Verify the token
        jwt.verify(token, process.env.JWT_SECRET, (err, decoded) => {
            if (err) {
                return res.status(400).json({
                    success: 0,
                    message: "Lien de vérification invalide ou expiré.",
                });
            }

            const email = decoded.email; // Get email from decoded token

            // Update user in database (set email_verified = true)
            verifyUserEmail(email, (err, results) => {
                if (err) {
                    return res.status(500).json({
                        success: 0,
                        message: "Erreur de base de données.",
                    });
                }

                return res.status(200).json({
                    success: 1,
                    message: " Welcome to Quiet Mind this is user password ' ChangeMePlease ' .",
                });
            });
        });
    },
    resetUserPassword: (req, res) => {
        const { email } = req.body;

        if (!email) {
            return res.status(400).json({
                success: 0,
                message: "Email is required",
            });
        }

        resetPassword(email, (err, results) => {
            if (err) {
                console.error("Database Error:", err);
                return res.status(500).json({
                    success: 0,
                    message: "Database connection error",
                });
            }

            if (!results) {
                return res.status(404).json({
                    success: 0,
                    message: "User not found",
                });
            }

            return res.status(200).json({
                success: 1,
                message: "A new password has been sent to your email.",
            });
        });
    },
    getUserByEmailLogin: (req, res) => {
        const email = req.params.email;

        getUserByEmail(email, (err, user) => {
            if (err) {
                console.error("Database Error:", err);
                return res.status(500).json({
                    success: 0,
                    message: "Database connection error",
                });
            }

            if (!user) {
                return res.status(404).json({
                    success: 0,
                    message: "User not found",
                });
            }

            return res.status(200).json({
                success: 1,
                data: user,
            });
        });
    },
    getAllParents: (req, res) => {
        getAllParents((err, results) => {
            if (err) {
                return res.status(500).json({
                    success: 0,
                    message: "Database connection error"
                });
            }

            if (!results) {
                return res.status(404).json({
                    success: 0,
                    message: "No parents found" // More accurate message
                });
            }

            return res.status(200).json({
                success: 1,
                data: results
            });
        });
    },
    assignCaregiver: (req, res) => {
        const { parentId, caregiverId } = req.body;

        if (!parentId || !caregiverId) {
            return res.status(400).json({
                success: 0,
                message: "Parent ID and Caregiver ID are required",
            });
        }

        assignCaregiverToParent(parentId, caregiverId, (err, results) => {
            if (err) {
                return res.status(500).json({
                    success: 0,
                    message: "Database connection error",
                });
            }
            return res.status(200).json({
                success: 1,
                message: "Caregiver assigned successfully",
            });
        });
    },
    getCaregiversByParent: (req, res) => {
        const parentId = req.params.parentId;

        if (!parentId) {
            return res.status(400).json({
                success: 0,
                message: "Parent ID is required",
            });
        }

        getCaregiversByParentId(parentId, (err, results) => {
            if (err) {
                return res.status(500).json({
                    success: 0,
                    message: "Database connection error",
                });
            }
            return res.status(200).json({
                success: 1,
                data: results,
            });
        });
    },
    assignChild: (req, res) => {
        const { parentId, childId } = req.body;

        if (!parentId || !childId) {
            return res.status(400).json({
                success: 0,
                message: "Parent ID and Child ID are required",
            });
        }

        assignChildToParent(parentId, childId, (err, results) => {
            if (err) {
                console.error("Database Error:", err);
                return res.status(500).json({
                    success: 0,
                    message: "Database connection error",
                });
            }
            return res.status(200).json({
                success: 1,
                message: "Child assigned to parent successfully",
            });
        });
    },
    getChildrenByParent: (req, res) => {
        const parentId = req.params.parentId;

        if (!parentId) {
            return res.status(400).json({
                success: 0,
                message: "Parent ID is required",
            });
        }

        getChildrenByParentId(parentId, (err, results) => {
            if (err) {
                return res.status(500).json({
                    success: 0,
                    message: "Database connection error",
                });
            }
            return res.status(200).json({
                success: 1,
                data: results,
            });
        });
    },
    getParentsByChild: (req, res) => {
        const childId = req.params.childId;

        if (!childId) {
            return res.status(400).json({
                success: 0,
                message: "Child ID is required",
            });
        }

        getParentsByChildId(childId, (err, results) => {
            if (err) {
                return res.status(500).json({
                    success: 0,
                    message: "Database connection error",
                });
            }
            return res.status(200).json({
                success: 1,
                data: results,
            });
        });
    },
    assignChildToParent: async (req, res) => {
        try {
            const { parent_id, child_id } = req.body;
    
            if (!parent_id || !child_id) {
                return res.status(400).json({ success: false, message: "❌ Parent ID et Enfant ID sont requis" });
            }
    
            await assignParentChildRelation(parent_id, child_id);
            return res.status(200).json({ success: true, message: "✅ Enfant affecté avec succès" });
        } catch (error) {
            return res.status(400).json({ success: false, message: error.message });
        }
    },
    

    
     getChildrenByParent :(req, res) => {
        const parentId = req.params.parentId;
    
        if (!parentId) {
            return res.status(400).json({
                success: 0,
                message: "Parent ID is required",
            });
        }
    
        getChildrenByParentId(parentId, (err, results) => {
            if (err) {
                return res.status(500).json({
                    success: 0,
                    message: "Database connection error",
                });
            }
            return res.status(200).json({
                success: 1,
                data: results,
            });
        });
    },
    
     getParentsByChild : (req, res) => {
        const childId = req.params.childId;
    
        if (!childId) {
            return res.status(400).json({
                success: 0,
                message: "Child ID is required",
            });
        }
    
        getParentsByChildId(childId, (err, results) => {
            if (err) {
                return res.status(500).json({
                    success: 0,
                    message: "Database connection error",
                });
            }
            return res.status(200).json({
                success: 1,
                data: results,
            });
        });
    },
   

    };
