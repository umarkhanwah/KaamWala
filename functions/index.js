const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");

admin.initializeApp();

exports.notifyWorkersOnRequest = onDocumentCreated(
  "requests/{requestId}",
  async (event) => {

    const requestData = event.data.data();
    const requestId = event.params.requestId;

    console.log("🔥 New request:", requestId);

    // 🔹 Fetch matching workers
    const workersSnap = await admin.firestore()
      .collection("workers")
      .where("categoryId", "==", requestData.categoryId)
      .get();

    if (workersSnap.empty) return;

    const tokens = [];
    workersSnap.forEach(doc => {
      if (doc.data().fcmToken) {
        tokens.push(doc.data().fcmToken);
      }
    });

    if (tokens.length === 0) return;

    // 🔹 Send FCM
    await admin.messaging().sendEachForMulticast({
      tokens,
      notification: {
        title: "New Job Request",
        body: requestData.serviceName,
      },
      data: {
        screen: "worker_notification",
        requestId: requestId,
      },
    });

    console.log("✅ Notification sent");
  }
);
