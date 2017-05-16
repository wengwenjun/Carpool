var firebase = require('firebase-admin');
var request = require('request');

var API_KEY = "AAAABB7BFz8:APA91bHsAvM1hR9IIT8f2R1lt83VnT2vo-sVrFEklzRVQQUqZ4xLmA-TyxQMUSo3eYfxBBH0ZstdOwkMQewXwSXyoIabhXTsOorWgq3SYMlUneGQyPUuiJB8FO6Bt4rj_7yBClQXRD2r";

var serviceAccount = require("./meta.json");

firebase.initializeApp({
	credential: firebase.credential.cert(serviceAccount),
	databaseURL: "https://carpool-84cf5.firebaseio.com/"
});
ref = firebase.database().ref();

function listenForNotificationRequests() {
  var requests = ref.child('notificationRequests');
  requests.on('child_added', function(requestSnapshot) {
    var request = requestSnapshot.val();
      sendNotificationToUser(
      request.username, 
      request.message,
      request.rideinfo,
      function() {
        requestSnapshot.ref.remove();
      }
    );
  }, function(error) {
    console.error(error);
  });
};

function sendNotificationToUser(username, message, rideinfo, onSuccess) {
  request({
    url: 'https://fcm.googleapis.com/fcm/send',
    method: 'POST',
    headers: {
      'Content-Type' :' application/json',
      'Authorization': 'key='+API_KEY
    },
    body: JSON.stringify({
      notification: {
        title: "You have a rider request!",
	body: message
      },
      to : username,
      data: {rideInfo: rideinfo}
    })
  }, function(error, response, body) {
    if (error) { console.error(error); }
    else if (response.statusCode >= 400) { 
      console.error('HTTP Error: '+response.statusCode+' - '+response.statusMessage); 
    }
    else {
      onSuccess();
    }
  });
}

// start listening
listenForNotificationRequests();
