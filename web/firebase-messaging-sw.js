console.log("firebase-messaging-sw.js loaded");

importScripts("https://cdnjs.cloudflare.com/ajax/libs/firebase/11.1.0/firebase-app-compat.min.js");
importScripts("https://cdnjs.cloudflare.com/ajax/libs/firebase/11.1.0/firebase-messaging-compat.min.js");


firebase.initializeApp({
  apiKey: "AIzaSyARQ3sRrXgjf8DJk4t_g3QS4gx8Ae3TZ0g",
  authDomain: "dinenorder-prod.firebaseapp.com",
  projectId: "dinenorder-prod",
  storageBucket: "dinenorder-prod.firebasestorage.app",
  messagingSenderId: "1010148746750",
  appId: "1:1010148746750:web:14cc540d00aedff0bf8caf",
  measurementId: "G-WMW1S97T95"
});
// Necessary to receive background messages:
const messaging = firebase.messaging();

// Optional:
messaging.onBackgroundMessage((m) => {
  console.log("onBackgroundMessage", m);
});
