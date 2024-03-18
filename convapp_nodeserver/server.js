// var admin = require("firebase-admin");
// let app = express()
// var serviceAccount = require("./auth_key.json");

// let muypp = admin.initializeApp({
//   credential: admin.credential.cert(serviceAccount)
// });

// let test = muypp.auth()

// test.listUsers().then(data => console.log(data))

var admin = require("firebase-admin");
var serviceAccount = require("./auth_key.json");
const express = require("express");
let app = express();

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

let firebase_init = admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

let firebase = firebase_init.auth();

app.post("/getuserbyuid", async (req, res) => {
  if (!req.body.id) {
    return res.status(500).json({
      error: "Une erreur s'est produite. Veuillez selectionner un utilisateur.",
    });
  }
  try {
    let user = await firebase.getUser(req.body.id);
    return res.json({ email: user.email });
  } catch (error) {
    return res.status(500).json({ error: error.errorInfo.message });
  }
});

app.get("/getusers/:uid", async (req, res) => {
  let userListFiltered = [];
  try {
    let userListFetch = await firebase.listUsers();
    Promise.all(
      userListFetch.users.map((user) => {
        if (user.uid != req.params.uid) {
          userListFiltered.push(user);
        }
      })
    );
    return res.json({ users: userListFiltered });
  } catch (error) {
    return res.status(500).json(error);
  }
});

app.post("/createconversation", async (req, res) => {
  if (!req.body.between) {
    return res
      .status(500)
      .json({ error: "Veuillez specifier un ou plusieurs utilisateurs" });
  }
  let checkIfConversationExists = await admin
    .firestore()
    .collection("conversations")
    .where("between", "==", req.body.between)
    .get();

  if(checkIfConversationExists.docs[0]) {
    return res.status(500).json({ error: "Cette conversation existe déjà." });
  }

  let createConversation = await admin
    .firestore()
    .collection("conversations")
    .add({
      between: req.body.between,
      last_message_at: Date.now(),
    });

  return res.json({ uid: createConversation.id });
});

app.listen(5500, () => console.log("Server opened on : " + 5500));
