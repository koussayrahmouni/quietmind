const { verify } = require("jsonwebtoken");

module.exports = {
    checkToken: (req, res, next) => {
        let token = req.get("authorization");

        if (token) {
            if (token.startsWith("Bearer ")) {
                token = token.slice(7); // Supprimer "Bearer " du token
            }

            verify(token, "qwe1234", (err, decoded) => {
                if (err) {
                    return res.status(401).json({
                        success: 0,
                        message: "Invalid token",
                    });
                }

                req.user = decoded; // Stocker les infos du token dans `req.user`
                next(); // Passer à la prochaine fonction middleware
            });
        } else {
            return res.status(403).json({
                success: 0,
                message: "Access denied! Unauthorized user!",
            });
        }
    },
};
