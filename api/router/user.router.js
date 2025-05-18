const { 
    createUser, 
    getUserById,
    getAllUsers,
    getAllUserss,
    updateUser,
    deleteUser,
    login,
    signup, 
    verifyEmail,
    resetUserPassword,
    getUserByEmailLogin,
    getAllParents,
    assignCaregiver,
    getCaregiversByParent ,
    assignChild,
    getChildrenByParent,
    getParentsByChild,
    assignChildToParent, 
    getAllParentChild,
    getUsersss 
    
} = require("../controller/user.controller");
const router = require("express").Router();
const userController = require("../controller/user.controller");

const { checkToken } = require("../../auth/token_validation");

router.post("/users/assign-child", userController.assignChildToParent);
router.delete("/users/unassign-child/:child_id/:parent_id", userController.unassignChildFromParent);
router.post("/signup", signup); 
router.post("/login", login); 
router.get("/verify-email/:token", verifyEmail); 
router.post("/reset-password", resetUserPassword);
router.post("/", checkToken, createUser); 
router.get("/", checkToken, getAllUsers); 
router.get("/caregiver", checkToken, getAllUserss); 
router.get("/:id", checkToken, getUserById); 
router.patch("/:id", checkToken, updateUser); 
router.delete("/:id", checkToken, deleteUser); 
router.get("/email/:email", checkToken, getUserByEmailLogin);
router.get("/chappi", getAllParents);// flase 
router.post("/assignCaregiver", checkToken, assignCaregiver);
router.get("/getCaregivers/:parentId", checkToken, getCaregiversByParent); 
router.post("/assign-child", assignChildToParent); 
router.get("/children/:parentId",checkToken, getChildrenByParent); 
router.get("/parents/:childId",checkToken, getParentsByChild); 
router.get("/", getUsersss);



router.get("/children/:parentId",checkToken, async (req, res) => {
    try {
        const parentId = req.params.parentId;
        console.log("Received parentId:", parentId); 
        if (!parentId || parentId === "null") {
            return res.status(400).json({ success: 0, message: "Parent ID is required" });
        }

        const parent = await User.findById(parentId);
        if (!parent) {
            return res.status(404).json({ success: 0, message: "User not found" });
        }

        const children = await User.find({ parentId: parentId });
        res.json({ success: 1, children });
    } catch (error) {
        console.error("Error fetching children:", error);
        res.status(500).json({ success: 0, message: "Internal Server Error" });
    }
});
router.get("/parent-child", getAllParentChild);


module.exports = router;
