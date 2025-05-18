const nodemailer = require("nodemailer");
require("dotenv").config();
const transporter = nodemailer.createTransport({
    service: "gmail",
    auth: {
        user: process.env.EMAIL_USER, 
        pass: process.env.EMAIL_PASS, 
    },
});
const sendVerificationEmail = async (email, token) => {
    try {
        const verificationLink = `http://localhost:3000/api/users/verify-email/${token}`; 

        const mailOptions = {
            from: process.env.EMAIL_USER,
            to: email,
            subject: "Vérification de votre compte",
            html: `<p>Cliquez sur ce lien pour vérifier votre email : <a href="${verificationLink}">${verificationLink}</a></p>`,
        };

        const info = await transporter.sendMail(mailOptions);
        console.log("Verification Email Sent:", info.response);
        return info;
    } catch (error) {
        console.error("Error Sending Verification Email:", error);
        throw error;
    }
};

const sendResetPasswordEmail = async (email, newPassword) => {
    try {
        const mailOptions = {
            from: process.env.EMAIL_USER,
            to: email,
            subject: "Password Reset - Quiet Mind",
            text: `Hello,\n\nYour new password is: ${newPassword}\n\nPlease log in and change your password immediately for security reasons.\n\nBest regards,\nQuiet Mind Team`,
        };

        const info = await transporter.sendMail(mailOptions);
        console.log("Password Reset Email Sent:", info.response);
        return info;
    } catch (error) {
        console.error("Error Sending Reset Password Email:", error);
        throw error;
    }
};

module.exports = { sendVerificationEmail, sendResetPasswordEmail };
