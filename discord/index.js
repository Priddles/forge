const functions = require("@google-cloud/functions-framework");
const nacl = require("tweetnacl");

const { DISCORD_APP_ID, DISCORD_PUBLIC_KEY } = process.env;

const INTERACTION_VERSION = 1;
const INTERACTION_TYPES = {
  ping: 1,
};

functions.http("discordBot", (req, res) => {
  console.log("[BOT] received request", { method: req.method, body: req.body });

  const { version, application_id: appId, type: interactionType } = req.body;

  if (req.method !== "POST") {
    return res.status(400).send({ error: "only POST accepted" });
  }
  if (version !== INTERACTION_VERSION) {
    return res.status(400).send({ error: "version must be 1" });
  }
  if (appId !== DISCORD_APP_ID) {
    return res.status(401).send({ error: "invalid application ID" });
  }
  if (!verifySig(req)) {
    return res.status(401).send({ error: "invalid request signature" });
  }
  if (interactionType === INTERACTION_TYPES.ping) {
    return res.send({ type: 1 });
  }

  return res.send({});
});

function verifySig(req) {
  const signature = req.get("X-Signature-Ed25519");
  const timestamp = req.get("X-Signature-Timestamp");
  const body = req.rawBody.toString();

  if (!signature || !timestamp || !body) {
    return false;
  }

  return nacl.sign.detached.verify(
    Buffer.from(timestamp + body),
    Buffer.from(signature, "hex"),
    Buffer.from(DISCORD_PUBLIC_KEY, "hex")
  );
}
