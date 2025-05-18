const {
    create,
    getChilds,
    getChildsById,
    updateChild,
    deleteChild,
    assignChildToParent,
    getChildsByParentId,
    assignChildToCaregiver,
    getCaregiversByChildId,
    getChildrenByCaregiverId,
    deleteAssignment 
} = require("../service/child.service");

module.exports = {
    createChild: (req, res) => {
        create(req.body, (error, results) => {
            if (error) {
                return res.status(500).json({ success: false, message: "Database error", error });
            }
            return res.status(201).json({ success: true, data: results });
        });
    },
    getChildren: (req, res) => {
        getChilds((error, results) => {
            if (error) {
                return res.status(500).json({ success: false, message: "Database error", error });
            }
            return res.status(200).json({ success: true, data: results });
        });
    },
    getChildById: (req, res) => {
        getChildsById(req.params.id, (error, results) => {
            if (error) {
                return res.status(500).json({ success: false, message: "Database error", error });
            }
            if (!results) {
                return res.status(404).json({ success: false, message: "Child not found" });
            }
            return res.status(200).json({ success: true, data: results });
        });
    },
    assignChildToParent: (req, res) => {
        const { childId, parentId } = req.body;
        if (!childId || !parentId) {
            return res.status(400).json({ success: false, message: "Child ID and Parent ID are required" });
        }

        assignChildToParent(childId, parentId, (error, results) => {
            if (error) {
                return res.status(500).json({ success: false, message: "Database error", error });
            }
            return res.status(200).json({ success: true, message: "Child assigned to parent successfully" });
        });
    },
    getChildrenByParentId: (req, res) => {
        const parentId = req.params.parentId;
        getChildsByParentId(parentId, (error, results) => {
            if (error) {
                return res.status(500).json({ success: false, message: "Database error", error });
            }
            return res.status(200).json({ success: true, data: results });
        });
    },
    updateChild: (req, res) => {
        const data = { id: req.params.id, ...req.body };
        updateChild(data, (error, results) => {
            if (error) {
                return res.status(500).json({ success: false, message: "Database error", error });
            }
            if (!results) {
                return res.status(404).json({ success: false, message: "Child not found" });
            }
            return res.status(200).json({ success: true, message: "Child updated successfully" });
        });
    },
    deleteChild: (req, res) => {
        deleteChild(req.params.id, (error, results) => {
            if (error) {
                return res.status(500).json({ success: false, message: "Database error", error });
            }
            if (!results) {
                return res.status(404).json({ success: false, message: "Child not found" });
            }
            return res.status(200).json({ success: true, message: "Child deleted successfully" });
        });
    },
    assignChildToCaregiver: (req, res) => {
        const { childId, caregiverId } = req.body;
        if (!childId || !caregiverId) {
            return res.status(400).json({ success: false, message: "Child ID and Caregiver ID are required" });
        }

        assignChildToCaregiver(childId, caregiverId, (error, results) => {
            if (error) {
                return res.status(500).json({ success: false, message: "Database error", error });
            }
            return res.status(200).json({ success: true, message: results });
        });
    },
    getCaregiversByChildId: (req, res) => {
        getCaregiversByChildId(req.params.childId, (error, results) => {
            if (error) {
                return res.status(500).json({ success: false, message: "Database error", error });
            }
            return res.status(200).json({ success: true, data: results });
        });
    },
    getChildrenByCaregiverId: (req, res) => {
        getChildrenByCaregiverId(req.params.caregiverId, (error, results) => {
            if (error) {
                return res.status(500).json({ success: false, message: "Database error", error });
            }
            return res.status(200).json({ success: true, data: results });
        });
    },
     deleteChildCaregiverAssignment : (req, res) => {
        console.log("🔹 Requête reçue :", req.params);  // DEBUG
    
        const { childId, caregiverId } = req.params;
    
        if (!childId || !caregiverId) {
            console.log("⚠️ ID manquant dans la requête !");
            return res.status(400).json({ success: false, message: "Child ID and Caregiver ID are required" });
        }
    
        deleteAssignment(childId, caregiverId, (error, results) => {
            if (error) {
                return res.status(500).json({ success: false, message: "Database error", error });
            }
    
            if (results.affectedRows === 0) {
                return res.status(404).json({ success: false, message: "Child-caregiver assignment not found" });
            }
    
            return res.status(200).json({ success: true, message: "Assignment deleted successfully" });
        });
    },
    
    
    
    

};
