"use-strict";

const functions = require("firebase-functions");

const admin = require("firebase-admin");
admin.initializeApp(functions.config().firebase);

exports.sendStressNotificationToGroup = functions.database
  .ref("/groups/{groupUid}/stressedUser")
  .onWrite(async (change, context) => {
    const groupUid = context.params.groupUid;
    // Get the list of device notification tokens.
    const getDeviceTokensPromise = admin
      .database()
      .ref(`/groups/${groupUid}/tokens`)
      .once("value");

    // Get the StressedUser name in the group.
    const getStressedUserName = admin
      .database()
      .ref(`/groups/${groupUid}/stressedUser/stressedUser`)
      .once("value");

    // Get the Sender Device Token in the group.
    const getSenderDeviceToken = admin
      .database()
      .ref(`/groups/${groupUid}/stressedUser/senderDeviceToken`)
      .once("value");

    // Get the Group Name.
    const getGroupNamePromise = admin
      .database()
      .ref(`/groups/${groupUid}/name`)
      .once("value");

    // The snapshot to the user's tokens.
    let tokensSnapshot;

    // The array containing all the user's tokens.
    let tokens;

    const results = await Promise.all([
      getDeviceTokensPromise,
      getStressedUserName,
      getGroupNamePromise,
      getSenderDeviceToken,
    ]);
    tokensSnapshot = results[0];
    const stressedUserName = results[1].val();
    const groupName = results[2].val();
    const senderToken = results[3].val();

    // Tokens Value
    console.log(tokensSnapshot.val());

    // Notification details.
    const payload = {
      notification: {
        title: `${stressedUserName} is Stressed!`,
        body: `Open ${groupName} to send music.`,
        icon: `https://is3-ssl.mzstatic.com/image/thumb/Music113/v4/88/48/8f/88488f62-ac34-a109-569c-6cda49352855/source/100x100bb.jpg`,
        sound: "frustration.caf",
      },
    };

    // Listing all tokens as an array.
    tokens = tokensSnapshot.val();

    // Filter tokens and remove Sender Token
    tokens = tokens.filter(function (str) {
      return str !== senderToken;
    });

    // Send notifications to all tokens.
    const response = await admin.messaging().sendToDevice(tokens, payload);
    // For each message check if there was an error.
    const tokensToRemove = [];
    response.results.forEach((result, index) => {
      const error = result.error;
      if (error) {
        console.error("Failure sending notification to", tokens[index], error);
        // Cleanup the tokens who are not registered anymore.
        if (
          error.code === "messaging/invalid-registration-token" ||
          error.code === "messaging/registration-token-not-registered"
        ) {
          tokensToRemove.push(tokensSnapshot.ref.child(tokens[index]).remove());
        }
      }
    });
    return Promise.all(tokensToRemove);
  });

exports.sendMusicNotificationToGroup = functions.database
  .ref("/groups/{groupUid}/chats/{chatUid}")
  .onWrite(async (change, context) => {
    const groupUid = context.params.groupUid;
    const chatUid = context.params.chatUid;
    // Get the list of device notification tokens.
    const getDeviceTokensPromise = admin
      .database()
      .ref(`/groups/${groupUid}/tokens`)
      .once("value");

    // Get the Group Name.
    const getGroupNamePromise = admin
      .database()
      .ref(`/groups/${groupUid}/name`)
      .once("value");

    // Get the Sender Name in the group.
    const getSenderName = admin
      .database()
      .ref(`/groups/${groupUid}/chats/${chatUid}/sender`)
      .once("value");

    // Get the Sender Device Token in the group.
    const getSenderDeviceToken = admin
      .database()
      .ref(`/groups/${groupUid}/chats/${chatUid}/senderDeviceToken`)
      .once("value");

    // The snapshot to the user's tokens.
    let tokensSnapshot;

    // The array containing all the user's tokens.
    let tokens;

    const results = await Promise.all([
      getDeviceTokensPromise,
      getGroupNamePromise,
      getSenderName,
      getSenderDeviceToken,
    ]);
    tokensSnapshot = results[0];
    const groupName = results[1].val();
    const senderName = results[2].val();
    const senderToken = results[3].val();

    // Group Name
    console.log(groupName);

    // Check if there are any device tokens.
    if (tokensSnapshot.count === 0) {
      return console.log("There are no notification tokens to send to.");
    }

    // Tokens Value
    console.log(tokensSnapshot.val());
    console.log(senderToken);
    console.log(senderName);

    // Notification details.
    const payload = {
      notification: {
        title: `${groupName} - ${senderName}`,
        body: `${groupName} - ${senderName} sent music.`,
        icon: `https://is3-ssl.mzstatic.com/image/thumb/Music113/v4/88/48/8f/88488f62-ac34-a109-569c-6cda49352855/source/100x100bb.jpg`,
        sound: "default",
      },
    };

    // Listing all tokens as an array.
    tokens = tokensSnapshot.val();

    // Filter tokens and remove Sender Token
    tokens = tokens.filter(function (str) {
      return str !== senderToken;
    });
    // Send notifications to all tokens.
    const response = await admin.messaging().sendToDevice(tokens, payload);
    // For each message check if there was an error.
    const tokensToRemove = [];
    response.results.forEach((result, index) => {
      const error = result.error;
      if (error) {
        console.error("Failure sending notification to", tokens[index], error);
        // Cleanup the tokens who are not registered anymore.
        if (
          error.code === "messaging/invalid-registration-token" ||
          error.code === "messaging/registration-token-not-registered"
        ) {
          tokensToRemove.push(tokensSnapshot.ref.child(tokens[index]).remove());
        }
      }
    });
    return Promise.all(tokensToRemove);
  });

exports.receivedFriendRequestNotification = functions.database
  .ref("/users/{userUid}/requests/{requestUid}")
  .onCreate(async (change, context) => {
    const userUid = context.params.userUid;
    const requestUid = context.params.requestUid;

    // Get the sender device token
    const getReceiverDeviceTokenPromise = admin
      .database()
      .ref(`/users/${userUid}/deviceToken`)
      .once("value");

    // Get the Sender First Name in the group.
    const getSenderFirstNamePromise = admin
      .database()
      .ref(`/users/${requestUid}/firstName`)
      .once("value");
    // Get the Sender Last Name in the group.
    const getSenderLastNamePromise = admin
      .database()
      .ref(`/users/${requestUid}/lastName`)
      .once("value");

    // The snapshot to the user's tokens.
    let tokensSnapshot;

    // The array containing all the user's tokens.
    let tokens;

    const results = await Promise.all([
      getReceiverDeviceTokenPromise,
      getSenderFirstNamePromise,
      getSenderLastNamePromise,
    ]);
    tokensSnapshot = results[0];
    const firstName = results[1].val();
    const lastName = results[2].val();

    // Check if there are any device tokens.
    if (tokensSnapshot.count === 0) {
      return console.log("There are no notification tokens to send to.");
    }

    // Log all the values
    console.log(tokensSnapshot.val());
    console.log(firstName);
    console.log(lastName);

    // Notification details.
    const payload = {
      notification: {
        title: `${firstName} ${lastName} sent you a request!`,
        body: `Open requests now to accept the friend request.`,
        icon: `https://is3-ssl.mzstatic.com/image/thumb/Music113/v4/88/48/8f/88488f62-ac34-a109-569c-6cda49352855/source/100x100bb.jpg`,
        sound: "default",
      },
    };

    // Listing all tokens as an array.
    tokens = tokensSnapshot.val();

    // Send notifications to all tokens.
    const response = await admin.messaging().sendToDevice(tokens, payload);
    // For each message check if there was an error.
    const tokensToRemove = [];
    response.results.forEach((result, index) => {
      const error = result.error;
      if (error) {
        console.error("Failure sending notification to", tokens[index], error);
        // Cleanup the tokens who are not registered anymore.
        if (
          error.code === "messaging/invalid-registration-token" ||
          error.code === "messaging/registration-token-not-registered"
        ) {
          tokensToRemove.push(tokensSnapshot.ref.child(tokens[index]).remove());
        }
      }
    });
    return Promise.all(tokensToRemove);
  });

exports.friendRequestConfirmationNotification = functions.database
  .ref("/users/{userUid}/friends/{friendUid}")
  .onCreate(async (change, context) => {
    const userUid = context.params.userUid;
    const friendUid = context.params.friendUid;

    // Get the sender device token
    const getCurrentUserDeviceTokenPromise = admin
      .database()
      .ref(`/users/${userUid}/deviceToken`)
      .once("value");

    // Get the Sender First Name in the group.
    const getFriendsFirstNamePromise = admin
      .database()
      .ref(`/users/${friendUid}/firstName`)
      .once("value");
    // Get the Sender Last Name in the group.
    const getFriendsLastNamePromise = admin
      .database()
      .ref(`/users/${friendUid}/lastName`)
      .once("value");

    // The snapshot to the user's tokens.
    let tokensSnapshot;

    // The array containing all the user's tokens.
    let tokens;

    const results = await Promise.all([
      getCurrentUserDeviceTokenPromise,
      getFriendsFirstNamePromise,
      getFriendsLastNamePromise,
    ]);
    tokensSnapshot = results[0];
    const firstName = results[1].val();
    const lastName = results[2].val();

    // Check if there are any device tokens.
    if (tokensSnapshot.count === 0) {
      return console.log("There are no notification tokens to send to.");
    }

    // Log all the values
    console.log(tokensSnapshot.val());
    console.log(firstName);
    console.log(lastName);

    // Notification details.
    const payload = {
      notification: {
        title: `You are now friends with ${firstName} ${lastName}!`,
        body: `Send music.`,
        icon: `https://is3-ssl.mzstatic.com/image/thumb/Music113/v4/88/48/8f/88488f62-ac34-a109-569c-6cda49352855/source/100x100bb.jpg`,
        sound: "default",
      },
    };

    // Listing all tokens as an array.
    tokens = tokensSnapshot.val();

    // Send notifications to all tokens.
    const response = await admin.messaging().sendToDevice(tokens, payload);
    // For each message check if there was an error.
    const tokensToRemove = [];
    response.results.forEach((result, index) => {
      const error = result.error;
      if (error) {
        console.error("Failure sending notification to", tokens[index], error);
        // Cleanup the tokens who are not registered anymore.
        if (
          error.code === "messaging/invalid-registration-token" ||
          error.code === "messaging/registration-token-not-registered"
        ) {
          tokensToRemove.push(tokensSnapshot.ref.child(tokens[index]).remove());
        }
      }
    });
    return Promise.all(tokensToRemove);
  });

exports.limitGroupChatMessages = functions.database
  .ref("/groups/{groupUid}/chats/{chatId}")
  .onWrite(async (change) => {
    const parentRef = change.after.ref.parent;
    const snapshot = await parentRef.once("value");
    if (snapshot.numChildren() >= 50) {
      let childCount = 0;
      const updates = {};
      snapshot.forEach((child) => {
        if (++childCount <= snapshot.numChildren() - 50) {
          updates[child.key] = null;
        }
      });
      // Update the parent. This effectively removes the extra children.
      return parentRef.update(updates);
    }
    return null;
  });
