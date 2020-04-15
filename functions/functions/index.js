const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp(functions.config().firebase);
var msgData;
 exports.offerTrigger = functions.firestore.document('users/{userId}').onCreate((snapshot,context) => {
     msgData = snapshot.data();

     admin.firestore().collection('pushtokens').get().then((snapshots)=>{
     var tokens =[];
     if(snapshots.empty){
        console.log('No Devices');
     }
     else
     {
         for(var token of snapshots.docs){
                 tokens.push(token.data().devtoken);
         }
         var payload ={
            "notification":{
                "title": "From " + msgData.name,
                "body": "Offer " + msgData.Uid,
                "sound": "default"
            },
            "data": {
                   "sendername": msgData.name,
                   "message": msgData.phone,
            }
         }

          return admin.messaging().sendToDevice(tokens,payload).then((response)=>{
             console.log('Pushed them all');
          }).catch((err)=>{
            console.log(err);
          }
          );
     }
     })
 })


// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });
