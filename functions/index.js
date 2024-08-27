/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {onRequest, onCall} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");

const functions = require("firebase-functions");
const admin = require("firebase-admin");
const { getFirestore, Timestamp } = require("firebase-admin/firestore");
const { getAuth, UserRecord } = require("firebase-admin/auth");
const { Message } = require("firebase-functions/v1/pubsub");

admin.initializeApp();

const options = {
  priority: 'high',
  timeToLive: 60 * 60 * 24
};

const CodeSuccess = 0;
const CodeUserAlreadyRegistered = 1;
const CodeUsernameTaken= 2;
const CodeUsernameTooShort = 3; 
const CodeReceiverDoesNotExist = 4;
const CodeEmailProfileAuthInvariantBroken = 5;
const CodeCantCreateAuthUser = 6;
const CodeUserNotRegistered = 7;
const CodeNotAuthenticated = 8;
const CodeMaximumTokensNumberReached = 9;
const CodeDeviceNameTooLong = 10;
const CodeInvalidArgs = 11;
const Code = 12; //next code

function callResponse(msg, code) {
    return {'result': {msg: msg, code: code}};
}
function callResponseWithUid(msg, code, uid) {
    return {'result': {msg: msg, code: code, uid: uid}};
}
function callResponseWithToken(msg, code, token) {
    return {'result': {msg: msg, code: code, token: token}};
}

function noAuthResponse() {
    return callResponse('No auth', CodeNotAuthenticated);
}

exports.myFunction = functions.firestore.document('chat/{messageId}').onCreate(
    (snapshot, ctx) => {
        admin.firestore().collection
        return admin.messaging().sendToTopic('chat', {
            notification: {
                title: snapshot.data()['username'],
                body: snapshot.data()['text'],
                clickAction: "FLUTTER_NOTIFICATION_CLICK",
            },
        },
    options);
    }
)

exports.updateavatar = functions.https.onCall(async (data, ctx) => {
    if (!ctx.auth) return noAuthResponse();

    //TODO: add a filter to only update if url is firestore url
    const avaUrl = data.img_url;
    if (!avaUrl){
        return callResponse('Invalid args', CodeInvalidArgs);
    }

    const doc = getFirestore().collection('users').doc(ctx.auth.uid);

    const res = await doc.update({img_url: avaUrl});

    return callResponse('Updated user ava', CodeSuccess);
} );

function notificationFcmMsg(msg, fromUsername, token) {
    const message = {
        notification: {
            title: fromUsername, 
            body: msg, 
        },
        data: {
            click_action: "FLUTTER_NOTIFICATION_CLICK",
        },
        token: token,
        android: {
            priority: 'high',
            notification: {
                sound: "default",
            },
        },
    }

    return message;
}

exports.addmessage = functions.https.onCall(async (data,context) => {
    if (!context.auth) return noAuthResponse();

    const msg = data.text;
    const fromId = context.auth.uid;
    const toId = data.to;

    if (!msg || !fromId || !toId) {
        return callResponse('Invalid args', CodeInvalidArgs);
    }
    
    const toUserSnapshot = await getFirestore().collection('users').doc(toId).get();
    const toUserData = toUserSnapshot.data();
    const toUsername = toUserData.username;
    //const toUsernameSnapshot = await getFirestore().collection('usernames').doc(toId).get();

    if (!toUserSnapshot.exists ) {
        return callResponse('Receiver does not exist', CodeReceiverDoesNotExist);
    }

    const fromUser = (await getFirestore().collection('users').doc(fromId).get()).data();
    const fromUsername = fromUser.username;
    const fromImgUrl = fromUser.img_url;

    var ids = [fromId, toId];
    ids.sort();
    const newId = ids[0].concat(ids[1]);
    const writeRes = getFirestore().collection('chats').doc(newId).collection('msgs').add({
        msg: msg,
        from: fromId,
        to: toId,
        created_at: Date.now(), 
        username: fromUsername,
        img_url: fromImgUrl,
    });

    // TODO: push notification(done)
    // TODO: make custom onClick behaviour

    tokens = toUserSnapshot.data().tokens;

    if (tokens) {
        for (let [devName, fcmtoken] of Object.entries(tokens)) {
            console.log(`Sending msg to ${devName}`);
            admin.messaging().send(notificationFcmMsg(msg, fromUsername, fcmtoken));
        }
    }
    /*await getFirestore().collection('users').doc(toId).get().then(
        (snapshot) => {
            tokens = snapshot.data().tokens;
            console.log('tokens');
            console.log(tokens);

            if (tokens) {
                for (let [devName, fcmtoken] of Object.entries(tokens)) {
                    console.log(`Sending msg to ${devName}`);
                    admin.messaging().send(notificationFcmMsg(msg, fromUsername, fcmtoken));
                }
            }
        }
    );*/


    return callResponse(`Added msg`, CodeSuccess);
});

// on hold(no reasonable password verification process is available)
exports.login = functions.https.onCall(async (data, context) => {
    const username = data.username;
    const pwd = data.pwd;

    if (!username || !pwd) {
        return callResponse('Invalid args', CodeInvalidArgs);
    }

    const usernameRecord = await getFirestore().collection('usernames').doc(username).get();
    if (usernameRecord.exists) {
        return callResponse('User not registerd', CodeUserNotRegistered);
    }
    const token = await admin.auth().createCustomToken(usernameRecord.data().user_id);
    return callResponseWithToken('Got auth token', CodeSuccess, token);
});

exports.registertoken = functions.https.onCall(async (data, context) => {
    if (!context.auth) return noAuthResponse();
    
    const fcmtoken = data.token;
    const deviceName = data.device_name;
    
    if (!fcmtoken || !deviceName) {
        return callResponse('Invalid args', CodeInvalidArgs);
    }

    if (fcmtoken.length > 200) {
        return callResponse('Device name too long', CodeDeviceNameTooLong);
    }

    //mb add check
    const userRecordDoc = getFirestore().collection('users').doc(context.auth.uid);
    const userRecord = await userRecordDoc.get();
    var tokenMap = userRecord.data().tokens || {};
    tokenMap[deviceName] = fcmtoken;
    console.log('Formed new token')
    if (Object.keys(tokenMap).length < 10) {
        await userRecordDoc.update({
            tokens: tokenMap,
        });

        return callResponse('Token registered', CodeSuccess);
    } else {
        return callResponse('Maximum tokens number reached', CodeMaximumTokensNumberReached);
    }
});

async function completeRegister(uid, email, username) {
    const firestore = getFirestore();
    const batch = firestore.batch();

    const newUsernameRef = firestore.collection('usernames').doc(username);   
    const newUserRef = firestore.collection('users').doc(uid);
    const newUserSnapshot = (await newUserRef.get());

    if (newUserSnapshot.exists){
        return callResponse('User already exists', CodeUserAlreadyRegistered);
    }
    if (username.trim().length < 4) {
        return {result: {msg: 'Username too short', code: CodeUsernameTooShort}};
    }

    //TODO check if username available

    batch.create(newUserRef, {
        email: email,
        username: username,
        img_url: '',
    });

    batch.create(newUsernameRef, {
        user_id: uid 
    });

    const writeRes = await batch.commit();


}
exports.completeregister = functions.https.onCall(async (data, context) => {
    if (!context.auth) return callResponse('No auth', CodeNotAuthenticated);

    const userRecord = await getAuth().getUser(context.auth.uid);
    if (userRecord.providerData.length == 0) {
        return callResponse('Invalid call, must only be called when registering from provider', CodeInvalidArgs);
    }

    const username = data.username;
    const email = userRecord.providerData[0].email;
    if (!username) {
        return callResponse('Invalid args', CodeInvalidArgs);
    }

    const result = await completeRegister(context.auth.uid, email, username);
   
    if (result) {
        //return result;
    }

    return callResponse('Register complete', CodeSuccess);
})
exports.register = functions.https.onCall(async (data,context) => {
    //(await getAuth().getUser(context.auth.uid)).providerData[0].email;
    const email = data.email;
    const username = data.username;
    const pwd = data.pwd;

    const firestore = getFirestore();
    //const batch = firestore.batch();
    //const newUsernameRef = firestore.collection('usernames').doc(username);


    

    var user = null;
    try {
        user = await admin.auth().createUser({
            email: email,
            password: pwd,
            emailVerified: false,
            disabled: false,
        });
    } catch(e) {
        return {result: {msg: e, code: CodeCantCreateAuthUser}};
    }
    result = await completeRegister(user.uid, email, username);
    if (result) {
        return result;
    }
    /*const uid = user.uid;
    const newUserRef = firestore.collection('users').doc(uid);

    batch.create(newUserRef, {
        email: email,
        username: username,
        img_url: '',
    });

    batch.create(newUsernameRef, {
        user_id: user.uid 
    });

    const writeRes = await batch.commit();*/

    return callResponseWithUid('User registered', CodeSuccess, user.uid);
});


// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
