const { onRequest } = require("firebase-functions/v2/https");
const admin = require("firebase-admin");
const axios = require("axios");
const crypto = require("crypto");

// Initialize Admin (Agar pehle nahi kiya)
if (admin.apps.length === 0) {
    admin.initializeApp();
}

const SAFE_PAY_PUBLIC_KEY = "sec_66e8644c-ec55-4267-be74-826165c2f8d0";
const SAFE_PAY_WEBHOOK_SECRET = "943af9acf958cb03780be46fd5f0629ba11c33db098ec515a382eb743ebccd18"; 

// 1. Checkout URL banane wala function
exports.createSafepayCheckout = onRequest({ cors: true }, async (req, res) => {
    const { amount, workerId } = req.body;

    if (!amount || !workerId) {
        return res.status(400).send("Missing amount or workerId");
    }

    try {
        const response = await axios.post("https://sandbox.api.getsafepay.com/order/v1/init", {
            client: SAFE_PAY_PUBLIC_KEY,
            amount: amount,
            currency: "PKR",
            environment: "sandbox"
        });

        const token = response.data.data.token;

        // Final Correct Sandbox URL
        const checkoutUrl = `https://sandbox.api.getsafepay.com/checkout/pay` + 
                            `?beacon=${token}` + 
                            `&amount=${amount}` + 
                            `&currency=PKR` + 
                            `&worker_id=${workerId}` + 
                            `&env=sandbox`;

        console.log(`✅ Checkout Created for Worker: ${workerId}, Amount: ${amount}`);
        res.status(200).send({ url: checkoutUrl });
    } catch (error) {
        console.error("❌ Safepay Init Error:", error.response ? error.response.data : error.message);
        res.status(500).send("Checkout error");
    }
});

// 2. Wallet Update karne wala function (Webhook)
exports.safepayWebhook = onRequest({ cors: true }, async (req, res) => {
    const data = req.body;
    
    console.log("🔔 Webhook Payload:", JSON.stringify(data));

    // Safepay Sandbox aksar payment success par status 'TRACKER_ENDED' bhejta hai
    if (data.state === "TRACKER_ENDED" || data.status === "success") {
        
        // ✨ Worker ID dhoondne ka behtar tareeqa
        // Pehle URL parameters (req.query) check karega, phir body data (data.worker_id)
        const workerId = req.query.worker_id || data.worker_id || (data.metadata ? data.metadata.worker_id : null);
        const amount = parseFloat(data.amount);

        console.log(`🔍 Processing for Worker: ${workerId}, Amount: ${amount}`);

        if (!workerId) {
            console.error("❌ Worker ID missing in all locations!");
            return res.status(400).send("Worker ID not found");
        }

        const workerRef = admin.firestore().collection("users").doc(workerId);

        try {
            await admin.firestore().runTransaction(async (t) => {
                const doc = await t.get(workerRef);
                if (!doc.exists) throw new Error("Worker doc missing");

                const currentBalance = (doc.data().walletAmount || 0);
                t.update(workerRef, { walletAmount: currentBalance + amount });

                const historyRef = admin.firestore().collection("wallet_history").doc();
                t.set(historyRef, {
                    workerId,
                    amount,
                    type: "deposit",
                    timestamp: admin.firestore.FieldValue.serverTimestamp()
                });
            });

            console.log("✅ Wallet Updated Successfully!");
            return res.status(200).send("OK");
        } catch (e) {
            console.error("❌ DB Error:", e.message);
            return res.status(500).send("DB Update Failed");
        }
    } else {
        return res.status(200).send("Status not success, ignored.");
    }
});