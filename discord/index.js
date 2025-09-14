const functions = require("@google-cloud/functions-framework");
const nacl = require("tweetnacl");

const { DISCORD_APP_ID, DISCORD_PUBLIC_KEY } = process.env;

const INTERACTION_VERSION = 1;
const INTERACTION_TYPES = {
  ping: 1,
};

functions.http("discordBot", (req, res) => {
  const { version, application_id: appId, type: interactionType } = req.body;

  if (req.method !== "POST") {
    return res.status(400).end({ error: "only POST accepted" });
  }
  if (appId !== DISCORD_APP_ID) {
    return res.status(401).end({ error: "invalid application ID" });
  }
  if (!verifySig(req)) {
    return res.status(401).end({ error: "invalid request signature" });
  }
  if (version !== INTERACTION_VERSION) {
    return res.status(400).end({ error: "version must be 1" });
  }
  if (interactionType === INTERACTION_TYPES.ping) {
    return res.end({ type: 1 });
  }

  return res.end({});
});

function verifySig(req) {
  const signature = req.get("X-Signature-Ed25519");
  const timestamp = req.get("X-Signature-Timestamp");
  const body = req.rawBody.toString();

  return nacl.sign.detached.verify(
    Buffer.from(timestamp + body),
    Buffer.from(signature, "hex"),
    Buffer.from(DISCORD_PUBLIC_KEY, "hex")
  );
}
