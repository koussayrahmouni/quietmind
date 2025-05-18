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
    
} = require("../controller/user.controller");

const router = require("express").Router();
const { checkToken } = require("../../auth/token_validation");

// Auth routes
router.post("/signup", signup); // Register new user
router.post("/login", login); // User login
router.get("/verify-email/:token", verifyEmail); // Verify email
router.post("/reset-password", resetUserPassword); // Reset password

// User routes (protected)
router.post("/", checkToken, createUser); // Create user
router.get("/", checkToken, getAllUsers); // Get all parents
router.get("/caregiver", checkToken, getAllUserss); // Get all caregivers
router.get("/:id", checkToken, getUserById); // Get user by ID
router.patch("/:id", checkToken, updateUser); // Update user
router.delete("/:id", checkToken, deleteUser); // Delete user
router.get("/email/:email", checkToken, getUserByEmailLogin); // Get user by email

// Parent & Caregiver management
router.get("/chappi", getAllParents);// flase 
router.post("/assignCaregiver", checkToken, assignCaregiver); // Assign caregiver to parent
router.get("/getCaregivers/:parentId", checkToken, getCaregiversByParent); // Get caregivers assigned to a parent

// ✅ Ensure routes are correctly mapped
router.post("/assignchild", assignChildToParent); // Assign child to parent
router.get("/children/:parentId",checkToken, getChildrenByParent); // Get children by parent
router.get("/parents/:childId",checkToken, getParentsByChild); // Get parents by child
router.get("/children/:parentId",checkToken, async (req, res) => {
    try {
        const parentId = req.params.parentId;
        console.log("Received parentId:", parentId); // Debugging

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

module.exports = router;
