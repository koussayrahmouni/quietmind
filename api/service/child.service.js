const pool = require("../../config/database");

module.exports = {
    create: (data, callBack) => {
        const insertQuery = `
            INSERT INTO child (
                LastName,
                FirstName,
                Age,
                Gender,
                AutonomyLevel,
                SensoryPreferences,
                FavoriteInterests,
                ModeOfCommunication,
                CalmingStrategies,
                AllergiesOrDietaryRestrictions,
                parent_id,
                created_at
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())
        `;

        pool.query(insertQuery, [
            data.LastName,
            data.FirstName,
            data.Age,
            data.Gender,
            data.AutonomyLevel,
            data.SensoryPreferences,
            data.FavoriteInterests,
            data.ModeOfCommunication,
            data.CalmingStrategies,
            data.AllergiesOrDietaryRestrictions,
            data.parent_id
        ], (error, results) => {
            if (error) {
                return callBack(error);
            }
            return callBack(null, { id: results.insertId, ...data });
        });
    },

    // Assign a child to a parent
    assignChildToParent: (childId, parentId, callBack) => {
        const query = `UPDATE child SET parent_id = ? WHERE id = ?`;

        pool.query(query, [parentId, childId], (error, results) => {
            if (error) {
                return callBack(error);
            }
            return callBack(null, results.affectedRows ? "Child assigned to parent successfully" : null);
        });
    },

    // Get all children with their parents' info
    getChilds: (callBack) => {
        pool.query(
            `SELECT 
                c.id, 
                c.LastName,
                c.FirstName,
                c.Age,
                c.Gender,
                c.AutonomyLevel,
                c.SensoryPreferences,
                c.FavoriteInterests,
                c.ModeOfCommunication,
                c.CalmingStrategies,
                c.AllergiesOrDietaryRestrictions,
                c.created_at,
                u.id AS parent_id,
                u.firstName AS parent_firstName,
                u.lastName AS parent_lastName,
                u.email AS parent_email,
                u.phone AS parent_phone
            FROM child c
            LEFT JOIN users u ON c.parent_id = u.id`,
            [],
            (error, results) => {
                if (error) {
                    return callBack(error);
                }
                return callBack(null, results);
            }
        );
    },

    // Get a specific child's parent
    getParentByChildId: (childId, callBack) => {
        pool.query(
            `SELECT u.id, u.firstName, u.lastName, u.email, u.phone 
            FROM users u
            JOIN child c ON u.id = c.parent_id
            WHERE c.id = ?`,
            [childId],
            (error, results) => {
                if (error) {
                    return callBack(error);
                }
                return callBack(null, results.length ? results[0] : null);
            }
        );
    },

    getChildsByParentId: (parentId, callBack) => {
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

    getChildsById: (id, callBack) => {
        pool.query(
            `SELECT * FROM child WHERE id = ?`,
            [id],
            (error, results) => {
                if (error) {
                    return callBack(error);
                }
                return callBack(null, results.length ? results[0] : null);
            }
        );
    },

    updateChild: (data, callBack) => {
        const query = `
            UPDATE child 
            SET 
                LastName = ?, 
                FirstName = ?, 
                Age = ?, 
                Gender = ?, 
                AutonomyLevel = ?, 
                SensoryPreferences = ?, 
                FavoriteInterests = ?, 
                ModeOfCommunication = ?, 
                CalmingStrategies = ?, 
                AllergiesOrDietaryRestrictions = ?, 
                parent_id = ?, 
                created_at = NOW()
            WHERE id = ?`;

        pool.query(query, [
            data.LastName,
            data.FirstName,
            data.Age,
            data.Gender,
            data.AutonomyLevel,
            data.SensoryPreferences,
            data.FavoriteInterests,
            data.ModeOfCommunication,
            data.CalmingStrategies,
            data.AllergiesOrDietaryRestrictions,
            data.parent_id,
            data.id
        ], (error, results) => {
            if (error) {
                return callBack(error);
            }
            return callBack(null, results.affectedRows ? "Child updated successfully" : null);
        });
    },

    deleteChild: (id, callBack) => {
        pool.query(
            `DELETE FROM child WHERE id = ?`,
            [id],
            (error, results) => {
                if (error) {
                    return callBack(error);
                }
                return callBack(null, results.affectedRows ? "Child deleted successfully" : null);
            }
        );
    },
    assignChildToCaregiver: (childId, caregiverId, callBack) => {
        const query = `INSERT INTO child_caregiver (child_id, caregiver_id) VALUES (?, ?)`;
    
        pool.query(query, [childId, caregiverId], (error, results) => {
            if (error) {
                return callBack(error);
            }
            return callBack(null, "Child assigned to caregiver successfully");
        });
    },
    
    // Get caregivers assigned to a child
    getCaregiversByChildId: (childId, callBack) => {
        const query = `
            SELECT u.id, u.firstName, u.lastName, u.email, u.phone 
            FROM users u
            JOIN child_caregiver cc ON u.id = cc.caregiver_id
            WHERE cc.child_id = ?`;
    
        pool.query(query, [childId], (error, results) => {
            if (error) {
                return callBack(error);
            }
            return callBack(null, results);
        });
    },
    
    // Get children assigned to a caregiver
    getChildrenByCaregiverId: (caregiverId, callBack) => {
        const query = `
            SELECT c.id, c.FirstName, c.LastName, c.Age, c.Gender 
            FROM child c
            JOIN child_caregiver cc ON c.id = cc.child_id
            WHERE cc.caregiver_id = ?`;
    
        pool.query(query, [caregiverId], (error, results) => {
            if (error) {
                return callBack(error);
            }
            return callBack(null, results);
        });
    },
    deleteAssignment: (child_id, caregiver_id, callBack) => {
        const checkQuery = `SELECT * FROM child_caregiver WHERE child_id = ? AND caregiver_id = ?`;
    
        pool.query(checkQuery, [child_id, caregiver_id], (error, results) => {
            if (error) {
                return callBack(error);
            }
    
            console.log("🔍 Checking if assignment exists:", results); // Log the result
    
            if (results.length === 0) {
                console.warn("⚠️ No matching assignment found for child_id:", child_id, "and caregiver_id:", caregiver_id);
                return callBack(null, { affectedRows: 0 });
            }
    
            const deleteQuery = `DELETE FROM child_caregiver WHERE child_id = ? AND caregiver_id = ?`;
            pool.query(deleteQuery, [child_id, caregiver_id], (error, results) => {
                if (error) {
                    return callBack(error);
                }
    
                console.log("✅ Assignment deleted:", results);
                return callBack(null, results);
            });
        });
    },
    
    
    
    
    
};
