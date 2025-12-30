
const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");

// Initialize Admin sirf aik baar index.js mein
if (admin.apps.length === 0) {
    admin.initializeApp();
}

exports.notifyWorkersOnRequest = onDocumentCreated(
  "requests/{requestId}",
  async (event) => {

    const requestData = event.data.data();
    const requestId = event.params.requestId;

    console.log("🔥 New request:", requestId);

    // ✅ UPDATED QUERY: Added status check for "approved"
    const workersSnap = await admin.firestore()
      .collection("users")
      .where("role", "==", "worker")
      .where("categoryId", "==", requestData.categoryId)
      .where("status", "==", "approved") // 👈 Yeh line add ki gayi hai
      .get();

    if (workersSnap.empty) {
      console.log("⚠ No approved workers found for this category");
      return;
    }

    const tokens = [];

    workersSnap.forEach(doc => {
      const token = doc.data().fcmToken;
      if (token) tokens.push(token);
    });

    if (tokens.length === 0) {
      console.log("⚠ No FCM tokens found for approved workers");
      return;
    }

    try {
      await admin.messaging().sendEachForMulticast({
        tokens,
        notification: {
          title: "New Job Request",
          body: requestData.serviceName,
        },
        data: {
          screen: "worker_notification",
          requestId,
        },
      });
      console.log("✅ Notification sent to", tokens.length, "approved workers");
    } catch (error) {
      console.error("❌ Error sending notification:", error);
    }
  }
);

// --- Safepay Functions ko Import/Export karein ---
const payments = require("./payments");
exports.createSafepayCheckout = payments.createSafepayCheckout;
exports.safepayWebhook = payments.safepayWebhook;