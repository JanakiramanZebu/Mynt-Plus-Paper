// Firebase Messaging service worker for web push notifications
// This file enables background notifications on Flutter web builds

importScripts('https://www.gstatic.com/firebasejs/9.6.10/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/9.6.10/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: 'AIzaSyCx8qVtfuxkx9_hUU2IajQR1RzpsUhgtSk',
  appId: '1:145091405497:web:01635d1251c63541ab1d68',
  messagingSenderId: '145091405497',
  projectId: 'zebull-flutter-9380e',
  authDomain: 'zebull-flutter-9380e.firebaseapp.com',
  storageBucket: 'zebull-flutter-9380e.appspot.com',
  measurementId: 'G-68G37B78XE',
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage(function(payload) {
  // Customize notification here
  const notificationTitle = payload.notification?.title || 'Notification';
  const notificationOptions = {
    body: payload.notification?.body || '',
    icon: 'icons/Icon-192.png',
    data: payload.data || {}
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});


