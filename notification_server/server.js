const express = require("express");
const admin = require("firebase-admin");
const cors = require("cors");

const app = express();
app.use(express.json());
app.use(cors());

// LOAD FIREBASE PRIVATE KEY
const serviceAccount = require("./smart-canteen-eae33-firebase-adminsdk-fbsvc-e30c31723a.json");

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