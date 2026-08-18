# 🚀 Prank Blaster - SMS & WhatsApp Mobile Gateway

A premium, local web application that turns your own Android or iOS smartphone into a free SMS and WhatsApp gateway to send lighthearted prank messages. Built with a Flask backend and a modern glassmorphic dark-mode web dashboard.

---

## 📱 Prerequisites

1. **Android/iOS Phone**: The messages will be sent using your own SIM plan or WhatsApp.
2. **SMS Mobile API App**:
   - Download the official **SMS Mobile API** app from the Google Play Store (or Apple App Store).
   - Register/open the app, and you will see your unique **API Key**.
   - Keep the app running in the background and ensure your phone is connected to the internet.

---

## 🛠️ Quick Start

### 1. Run the Application
Open a terminal in this directory and execute the Python Flask server:

```powershell
# Using the local virtual environment Python
.\.venv\Scripts\python app.py
```

### 2. Access the Dashboard
Open your web browser and navigate to:
👉 **[http://127.0.0.1:5000](http://127.0.0.1:5000)**

---

## ⚙️ Features & Configuration

- **API Credentials Manager**: Paste your API Key and click **Test** to verify connection to your mobile gateway.
- **Bulk Targets**: Enter phone numbers separated by commas or new lines (e.g. `9876543210`).
- **Bombing Channels**:
  - **SMS**: Sends messages via standard SMS (uses your phone's SMS pack).
  - **WhatsApp**: Sends messages via WhatsApp web interface on your phone.
- **Cycles**: Specify how many messages each target receives.
- **Delay (Seconds)**: Set the delay between messages. A minimum of **3-5 seconds** is highly recommended to avoid carrier spam triggers.
- **Prank Presets**: Click any funny preset (Lottery, Fake OTP, Bank Debit spoof, Courier delivery) to quickly populate the message content.
- **Live Terminal & Progress**: Monitor the progress of sent messages in real time with the custom scrolling terminal logs.
- **Stop Control**: Cancel the blast queue mid-process at any time.

---

## ⚠️ Disclaimer & Safe Usage Rules

1. **Consent**: Only send pranks to friends and family who understand the joke.
2. **Carrier Tariffs**: You are using your own SIM card's SMS pack. Ensure you have an active SMS pack to avoid unexpected carrier charges.
3. **No Spamming**: Do not use this application to harass, threaten, spam, or send unsolicited promotional messages. Abusing this gateway might result in your phone number being banned by your telecom carrier or WhatsApp.
