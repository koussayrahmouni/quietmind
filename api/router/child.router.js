const express = require("express");
const {
    createChild,
    getChildren,
    getChildById,
    updateChild,
    deleteChild,
    assignChildToParent,  // Import the new controller function
    getChildrenByParentId ,// Import to get children of a specific parent
    assignChildToCaregiver,
    getCaregiversByChildId,
    getChildrenByCaregiverId,
    deleteChildCaregiverAssignment 
} = require("../controller/child.controller");

const router = express.Router();

// Route to create a new child
router.post("/", createChild);

// Route to assign a child to a parent
router.put("/assign", assignChildToParent);

// Route to get all children
router.get("/", getChildren);

// Route to get all children of a specific parent
router.get("/parent/:parentId", getChildrenByParentId);

// Route to get a single child by ID
router.get("/:id", getChildById);

// Route to update a child's details
router.patch("/:id", updateChild);

// Route to delete a child
router.delete("/:id", deleteChild);
router.post("/assign-caregiver", assignChildToCaregiver);

// Route to get all caregivers of a specific child
router.get("/:childId/caregivers", getCaregiversByChildId);

// Route to get all children assigned to a caregiver
router.get("/caregiver/:caregiverId", getChildrenByCaregiverId);

router.delete("/unassign-caregiver/:childId/:caregiverId", deleteChildCaregiverAssignment);


module.exports = router;
