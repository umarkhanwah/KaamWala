const { onRequest } = require("firebase-functions/v2/https");
const admin = require("firebase-admin");
const axios = require("axios");
const crypto = require("crypto"); // Security signature verify karne ke liye

const SAFE_PAY_PUBLIC_KEY = "sec_66e8644c-ec55-4267-be74-826165c2f8d0";
// Dashboard -> Webhooks se Webhook Secret copy karke yahan lagayein
const SAFE_PAY_WEBHOOK_SECRET = "943af9acf958cb03780be46fd5f0629ba11c33db098ec515a382eb743ebccd18"; 

exports.createSafepayCheckout = onRequest(async (req, res) => {
    const { amount, workerId } = req.body;

    try {
        const response = await axios.post("https://sandbox.api.getsafepay.com/order/v1/init", {
            client: SAFE_PAY_PUBLIC_KEY,
            amount: amount,
            currency: "PKR",
            environment: "sandbox"
        });

        const token = response.data.data.token;
        
        // Success hone par worker_id ko URL parameters mein pass karna zaroori hai
        // Taake webhook ko pata chale kis worker ka balance barhana hai
        const checkoutUrl = `https://sandbox.api.getsafepay.com/checkout/pay?bid=${token}&amount=${amount}&currency=PKR&worker_id=${workerId}`;

        res.status(200).send({ url: checkoutUrl });
    } catch (error) {
        console.error("Safepay Init Error:", error);
        res.status(500).send("Checkout error");
    }
});

exports.safepayWebhook = onRequest(async (req, res) => {
    // 1. Security Check (Signature Verification)
    // Yeh step zaroori hai taake koi fake request bhej kar balance na barha sake
    const signature = req.headers["x-sfpy-signature"];
    const payload = JSON.stringify(req.body);
    
    // Agar aapne Webhook Secret set kiya hai, to yahan verify karein:
    /*
    const expectedSignature = crypto.createHmac('sha256', SAFE_PAY_WEBHOOK_SECRET).update(payload).digest('hex');
    if (signature !== expectedSignature) {
        return res.status(401).send("Invalid Signature");
    }
    */

    const data = req.body;
    
    // Safepay "TRACKER_ENDED" tab bhejta hai jab payment successfully mukammal ho jaye
    if (data.state === "TRACKER_ENDED") {
        // Humne URL mein worker_id bheja tha, wo req.query se milega
        const workerId = req.query.worker_id; 
        const amount = parseFloat(data.amount);

        if (!workerId) {
            console.error("❌ No Worker ID found in webhook URL");
            return res.status(400).send("No Worker ID");
        }

        const workerRef = admin.firestore().collection("users").doc(workerId);

        try {
            await admin.firestore().runTransaction(async (t) => {
                const doc = await t.get(workerRef);
                if (!doc.exists) {
                    throw new Error("Worker does not exist");
                }

                const currentBalance = doc.data().walletAmount || 0;
                const newBalance = currentBalance + amount;
                
                t.update(workerRef, { walletAmount: newBalance });
                
                const historyRef = admin.firestore().collection("wallet_history").doc();
                t.set(historyRef, {
                    workerId,
                    amount,
                    type: "deposit",
                    status: "success",
                    reference: data.tracker, // Safepay transaction reference
                    timestamp: admin.firestore.FieldValue.serverTimestamp()
                });
            });

            console.log(`✅ Success: Added ${amount} to Worker ${workerId}`);
            res.status(200).send("OK");
        } catch (e) {
            console.error("❌ Firestore Update Error:", e.message);
            res.status(500).send("DB Error");
        }
    } else {
        res.status(200).send("Event ignored");
    }
});