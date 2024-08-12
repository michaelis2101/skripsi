const functions = require("firebase-functions");
const admin = require("firebase-admin");
const {createClient} = require("@supabase/supabase-js");

// Initialize Firebase Admin SDK
initializeApp();

// Initialize Supabase client
const supabase = createClient("https://wweyukblyptkrbhwhcaw.supabase.co",
    "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Ind3ZXl1a2JseXB0a3JiaHdoY2F3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTIwNDg3MDMsImV4cCI6MjAyNzYyNDcwM30.3RpcktL4y6V0Yv_Y6YByAgXJRnPqJZzGg8wah5UjWjI");

// Get reference to the device_log collection in RTDB
const deviceLogRef = admin.database().ref("device_log");

exports.listeningDevicesValue = functions.database.ref("devices").onWrite((change, context) => {
  const snapshot = change.after;

  return Promise.all(snapshot.forEach((deviceSnapshot) => {
    const deviceId = deviceSnapshot.key;
    const deviceData = deviceSnapshot.val();

    if (Object.prototype.hasOwnProperty.call(deviceData, "value")) {
      const deviceValue = deviceData.value;
      const timestamp = admin.database.ServerValue.TIMESTAMP;

      const rtdbPushTask = deviceLogRef.push({
        deviceId,
        data: deviceValue,
        timestamp,
      });

      const supabasePushLog = supabase.from("device_log").insert({
        device_name: deviceData.deviceName, // Assuming "deviceName" exists
        value: deviceValue,
      });

      return Promise.all([rtdbPushTask, supabasePushLog])
          .then(([rtdbResult, supabaseResult]) => {
            console.log("Data pushed to RTDB:", rtdbResult);
            console.log("Data pushed to Supabase:", supabaseResult);
          })
          .catch((error) => {
            console.error("Error pushing data:", error);
          });
    }
  }));
});
