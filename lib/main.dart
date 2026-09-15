const express = require('express');
const cors = require('cors');
const admin = require('firebase-admin');
const axios = require('axios');
const { GoogleGenAI } = require('@google/genai');

// Direct Hardcoded Firebase Admin Initialization
if (!admin.apps.length) {
  const privateKeyLines = [
    "-----BEGIN PRIVATE KEY-----",
    "MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDZcGz/XhNyBn2h",
    "hHDSW3FbE4rJbkRChU+hhTsG2HWcDuR2IvQPzDM6jUqbI28egvn1ZsCgEqEAg0yB",
    "r9vUGp8zMhiEMxoPDFlDpY0OhoHNmBSV9siKeSvzulu99SAp4Ki9JG5mzhUXzB46",
    "uZmZuZ4403K552oX21yjrqlLGxQJPd68zRJZtwVWS7cJzkgkrzlSuqhAcViiOkwD",
    "rLVJX9FSObeC6yT2LAmBHwLs4kmDglKqc1hU8ypWo1BhjCXCoagSZ7zw+357qUFN",
    "DvchxqTPQuHsDr4XmD2K912+J57wAKlMfYothtVP28UDV/oMrPEWvtPbub6/RTei",
    "zm3if3nNAgMBAAECggEAPVpXpwaoffgO4tA39WMP7R7qfkO6xvpOqciqCxhwtwQM",
    "urjKHNsFaXQMpRGufPGADhpcJ86Z10c1AzLX2FVarltoR4UTyUM2vLutvXd+kMBk",
    "rpvfohLmr/LZiBPua2KUuinZbPChSwGxVeigyptxZZ9kM8h0Sx7+WMEjy6lsUd65",
    "sPDbDa36cssORwCdl0v/9kpa8JEcvRrdMplC6/K0mVKhyXpc5wSQzEKUI0oUbHcN",
    "EMo22bvzq9MARTyOFXFDgrr/tjFB9f2hpr22zZm9HMawoAcKQWBle2l17pRr4iHQ",
    "wE0PkmG+lLdMbB4xvKggbteHnU9wAK0bfG+T+188EQKBgQD/6cAREeqrYoxWhqb4",
    "F/1nCUOjH/5IC4YGLvh4G+ZJDJs67MiXb+DGWMpYUDQTNvkQPMf1pNDTV3JWbnOk",
    "CWZUeN2mP7mTxbk1GghLGFyNerhDrMHAU/JpiLCBgUEpZGIz0mVlBKlyF7XYdWFl",
    "8u0BA2g9iHPi9nJVyLbK55hGpwKBgQDZg1Sa95m8kJreryMKY4BFUzv5EeKSlEXu",
    "7UGzqf3CzaGnxxWsPR92iM2ZwIhzO2CJln20sxXqkzpVXvST2+fc4A2ECskyUkSO",
    "KPTgCy3OJQg+zEp3wBEpShz6XIrVlg+3gqcD4wSw0kl1j6TDdl3ojwwSzB1qmIVo",
    "8j+4+oa+awKBgQC6gw4sYrZ5ejV1ymVeY32X3rSg6uxUbbGcSBdm0k6f5sQrye7Y",
    "D/3uEUBH5QxPBL25C9NgQGLB5PW78Hvvjbo6zmwcgk0qWeyFuxdYQ8UQh+RLzljX",
    "Z1dBexHJEP8Av9yikDC90wv7zzQFMmdt+gKpvmX2ksCDJcJmqwYuE2Rz+QKBgG7l",
    "Q0xi8lGuFBd2iVHxmuM9ZXU+BhsfV2xSME4uW/9moYWNveH7o7/mTZSXEbpWSoi7",
    "XkmziHf5KiN+bwm3c0YsQRfR+/QY93TXMsnLSUYxoTuLImhdVyKK8609Y1cz072G",
    "8inMI4cXH3a9jo5NGeHIlKo8wL6pFlOENrLTn8ETAoGAazV2OrImV3xwZdrOpN59",
    "I+N9MSeXytFsbE4nTvYdzcYQGu96GkltmKDrY+rOeoA0eK4uNDasx6/KlXQs6On2",
    "sdc1QAROu2Ut1HEkqZFAAjcjS213YP0BhZsAjNSWpdDhllf4eDC1Ctcq1AYMyT9n",
    "5vrIS+lWwStfCeIAFRLrjdw=",
    "-----END PRIVATE KEY-----"
  ].join("\n");

  admin.initializeApp({
    credential: admin.credential.cert({
      projectId: "nombu-beauty",
      clientEmail: "firebase-adminsdk-fbsvc@nombu-beauty.iam.gserviceaccount.com",
      privateKey: privateKeyLines
    })
  });
}
const db = admin.firestore();

// Initialize Gemini SDK
const ai = new GoogleGenAI({ apiKey: process.env.GEMINI_API_KEY });

const app = express();
app.use(cors());
app.use(express.json());

// Meta & Phone Configuration
const WHATSAPP_TOKEN = process.env.WHATSAPP_TOKEN;
const PHONE_NUMBER_ID = process.env.PHONE_NUMBER_ID || "1319308994596760";
const VERIFY_TOKEN = process.env.VERIFY_TOKEN;

// Hardcoded phone numbers
const GIRLFRIEND_PHONE = "0672412217"; // Khanyi
const DEVELOPER_PHONE = "0624295074";   // Umair

// Smart Helper to normalize phone numbers
function normalizePhone(phone) {
  if (!phone) return '';
  let cleaned = phone.replace(/\D/g, '');
  if (cleaned.length === 10 && cleaned.startsWith('0')) {
    cleaned = '27' + cleaned.slice(1);
  }
  return cleaned;
}

// Helper to send Meta-approved Template Messages
async function sendTemplateMessage(recipientPhone, templateName, parameters = []) {
  try {
    let formattedParams = [];
    if (templateName === 'owner_notificationn') {
      formattedParams = parameters.map((param, index) => ({
        type: "text",
        parameter_name: index === 0 ? "client_name" : index === 1 ? "client_phone" : "service_name",
        text: String(param)
      }));
    } else if (templateName === 'booking_approved') {
      formattedParams = parameters.map((param, index) => ({
        type: "text",
        parameter_name: ["client_name", "service_name", "location", "date", "time", "price"][index],
        text: String(param)
      }));
    } else if (['booking_declined', 'booking_cancelled'].includes(templateName)) {
      formattedParams = parameters.map((param, index) => ({
        type: "text",
        parameter_name: ["client_name", "service_name", "date", "time"][index],
        text: String(param)
      }));
    } else if (['owner_approval_notif', 'owner_decline_notif', 'owner_cancel_notif'].includes(templateName)) {
      formattedParams = parameters.map((param, index) => ({
        type: "text",
        parameter_name: ["client_name", "service_name", "date", "time"][index],
        text: String(param)
      }));
    } else {
      formattedParams = parameters.map((param, index) => ({
        type: "text",
        parameter_name: index === 0 ? "client_name" : "service_name",
        text: String(param)
      }));
    }

    const response = await axios.post(
      `https://graph.facebook.com/v20.0/${PHONE_NUMBER_ID}/messages`,
      {
        messaging_product: "whatsapp",
        recipient_type: "individual",
        to: recipientPhone,
        type: "template",
        template: {
          name: templateName,
          language: { code: "en" },
          components: [{ type: "body", parameters: formattedParams }]
        }
      },
      {
        headers: {
          "Authorization": `Bearer ${WHATSAPP_TOKEN}`,
          "Content-Type": "application/json"
        }
      }
    );
    console.log(`✨ Template [${templateName}] sent successfully to ${recipientPhone}`);
    return response.data;
  } catch (err) {
    console.log(`❌ ERROR sending template [${templateName}] to ${recipientPhone}:`, JSON.stringify(err.response?.data || err.message, null, 2));
    throw err;
  }
}

// Webhook Verification (GET)
app.get("/webhook", (req, res) => {
  const mode = req.query["hub.mode"];
  const token = req.query["hub.verify_token"];
  const challenge = req.query["hub.challenge"];

  if (mode && token) {
    if (mode === "subscribe" && token === VERIFY_TOKEN) {
      console.log("🔒 WEBHOOK_VERIFIED successfully");
      res.status(200).send(challenge);
    } else {
      res.sendStatus(403);
    }
  } else {
    res.sendStatus(400);
  }
});

// New Booking Trigger from Website
app.post("/new-booking", async (req, res) => {
  console.log("📥 /new-booking hit with body:", req.body);
  try {
    const { clientName, phoneNumber, service, location, date, time, price } = req.body;

    if (!phoneNumber) {
      return res.status(400).json({ error: "Missing phoneNumber" });
    }

    await db.collection('bookings').add({
      clientName,
      phoneNumber,
      service,
      location,
      date,
      time,
      price: price || 0,
      status: 'Pending',
      createdAt: admin.firestore.FieldValue.serverTimestamp()
    });

    const cleanClientPhone = normalizePhone(phoneNumber);
    await db.collection('chat_states').doc(cleanClientPhone).set({
      botActive: false,
      pausedAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    }, { merge: true });

    const targetGirlfriendPhone = normalizePhone(GIRLFRIEND_PHONE);
    const targetDevPhone = normalizePhone(DEVELOPER_PHONE);

    if (targetGirlfriendPhone) {
      await sendTemplateMessage(targetGirlfriendPhone, 'owner_notificationn', [clientName || 'N/A', cleanClientPhone, service || 'N/A']);
    }

    if (targetDevPhone) {
      await sendTemplateMessage(targetDevPhone, 'owner_notificationn', [clientName || 'N/A', cleanClientPhone, service || 'N/A']);
    }

    await sendTemplateMessage(cleanClientPhone, 'booking_ack', [clientName || 'there', service || 'our service']);

    return res.status(200).json({ success: true, message: "🚀 Booking processed successfully!" });
  } catch (err) {
    console.log("❌ /new-booking ERROR FULL:", JSON.stringify(err.response?.data || err.message, null, 2));
    return res.status(500).json({ error: err.message });
  }
});

// Approve Booking Trigger
app.post("/approve-booking", async (req, res) => {
  console.log("👑 /approve-booking hit with body:", req.body);
  try {
    const { bookingId, phoneNumber, clientName, service, location, date, time, price } = req.body;

    if (!phoneNumber) {
      return res.status(400).json({ error: "Missing phoneNumber" });
    }

    const cleanClientPhone = normalizePhone(phoneNumber);

    if (bookingId) {
      await db.collection('bookings').doc(bookingId).update({
        status: 'Approved',
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      });
    }

    // 1. Notify Client
    await sendTemplateMessage(cleanClientPhone, 'booking_approved', [
      clientName || 'there',
      service || 'our service',
      location || 'NOMBU Beauty',
      date || 'upcoming',
      time || 'scheduled time',
      String(price || '0')
    ]);

    // 2. Notify Both Owners via Template
    const targets = [normalizePhone(GIRLFRIEND_PHONE), normalizePhone(DEVELOPER_PHONE)].filter(Boolean);
    for (const targetPhone of targets) {
      await sendTemplateMessage(targetPhone, 'owner_approval_notif', [
        clientName || 'N/A',
        service || 'N/A',
        date || 'upcoming',
        time || 'scheduled time'
      ]);
    }

    return res.status(200).json({ success: true, message: "✨ Booking approved and all parties notified!" });
  } catch (err) {
    console.log("❌ /approve-booking ERROR:", JSON.stringify(err.response?.data || err.message, null, 2));
    return res.status(500).json({ error: err.message });
  }
});

// Decline Booking Trigger
app.post("/decline-booking", async (req, res) => {
  console.log("❌ /decline-booking hit with body:", req.body);
  try {
    const { bookingId, phoneNumber, clientName, service, date, time } = req.body;

    if (!phoneNumber) {
      return res.status(400).json({ error: "Missing phoneNumber" });
    }

    const cleanClientPhone = normalizePhone(phoneNumber);

    if (bookingId) {
      await db.collection('bookings').doc(bookingId).update({
        status: 'Declined',
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      });
    }

    // 1. Notify Client
    await sendTemplateMessage(cleanClientPhone, 'booking_declined', [
      clientName || 'there',
      service || 'our service',
      date || 'upcoming',
      time || 'scheduled time'
    ]);

    // 2. Notify Both Owners via Template
    const targets = [normalizePhone(GIRLFRIEND_PHONE), normalizePhone(DEVELOPER_PHONE)].filter(Boolean);
    for (const targetPhone of targets) {
      await sendTemplateMessage(targetPhone, 'owner_decline_notif', [
        clientName || 'N/A',
        service || 'N/A',
        date || 'upcoming',
        time || 'scheduled time'
      ]);
    }

    return res.status(200).json({ success: true, message: "❌ Booking declined and all parties notified!" });
  } catch (err) {
    console.log("❌ /decline-booking ERROR:", JSON.stringify(err.response?.data || err.message, null, 2));
    return res.status(500).json({ error: err.message });
  }
});

// Cancel Booking Trigger
app.post("/cancel-booking", async (req, res) => {
  console.log("🚫 /cancel-booking hit with body:", req.body);
  try {
    const { bookingId, phoneNumber, clientName, service, date, time } = req.body;

    if (!phoneNumber) {
      return res.status(400).json({ error: "Missing phoneNumber" });
    }

    const cleanClientPhone = normalizePhone(phoneNumber);

    if (bookingId) {
      await db.collection('bookings').doc(bookingId).update({
        status: 'Cancelled',
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      });
    }

    // 1. Notify Client
    await sendTemplateMessage(cleanClientPhone, 'booking_cancelled', [
      clientName || 'there',
      service || 'our service',
      date || 'upcoming',
      time || 'scheduled time'
    ]);

    // 2. Notify Both Owners via Template
    const targets = [normalizePhone(GIRLFRIEND_PHONE), normalizePhone(DEVELOPER_PHONE)].filter(Boolean);
    for (const targetPhone of targets) {
      await sendTemplateMessage(targetPhone, 'owner_cancel_notif', [
        clientName || 'N/A',
        service || 'N/A',
        date || 'upcoming',
        time || 'scheduled time'
      ]);
    }

    return res.status(200).json({ success: true, message: "🚫 Booking cancelled and all parties notified!" });
  } catch (err) {
    console.log("❌ /cancel-booking ERROR:", JSON.stringify(err.response?.data || err.message, null, 2));
    return res.status(500).json({ error: err.message });
  }
});

// Incoming WhatsApp Webhook (POST)
app.post("/webhook", async (req, res) => {
  try {
    const body = req.body;

    if (body.object === "whatsapp_business_account") {
      for (const entry of body.entry) {
        for (const change of entry.changes) {
          if (change.value && change.value.messages && change.value.messages[0]) {
            const msg = change.value.messages[0];
            const fromPhone = msg.from;
            const userMessage = msg.text ? msg.text.body : "";
            const cleanFrom = normalizePhone(fromPhone);

            console.log(`💬 Incoming message from ${cleanFrom}: ${userMessage}`);

            const cleanGirlfriend = normalizePhone(GIRLFRIEND_PHONE);
            const cleanDev = normalizePhone(DEVELOPER_PHONE);
            
            const isKhanyi = (cleanFrom === cleanGirlfriend);
            const isDeveloper = (cleanFrom === cleanDev);
            const isBossOrTester = isKhanyi || isDeveloper;

            // ==========================================
            // 1. BOSS / DEVELOPER HANDLING
            // ==========================================
            if (isBossOrTester) {
              const textLower = userMessage.toLowerCase().trim();

              // WHATSAPP QUICK APPROVAL/DECLINE FOR KHANYI OR DEVS
              if (textLower.startsWith('approve') || textLower.startsWith('decline') || textLower.startsWith('cancel')) {
                const actionType = textLower.startsWith('approve') ? 'Approved' : textLower.startsWith('decline') ? 'Declined' : 'Cancelled';
                
                const pendingSnapshot = await db.collection('bookings')
                  .where('status', '==', 'Pending')
                  .orderBy('createdAt', 'desc')
                  .limit(1)
                  .get();

                if (pendingSnapshot.empty) {
                  await axios.post(
                    `https://graph.facebook.com/v20.0/${PHONE_NUMBER_ID}/messages`,
                    {
                      messaging_product: "whatsapp",
                      recipient_type: "individual",
                      to: fromPhone,
                      type: "text",
                      text: { body: `⚠️ No pending bookings found to ${actionType.toLowerCase()}.` }
                    },
                    { headers: { "Authorization": `Bearer ${WHATSAPP_TOKEN}`, "Content-Type": "application/json" } }
                  );
                  return res.sendStatus(200);
                }

                const bookingDoc = pendingSnapshot.docs[0];
                const bookingId = bookingDoc.id;
                const bookingData = bookingDoc.data();
                const cleanClientPhone = normalizePhone(bookingData.phoneNumber);

                await db.collection('bookings').doc(bookingId).update({
                  status: actionType,
                  updatedAt: admin.firestore.FieldValue.serverTimestamp()
                });

                if (actionType === 'Approved') {
                  await sendTemplateMessage(cleanClientPhone, 'booking_approved', [
                    bookingData.clientName || 'there',
                    bookingData.service || 'our service',
                    bookingData.location || 'NOMBU Beauty',
                    bookingData.date || 'upcoming',
                    bookingData.time || 'scheduled time',
                    String(bookingData.price || '0')
                  ]);
                } else if (actionType === 'Declined') {
                  await sendTemplateMessage(cleanClientPhone, 'booking_declined', [
                    bookingData.clientName || 'there',
                    bookingData.service || 'our service',
                    bookingData.date || 'upcoming',
                    bookingData.time || 'scheduled time'
                  ]);
                } else if (actionType === 'Cancelled') {
                  await sendTemplateMessage(cleanClientPhone, 'booking_cancelled', [
                    bookingData.clientName || 'there',
                    bookingData.service || 'our service',
                    bookingData.date || 'upcoming',
                    bookingData.time || 'scheduled time'
                  ]);
                }

                const templateNameForOwner = actionType === 'Approved' ? 'owner_approval_notif' : actionType === 'Declined' ? 'owner_decline_notif' : 'owner_cancel_notif';
                const targets = [normalizePhone(GIRLFRIEND_PHONE), normalizePhone(DEVELOPER_PHONE)].filter(Boolean);
                
                for (const targetPhone of targets) {
                  await sendTemplateMessage(targetPhone, templateNameForOwner, [
                    bookingData.clientName || 'N/A',
                    bookingData.service || 'N/A',
                    bookingData.date || 'upcoming',
                    bookingData.time || 'scheduled time'
                  ]);
                }

                return res.sendStatus(200);
              }

              if (textLower === 'help') {
                let helpText = `👑 *Nombu Beauty - Command Guide* ✨\n\n` +
                  `1️⃣ *talk [number]*\nOpen a direct walkie-talkie bridge to a client with recent context.\n\n` +
                  `2️⃣ *stop [number]*\nClose the active client chat bridge.\n\n` +
                  `3️⃣ *learn [rule]*\nTeach the AI a new business rule on the fly.\n\n` +
                  `4️⃣ *Approve / Decline*\nReply directly to booking alerts to update status.\n\n` +
                  `5️⃣ *help*\nDisplay this command guide.`;

                if (isDeveloper) {
                  helpText += `\n\n🛠️ *Developer Controls:*\n• \`cmd: pause khanyi\`\n• \`cmd: resume khanyi\`\n• \`cmd:khanyi history\``;
                }

                await axios.post(
                  `https://graph.facebook.com/v20.0/${PHONE_NUMBER_ID}/messages`,
                  {
                    messaging_product: "whatsapp",
                    recipient_type: "individual",
                    to: fromPhone,
                    type: "text",
                    text: { body: helpText }
                  },
                  { headers: { "Authorization": `Bearer ${WHATSAPP_TOKEN}`, "Content-Type": "application/json" } }
                );
                return res.sendStatus(200);
              }

              if (isDeveloper) {
                if (textLower === 'cmd: pause khanyi') {
                  await db.collection('chat_states').doc(cleanGirlfriend).set({
                    botActive: false,
                    updatedAt: admin.firestore.FieldValue.serverTimestamp()
                  }, { merge: true });

                  await axios.post(
                    `https://graph.facebook.com/v20.0/${PHONE_NUMBER_ID}/messages`,
                    {
                      messaging_product: "whatsapp",
                      recipient_type: "individual",
                      to: fromPhone,
                      type: "text",
                      text: { body: `🛠️ Developer Action: Khanyi's bot session has been **paused**. 🛑` }
                    },
                    { headers: { "Authorization": `Bearer ${WHATSAPP_TOKEN}`, "Content-Type": "application/json" } }
                  );
                  return res.sendStatus(200);
                }

                if (textLower === 'cmd: resume khanyi') {
                  await db.collection('chat_states').doc(cleanGirlfriend).set({
                    botActive: true,
                    updatedAt: admin.firestore.FieldValue.serverTimestamp()
                  }, { merge: true });

                  await axios.post(
                    `https://graph.facebook.com/v20.0/${PHONE_NUMBER_ID}/messages`,
                    {
                      messaging_product: "whatsapp",
                      recipient_type: "individual",
                      to: fromPhone,
                      type: "text",
                      text: { body: `🛠️ Developer Action: Khanyi's bot session has been **resumed**. ✅` }
                    },
                    { headers: { "Authorization": `Bearer ${WHATSAPP_TOKEN}`, "Content-Type": "application/json" } }
                  );
                  return res.sendStatus(200);
                }

                if (textLower.replace(/\s+/g, '') === 'cmd:khanyi history') {
                  let historyText = "_No history found for Khanyi yet._";
                  try {
                    const histSnap = await db.collection('chats')
                      .doc(cleanGirlfriend)
                      .collection('messages')
                      .orderBy('timestamp', 'desc')
                      .limit(10)
                      .get();

                    if (!histSnap.empty) {
                      const msgs = [];
                      histSnap.forEach(doc => {
                        const d = doc.data();
                        let senderName = d.sender || (d.text && d.text.toLowerCase().includes('help') ? 'Khanyi' : 'AI');
                        msgs.push(`• *${senderName}*: ${d.text || ''}`);
                      });
                      historyText = msgs.reverse().join('\n');
                    }
                  } catch (e) {
                    historyText = `Error fetching history: ${e.message}`;
                  }

                  await axios.post(
                    `https://graph.facebook.com/v20.0/${PHONE_NUMBER_ID}/messages`,
                    {
                      messaging_product: "whatsapp",
                      recipient_type: "individual",
                      to: fromPhone,
                      type: "text",
                      text: { body: `📜 *Khanyi & AI Chat History:*\n\n${historyText}` }
                    },
                    { headers: { "Authorization": `Bearer ${WHATSAPP_TOKEN}`, "Content-Type": "application/json" } }
                  );
                  return res.sendStatus(200);
                }
              }

              if (textLower.startsWith('stop ')) {
                let targetRaw = userMessage.replace(/^stop\s+/i, '').trim();
                let targetClient = normalizePhone(targetRaw);

                if (targetClient.length >= 10) {
                  await db.collection('boss_sessions').doc(fromPhone).delete();
                  await axios.post(
                    `https://graph.facebook.com/v20.0/${PHONE_NUMBER_ID}/messages`,
                    {
                      messaging_product: "whatsapp",
                      recipient_type: "individual",
                      to: fromPhone,
                      type: "text",
                      text: { body: `🔒 Client chat bridge closed. You are back in Boss Mode! 👑✨` }
                    },
                    { headers: { "Authorization": `Bearer ${WHATSAPP_TOKEN}`, "Content-Type": "application/json" } }
                  );
                  return res.sendStatus(200);
                }
              }

              if (textLower.startsWith('talk ')) {
                let targetRaw = userMessage.replace(/^talk\s+/i, '').trim();
                let targetClient = normalizePhone(targetRaw);

                if (targetClient.length >= 10) {
                  await db.collection('boss_sessions').doc(fromPhone).set({
                    activeClient: targetClient,
                    updatedAt: admin.firestore.FieldValue.serverTimestamp()
                  });

                  let contextHistory = "_No recent message history found._";
                  try {
                    const msgSnapshot = await db.collection('chats')
                      .doc(targetClient)
                      .collection('messages')
                      .orderBy('timestamp', 'desc')
                      .limit(5)
                      .get();

                    if (!msgSnapshot.empty) {
                      const messages = [];
                      msgSnapshot.forEach(doc => {
                        const data = doc.data();
                        messages.push(`• *${data.sender || 'Client'}*: ${data.text}`);
                      });
                      contextHistory = messages.reverse().join('\n');
                    }
                  } catch (histErr) {
                    console.log("Could not fetch chat history context:", histErr.message);
                  }

                  const bridgeMessage = `🔗 *Bridge Connected & Context Loaded!*\n` +
                    `Messaging client: ${targetClient}\n\n` +
                    `📜 *Recent Chat History:*\n${contextHistory}\n\n` +
                    `Type \`stop [number]\` when you are finished. ✨`;

                  await axios.post(
                    `https://graph.facebook.com/v20.0/${PHONE_NUMBER_ID}/messages`,
                    {
                      messaging_product: "whatsapp",
                      recipient_type: "individual",
                      to: fromPhone,
                      type: "text",
                      text: { body: bridgeMessage }
                    },
                    { headers: { "Authorization": `Bearer ${WHATSAPP_TOKEN}`, "Content-Type": "application/json" } }
                  );
                  return res.sendStatus(200);
                }
              }

              if (textLower.startsWith('learn ')) {
                let newRule = userMessage.replace(/^learn\s+/i, '').trim();

                if (newRule.length > 0) {
                  await db.collection('business_knowledge').add({
                    rule: newRule,
                    addedBy: fromPhone,
                    createdAt: admin.firestore.FieldValue.serverTimestamp()
                  });

                  await axios.post(
                    `https://graph.facebook.com/v20.0/${PHONE_NUMBER_ID}/messages`,
                    {
                      messaging_product: "whatsapp",
                      recipient_type: "individual",
                      to: fromPhone,
                      type: "text",
                      text: { body: `🧠 *Learned & Saved!* I have added this rule to Nombu Beauty's active memory:\n\n_"${newRule}"_ ✨` }
                    },
                    { headers: { "Authorization": `Bearer ${WHATSAPP_TOKEN}`, "Content-Type": "application/json" } }
                  );
                  return res.sendStatus(200);
                }
              }

              const bossSessionDoc = await db.collection('boss_sessions').doc(fromPhone).get();
              const activeClient = bossSessionDoc.exists ? bossSessionDoc.data().activeClient : null;

              if (activeClient) {
                await axios.post(
                  `https://graph.facebook.com/v20.0/${PHONE_NUMBER_ID}/messages`,
                  {
                    messaging_product: "whatsapp",
                    recipient_type: "individual",
                    to: activeClient,
                    type: "text",
                    text: { body: userMessage }
                  },
                  { headers: { "Authorization": `Bearer ${WHATSAPP_TOKEN}`, "Content-Type": "application/json" } }
                );
                return res.sendStatus(200);
              }

              if (isKhanyi) {
                await db.collection('chats').doc(cleanGirlfriend).collection('messages').add({
                  sender: 'Khanyi',
                  text: userMessage,
                  timestamp: admin.firestore.FieldValue.serverTimestamp()
                });
              }

              const knowledgeSnapshot = await db.collection('business_knowledge').get();
              let learnedRulesText = "";
              knowledgeSnapshot.forEach(doc => {
                learnedRulesText += `- ${doc.data().rule}\n`;
              });

              const personaTitle = isKhanyi ? "Khanyi (Owner)" : "Umair (Developer)";
              const bossPrompt = `You are an elite executive business AI assistant for Nombu Beauty, speaking directly with ${personaTitle}. 
Learned business rules:
${learnedRulesText}

Answer professionally, concisely, and use emojis appropriately.`;

              // Safe Gemini call with 503 error retry wrapper
              let aiReply = "Processed, boss! ✨";
              try {
                const response = await ai.models.generateContent({
                  model: 'gemini-3.6-flash',
                  contents: [{ role: 'user', parts: [{ text: userMessage }] }],
                  config: { systemInstruction: bossPrompt }
                });
                aiReply = response.text || aiReply;
              } catch (aiErr) {
                console.log("⚠️ Gemini 503/High Demand Error, using fallback:", aiErr.message);
                aiReply = "I'm experiencing a brief high-demand traffic spike, boss, but I'm back up! What would you like to do? ✨";
              }

              if (isKhanyi) {
                await db.collection('chats').doc(cleanGirlfriend).collection('messages').add({
                  sender: 'AI Executive',
                  text: aiReply,
                  timestamp: admin.firestore.FieldValue.serverTimestamp()
                });
              }

              await axios.post(
                `https://graph.facebook.com/v20.0/${PHONE_NUMBER_ID}/messages`,
                {
                  messaging_product: "whatsapp",
                  recipient_type: "individual",
                  to: fromPhone,
                  type: "text",
                  text: { body: aiReply }
                },
                { headers: { "Authorization": `Bearer ${WHATSAPP_TOKEN}`, "Content-Type": "application/json" } }
              );
              return res.sendStatus(200);
            }

            // ==========================================
            // 2. CLIENT HANDLING
            // ==========================================
            await db.collection('chats').doc(cleanFrom).collection('messages').add({
              sender: 'Client',
              text: userMessage,
              timestamp: admin.firestore.FieldValue.serverTimestamp()
            });

            const stateDoc = await db.collection('chat_states').doc(cleanFrom).get();
            const isBotActive = stateDoc.exists ? stateDoc.data().botActive : true;

            if (isBotActive === false) {
              return res.sendStatus(200);
            }

            const knowledgeSnapshot = await db.collection('business_knowledge').get();
            let learnedRulesText = "";
            knowledgeSnapshot.forEach(doc => {
              learnedRulesText += `- ${doc.data().rule}\n`;
            });

            const clientPrompt = `You are the friendly AI receptionist for Nombu Beauty. Help clients with bookings, services, and inquiries.

CRITICAL HANDOVER CONDITIONS:
You MUST include the exact tag [HANDOVER_TO_KHANYI] in your reply if any of the following occur:
1. The client asks for a discount, custom pricing, or package deal not on the standard menu.
2. The client asks for complex custom requests or specialized treatments you are uncertain about.
3. The client needs urgent rescheduling or same-day changes.
4. The client expresses a complaint or requires special physical accommodations.
5. The client explicitly asks to speak to a real person, human, or the owner (Khanyi).
6. You do not know the answer or cannot handle the request.

If you include [HANDOVER_TO_KHANYI], make sure your reply politely lets the client know that Khanyi (the owner) is being notified and will message them directly shortly.

Active business rules to follow:
${learnedRulesText}`;

              let clientReplyText = "Welcome to Nombu Beauty! How can we assist you today? ✨";
              try {
                const clientResponse = await ai.models.generateContent({
                  model: 'gemini-3.6-flash',
                  contents: [{ role: 'user', parts: [{ text: userMessage }] }],
                  config: { systemInstruction: clientPrompt }
                });
                clientReplyText = clientResponse.text || clientReplyText;
              } catch (clientAiErr) {
                console.log("⚠️ Client Gemini 503 Error, using fallback:", clientAiErr.message);
                clientReplyText = "Welcome to Nombu Beauty! We're experiencing heavy traffic right now, but let me loop Khanyi in for you! [HANDOVER_TO_KHANYI]";
              }

            if (clientReplyText.includes('[HANDOVER_TO_KHANYI]')) {
              await db.collection('chat_states').doc(cleanFrom).set({
                botActive: false,
                pausedAt: admin.firestore.FieldValue.serverTimestamp(),
                updatedAt: admin.firestore.FieldValue.serverTimestamp()
              }, { merge: true });

              let contextHistory = "_No recent history found._";
              try {
                const msgSnapshot = await db.collection('chats')
                  .doc(cleanFrom)
                  .collection('messages')
                  .orderBy('timestamp', 'desc')
                  .limit(5)
                  .get();

                if (!msgSnapshot.empty) {
                  const messages = [];
                  msgSnapshot.forEach(doc => {
                    const data = doc.data();
                    messages.push(`• *${data.sender || 'Client'}*: ${data.text}`);
                  });
                  contextHistory = messages.reverse().join('\n');
                }
              } catch (histErr) {
                console.log("Could not fetch handover history:", histErr.message);
              }

              const autoHandoffAlert = `🚨 *AI Handoff Triggered!*\n` +
                `👤 Client: ${cleanFrom}\n\n` +
                `📜 *Recent Chat Context:*\n${contextHistory}\n\n` +
                `_The bot has paused itself. You can now reply directly to this client._ ✨`;

              if (cleanGirlfriend) {
                await axios.post(
                  `https://graph.facebook.com/v20.0/${PHONE_NUMBER_ID}/messages`,
                  {
                    messaging_product: "whatsapp",
                    recipient_type: "individual",
                    to: cleanGirlfriend,
                    type: "text",
                    text: { body: autoHandoffAlert }
                  },
                  { headers: { "Authorization": `Bearer ${WHATSAPP_TOKEN}`, "Content-Type": "application/json" } }
                );
              }

              clientReplyText = clientReplyText.replace('[HANDOVER_TO_KHANYI]', '').trim();
            }

            if (!clientReplyText && !isBotActive) {
              clientReplyText = "Let me loop Khanyi in on this! She will be with you shortly to assist you personally. ✨";
            }

            await db.collection('chats').doc(cleanFrom).collection('messages').add({
              sender: 'AI Receptionist',
              text: clientReplyText || "Let me check on that for you!",
              timestamp: admin.firestore.FieldValue.serverTimestamp()
            });

            if (clientReplyText) {
              await axios.post(
                `https://graph.facebook.com/v20.0/${PHONE_NUMBER_ID}/messages`,
                {
                  messaging_product: "whatsapp",
                  recipient_type: "individual",
                  to: fromPhone,
                  type: "text",
                  text: { body: clientReplyText }
                },
                { headers: { "Authorization": `Bearer ${WHATSAPP_TOKEN}`, "Content-Type": "application/json" } }
              );
            }
            return res.sendStatus(200);
          }
        }
      }
      res.sendStatus(200);
    } else {
      res.sendStatus(404);
    }
  } catch (err) {
    console.log("❌ /webhook ERROR:", JSON.stringify(err.response?.data || err.message, null, 2));
    res.sendStatus(500);
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`🚀 Server is running smoothly on port ${PORT}`);
});
