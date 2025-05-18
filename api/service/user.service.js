const pool = require('../../config/database');
const { genSaltSync, hashSync } = require("bcrypt");
const { sendResetPasswordEmail } = require("../service/email.service");




function generateRandomPassword(length = 6) {
    const chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
    let password = "";
    for (let i = 0; i < length; i++) {
        password += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    return password;
}

module.exports = {
    create: (data, callBack) => {
        // Vérifier si l'email existe déjà
        const checkEmailQuery = `SELECT id FROM users WHERE email = ?`;
    
        pool.query(checkEmailQuery, [data.email], (error, results) => {
            if (error) {
                return callBack(error);
            }
            
            if (results.length > 0) {
                // Email déjà existant
                return callBack(null, { emailExists: true });
            }
    
            // Si l'email n'existe pas, on ajoute l'utilisateur
            const insertQuery = `
                INSERT INTO users (firstName, lastName, email, password, role, phone , etat)
                VALUES (?, ?, ?, ?, ?, ?,?)
            `;
    
            pool.query(insertQuery, [
                data.firstName,
                data.lastName,
                data.email,
                data.password,
                data.role,
                data.phone,
                data.etat
            ], (error, results) => {
                if (error) {
                    return callBack(error);
                }
                return callBack(null, results);
            });
        });
    },
    getUsers: (callBack) => {
        pool.query(
            `SELECT id, firstName, lastName, email, role, phone ,etat FROM users where role ='parents'`,
            [],
            (error, results) => {
                if (error) {
                    return callBack(error);
                }
                return callBack(null, results); // Renvoie l'ensemble des résultats
            }
        );
    },
    getUserss :(callBack) => {
        pool.query(
            `SELECT id, firstName, lastName, email, role, phone, etat FROM users WHERE role ='caregiver'`,
            [],
            (error, results) => {
                if (error) {
                    return callBack(error);
                }
                return callBack(null, results);
            }
        );
    },
    getUsersById: (id, callBack) => {
        const query = `SELECT id, firstName, lastName, email, role, phone,etat FROM users WHERE id = ?`;

        pool.query(query, [id], (error, results) => {
            if (error) {
                return callBack(error);
            }
            return callBack(null, results.length ? results[0] : null); // Vérifie s'il y a un résultat
        });
    },
    updateUser: (data, callBack) => {
        // Vérification des champs avant de mettre à jour
        const fieldsToUpdate = [
            { field: 'firstName', value: data.firstName },
            { field: 'lastName', value: data.lastName },
            { field: 'email', value: data.email },
            { field: 'phone', value: data.phone },
            { field: 'role', value: data.role },  // Assurez-vous que "role" et "etat" existent dans le corps de la requête
            { field: 'etat', value: data.etat },
        ];
    
        // Filtrer les champs qui ne sont pas null ou indéfinis
        const setValues = [];
        const setFields = [];
    
        fieldsToUpdate.forEach(({ field, value }) => {
            if (value !== undefined && value !== null) {
                setFields.push(`${field} = ?`);
                setValues.push(value);
            }
        });
    
        if (setFields.length === 0) {
            return callBack(null, null); // Aucun champ à mettre à jour
        }
    
        setValues.push(data.id); // Ajout de l'ID à la fin des valeurs
    
        const query = `
            UPDATE users 
            SET ${setFields.join(', ')}
            WHERE id = ?
        `;
        
        pool.query(query, setValues, (error, results) => {
            if (error) {
                return callBack(error);
            }
    
            // Vérifier si des lignes ont été affectées (i.e., si l'utilisateur existe)
            if (results.affectedRows === 0) {
                return callBack(null, null); // Aucun utilisateur trouvé
            }
    
            return callBack(null, results);
        });
    },
    
    deleteUser: (id, callBack) => {
        pool.query(
            `DELETE FROM users WHERE id = ?`,
            [id],
            (error, results) => {
                if (error) {
                    return callBack(error);
                }
                return callBack(null, results);
            }
        );
    },
    getUserByEmail: (email, callBack) => {
        const query = `SELECT * FROM users WHERE email = ?`;
    
        pool.query(query, [email], (error, results) => {
            if (error) {
                return callBack(error);
            }
    
            if (results.length === 0) {
                return callBack(null, null); // Aucun utilisateur trouvé
            }
    
            return callBack(null, results[0]); // Retourner un seul utilisateur
        });
    },
    verifyUserEmail: (email, callBack) => {
        const query = `UPDATE users SET email_verified = 1 WHERE email = ?`;
    
        pool.query(query, [email], (error, results) => {
            if (error) {
                return callBack(error);
            }
            return callBack(null, results);
        });
    },
    resetPassword: (email, callBack) => {
        const query = `SELECT id FROM users WHERE email = ?`;

        pool.query(query, [email], (error, results) => {
            if (error) {
                return callBack(error);
            }

            if (results.length === 0) {
                return callBack(null, null); // No user found
            }

            const newPassword = generateRandomPassword();
            const salt = genSaltSync(10);
            const hashedPassword = hashSync(newPassword, salt);

            const updateQuery = `UPDATE users SET password = ? WHERE email = ?`;

            pool.query(updateQuery, [hashedPassword, email], (error, updateResults) => {
                if (error) {
                    return callBack(error);
                }

                // Send email with the new password
                sendResetPasswordEmail(email, newPassword)
                    .then(() => callBack(null, updateResults))
                    .catch(emailError => callBack(emailError));
            });
        });
    },
    getParents: (callBack) => {
        const query = `SELECT id, firstName, lastName, email, role, phone, etat FROM users WHERE role = ?`;

        pool.query(query, ["parent"], (error, results) => {
            if (error) {
                return callBack(error);
            }
            return callBack(null, results);
        });
    },
    getChildrenByParentId: (parentId, callBack) => {
        pool.query(
            `SELECT * FROM child WHERE parent_id = ?`,
            [parentId],
            (error, results) => {
                if (error) {
                    return callBack(error);
                }
                return callBack(null, results);
            }
        );
    },
    assignCaregiverToParent: (parentId, caregiverId, callBack) => {
        const query = `INSERT INTO parent_caregiver (parent_id, caregiver_id) VALUES (?, ?)`;

        pool.query(query, [parentId, caregiverId], (error, results) => {
            if (error) {
                return callBack(error);
            }
            return callBack(null, results);
        });
    },
    getCaregiversByParentId: (parentId, callBack) => {
        const query = `
            SELECT u.id, u.firstName, u.lastName, u.email, u.phone 
            FROM users u
            JOIN parent_caregiver pc ON u.id = pc.caregiver_id
            WHERE pc.parent_id = ?`;

        pool.query(query, [parentId], (error, results) => {
            if (error) {
                return callBack(error);
            }
            return callBack(null, results);
        });
    },
    getAllParents: (callBack) => {
        const query = `SELECT * FROM users WHERE role = 'parents'`;

        pool.query(query, [], (error, results) => {
            if (error) {
                return callBack(error);
            }

            if (results.length === 0) {
                return callBack(null, null); // No parents found
            }

            return callBack(null, results);
        });
    },
    assignParentChildRelation: async (parent_id, child_id) => {
        return new Promise((resolve, reject) => {
            // Vérifier si l'un des ID est déjà utilisé
            const checkQuery = `SELECT * FROM parent_child WHERE parent_id = ? OR child_id = ?`;
            pool.query(checkQuery, [parent_id, child_id], (err, results) => {
                if (err) {
                    return reject(err);
                } 
    
                // Insérer la relation si elle n'existe pas encore
                const insertQuery = `INSERT INTO parent_child (parent_id, child_id) VALUES (?, ?)`;
                pool.query(insertQuery, [parent_id, child_id], (err, result) => {
                    if (err) {
                        return reject(err);
                    }
                    resolve(result);
                });
            });
        });
    },
    
    
     getChildrenByParentId : (parentId, callBack) => {
        const query = `
            SELECT c.id, c.FirstName, c.LastName, c.Age, c.Gender ,c.AutonomyLevel,c.SensoryPreferences	,c.FavoriteInterests,c.ModeOfCommunication,c.CalmingStrategies,c.AllergiesOrDietaryRestrictions
            FROM child c
            JOIN parent_child pc ON c.id = pc.child_id
            WHERE pc.parent_id = ?`;
    
        pool.query(query, [parentId], (error, results) => {
            if (error) {
                return callBack(error);
            }
            return callBack(null, results);
        });
    },
    
     getParentsByChildId :(childId, callBack) => {
        const query = `
            SELECT u.id, u.firstName, u.lastName, u.email, u.phone
            FROM users u
            JOIN parent_child pc ON u.id = pc.parent_id
            WHERE pc.child_id = ?`;
    
        pool.query(query, [childId], (error, results) => {
            if (error) {
                return callBack(error);
            }
            return callBack(null, results);
        });
    },
    // user.service.js
    getAllParentChildRelations :(callBack) => {
        const query = "SELECT * FROM parent_child";
    
        pool.query(query, (error, results) => {
            if (error) {
                return callBack(error);
            }
            return callBack(null, results);
        });
    },

    getUsersss: (callBack) => {
        // SQL query to fetch users ordered by role in a custom way (admin, caregiver, parent)
        const getUsersQuery = `
            SELECT id, firstName, lastName, email, phone, role, etat
            FROM users
            ORDER BY 
                CASE 
                    WHEN role = 'admin' THEN 1
                    WHEN role = 'caregiver' THEN 2
                    WHEN role = 'parent' THEN 3
                    ELSE 4 
                END
        `;
    
        pool.query(getUsersQuery, (error, results) => {
            if (error) {
                return callBack(error);
            }
            return callBack(null, results);
        });
    },
    
    
    

    
    
};
