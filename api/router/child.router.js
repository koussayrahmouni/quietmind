const express = require("express");
const {
    createChild,
    getChildren,
    getChildById,
    updateChild,
    deleteChild,
    assignChildToParent,  
    getChildrenByParentId ,
    assignChildToCaregiver,
    getCaregiversByChildId,
    getChildrenByCaregiverId,
    deleteChildCaregiverAssignment ,
    getChildrenOfParent 
} = require("../controller/child.controller");
const childCtrl = require('../controller/child.controller');
const router = express.Router();
router.post("/", createChild);
router.put("/assign", assignChildToParent);
router.get("/", getChildren);
router.get("/parent/:parentId", getChildrenByParentId);
router.get("/:id", getChildById);
router.patch("/:id", updateChild);
router.delete("/:id", deleteChild);
router.post("/assign-caregiver", assignChildToCaregiver);
router.get("/:childId/caregivers", getCaregiversByChildId);
router.get("/caregiver/:caregiverId", getChildrenByCaregiverId);
router.delete("/unassign-caregiver/:childId/:caregiverId", deleteChildCaregiverAssignment);
router.patch('/children/:id', childCtrl.updateParent);
router.get('/parent/:parent_id/children', getChildrenOfParent);


module.exports = router;
