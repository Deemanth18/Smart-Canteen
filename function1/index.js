const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.orderReadyNotification =
functions.database.ref("/orders/{orderId}/status")
.onUpdate(async (change, context) => {

  const newStatus = change.after.val();

  if (newStatus !== "Ready") {
    return null;
  }

  const orderId = context.params.orderId;

  const orderSnapshot =
  await admin.database().ref(`/orders/${orderId}`).once("value");

  const order = orderSnapshot.val();
  const userId = order.userId;

  const userSnapshot =
  await admin.database().ref(`/users/${userId}`).once("value");

  const userData = userSnapshot.val();
  const token = userData.token;

  const payload = {
    notification: {
      title: "Smart Canteen",
      body: "Your order is ready! Please collect it."
    }
  };

  return admin.messaging().sendToDevice(token, payload);

});