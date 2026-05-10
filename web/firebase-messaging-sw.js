importScripts("https://www.gstatic.com/firebasejs/10.0.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.0.0/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: "AIzaSyA_twkW5-a2TXEJyxSjs7CSgbruWDtd5nA",
  authDomain: "fixco-dc493-8d57c.firebaseapp.com",
  projectId: "fixco-dc493-8d57c",
  storageBucket: "fixco-dc493-8d57c.firebasestorage.app",
  messagingSenderId: "172882778974",
  appId: "1:172882778974:web:915a5c400ddb6c68abcdcf"
});

const messaging = firebase.messaging();
