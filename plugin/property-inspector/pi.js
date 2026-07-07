let websocket;
let uuid;
let actionInfo;
let settings = {};

const defaults = {
  "com.aiapproval.buttons.yesonce": "1{ENTER}",
  "com.aiapproval.buttons.always": "2{ENTER}",
  "com.aiapproval.buttons.no": "3{ENTER}",
  "com.aiapproval.buttons.custom": "{ENTER}",
  "com.aiapproval.buttons.newchat": "^n",
  "com.aiapproval.buttons.modelmenu": "^+m"
};

function connectElgatoStreamDeckSocket(inPort, inUuid, inRegisterEvent, inInfo, inActionInfo) {
  uuid = inUuid;
  actionInfo = JSON.parse(inActionInfo);
  websocket = new WebSocket(`ws://127.0.0.1:${inPort}`);

  websocket.onopen = () => {
    websocket.send(JSON.stringify({ event: inRegisterEvent, uuid }));
    websocket.send(JSON.stringify({ event: "getSettings", context: uuid }));
  };

  websocket.onmessage = (event) => {
    const message = JSON.parse(event.data);
    if (message.event === "didReceiveSettings") {
      settings = message.payload.settings || {};
      render();
    }
  };
}

function render() {
  const sequence = document.getElementById("sequence");
  sequence.value = settings.sequence || defaults[actionInfo.action] || "{ENTER}";
}

function save(sequence) {
  settings.sequence = sequence;
  websocket.send(JSON.stringify({
    event: "setSettings",
    context: uuid,
    payload: settings
  }));
}

document.addEventListener("DOMContentLoaded", () => {
  const sequence = document.getElementById("sequence");
  const preset = document.getElementById("preset");

  sequence.addEventListener("input", () => save(sequence.value));
  preset.addEventListener("change", () => {
    if (!preset.value) {
      return;
    }
    sequence.value = preset.value;
    save(preset.value);
    preset.value = "";
  });
});
