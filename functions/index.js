const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

// Trigger on new expense
exports.notifyExpenseExceedsIncome = functions.firestore
    .document("users/{userId}/transactions/{transactionId}")
    .onCreate(async (snap, context) => {
      const userId = context.params.userId;
      const transaction = snap.data();

      if (transaction.type !== "expense") return null;

      const userDoc = await admin.firestore()
          .collection("users").doc(userId).get();
      if (!userDoc.exists) return null;

      const balance = userDoc.data().balance || {};
      const monthlyIncome = balance.monthlyIncome || 0;
      const monthlyExpense = balance.monthlyExpense || 0;

      if (monthlyExpense <= monthlyIncome) return null;

      const fcmToken = userDoc.data().fcmToken;
      if (!fcmToken) return null;

      const payload = {
        notification: {
          title: "Expense Limit Exceeded",
          body: "You have spent more than your income this month!",
        },
        data: {type: "overspend"},
      };

      return admin.messaging().sendToDevice(fcmToken, payload);
    });
