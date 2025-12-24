const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");

admin.initializeApp();

exports.notifyWorkersOnRequest = onDocumentCreated(
  "requests/{requestId}",
  async (event) => {

    const requestData = event.data.data();
    const requestId = event.params.requestId;

    console.log("🔥 New request:", requestId);

    // ✅ READ FROM USERS (WORKERS)
    const workersSnap = await admin.firestore()
      .collection("users")
      .where("role", "==", "worker")
      .where("categoryId", "==", requestData.categoryId)
      .get();

    if (workersSnap.empty) {
      console.log("⚠ No workers found");
      return;
    }

    const tokens = [];

    workersSnap.forEach(doc => {
      const token = doc.data().fcmToken;
      if (token) tokens.push(token);
    });

    if (tokens.length === 0) {
      console.log("⚠ No FCM tokens found");
      return;
    }

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

    console.log("✅ Notification sent to", tokens.length, "workers");
  }
);