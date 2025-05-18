const nodemailer = require("nodemailer");

const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    type: "OAuth2",
    user: "benmradmeriem@gmail.com",
    clientId: "539268364787-9575cla69celg37lq8kh0qo9kj7bf38b.apps.googleusercontent.com",
    clientSecret: "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",
   
  },
});

const sendAlertEmail = (to, subject, text) => {
  const mailOptions = {
    from: "benmradmeriem@gmail.com",
    to,
    subject,
    text,
  };

  transporter.sendMail(mailOptions, (error, info) => {
    if (error) {
      console.error("Erreur lors de l'envoi de l'e-mail :", error);
    } else {
      console.log("E-mail envoyé :", info.response);
    }
  });
};

module.exports = sendAlertEmail;