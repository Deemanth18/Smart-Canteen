const express = require("express");
const admin = require("firebase-admin");
const cors = require("cors");
require("dotenv").config();

const app = express();
app.use(express.json());
app.use(cors());

// LOAD FIREBASE PRIVATE KEY FROM ENV
const serviceAccount = {
  type: process.env.FIREBASE_TYPE,
  project_id: process.env.FIREBASE_PROJECT_ID,
  private_key_id: process.env.FIREBASE_PRIVATE_KEY_ID,
  private_key: process.env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n'),
  client_email: process.env.FIREBASE_CLIENT_EMAIL,
  client_id: process.env.FIREBASE_CLIENT_ID,
  auth_uri: process.env.FIREBASE_AUTH_URI,
  token_uri: process.env.FIREBASE_TOKEN_URI,
  auth_provider_x509_cert_url: process.env.FIREBASE_AUTH_PROVIDER_X509_CERT_URL,
  client_x509_cert_url: process.env.FIREBASE_CLIENT_X509_CERT_URL,
  universe_domain: process.env.FIREBASE_UNIVERSE_DOMAIN,
};

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

// TEST ROUTE
app.get("/", (req, res) => {
  res.send("Notification Server Running");
});

// SEND NOTIFICATION ROUTE
app.post("/sendNotification", async (req, res) => {
  console.log("Notification request received");

  const token = req.body.token;

  console.log("Token:", token);

  const message = {
    notification: {
      title: "Smart Canteen",
      body: "Your order is ready! Please collect it.",
    },
    token: token,
  };

  try {
    await admin.messaging().send(message);
    console.log("Notification sent successfully");
    res.send("Notification sent");
  } catch (error) {
    console.log("Error sending notification:", error);
    res.status(500).send(error);
  }
});

// START SERVER
app.listen(3000, () => {
  console.log("Notification server running on port 3000");
});