// Give Firebase SDK access to messaging.
importScripts('https://www.gstatic.com/firebasejs/9.23.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/9.23.0/firebase-messaging-compat.js');

// Initialize the Firebase app in the service worker by passing in the messagingSenderId.
firebase.initializeApp({
    apiKey: 'AIzaSyDvrP0UAggUQuvd8vFTTtdHxFL0eykANXc',
    appId: '1:421151059964:web:031134a180482cbe1acc79',
    messagingSenderId: '421151059964',
    projectId: 'kaam-wala-546a1',
    authDomain: 'kaam-wala-546a1.firebaseapp.com',
    storageBucket: 'kaam-wala-546a1.firebasestorage.app',
});

// Retrieve an instance of Firebase Messaging so that it can handle background messages.
const messaging = firebase.messaging();
