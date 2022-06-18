<template>
    <div class="send">
        <form name="sendForm">
            <textarea
                cols="30"
                rows="2"
                autofocus
                v-model="inputText"
                @input="activateButton()"
                @keydown.alt.enter="send()"
            ></textarea>
            <div
                class="send-button"
                @click="send()"
                v-bind:style="{ 'border-left-color': buttonColor }"
            ></div>
        </form>
    </div>
</template>

<script setup lang="ts">
import { ref } from "vue";

import { Message } from "@/dto/message";

interface Emits {
    (e: "input", value: Message): void;
}

const emit = defineEmits<Emits>();

const local_url = "http://localhost:8080/callback";
const dev_url = "https://api.gokabot.com/callback";
const url = ref(dev_url);
const buttonColor = ref("gray");
const inputText = ref("");

const activateButton = () => {
    buttonColor.value = isActive() ? "royalblue" : "gray";
};

const isActive = () => {
    return inputText.value.length > 0;
};

const switchUrl = (msgText: string) => {
    if (msgText != "dev" && msgText != "local") {
        return false;
    }

    if (msgText == "dev" && url.value != dev_url) {
        url.value = local_url;
    }

    if (msgText == "local" && url.value != local_url) {
        url.value = local_url;
    }

    return true;
};

const send = async () => {
    if (!isActive()) return;

    const msgText = inputText.value;
    inputText.value = "";

    // send myself message to super-component
    console.info("Message: " + msgText);
    emit("input", new Message(0, msgText, "my-message"));

    // send switching URL info as reply message to super-component
    if (switchUrl(msgText)) {
        emit("input", new Message(0, "Switch URL to " + url.value, "reply-message"));
        return;
    }

    sendRequest(msgText)
        .then((resJson) => {
            console.debug("sendRequest");
            const reply = getReply(resJson);

            if (reply) {
                console.info("Reply: " + reply);
                emit("input", new Message(0, reply, "reply-message"));
            }
        })
        .catch((err) => {
            console.error(err);
        });
};

const sendRequest = async (msgText: string) => {
    console.debug(mkRequest(msgText));
    const response = await fetch(mkRequest(msgText));
    console.info(response);

    if (response.ok) {
        const resJson = await response.json();
        console.info(resJson);
        return resJson;
    }

    throw new Error("Response error");
};

const mkRequest = (msgText: string) => {
    const reqHeaders = {
        Accept: "application/json",
        "Content-Type": "application/json; charset=utf-8",
    };

    const reqBody = {
        msg: msgText,
        user_id: "U0123456789abcdefghijklmnopqrstuv",
        user_name: "gokabot-demo",
    };

    return new Request(url.value, {
        method: "POST",
        mode: "cors",
        headers: reqHeaders,
        body: JSON.stringify(reqBody),
    });
};

// eslint-disable-next-line @typescript-eslint/no-explicit-any
const getReply = (resJson: any) => {
    if (resJson["type"] == "text") {
        return resJson["text"];
    }
};
</script>

<style scoped>
.send {
    position: fixed;
    bottom: 0;
    padding: 7px;
    background-color: white;
    width: 100%;
}

form[name="sendForm"] {
    display: flex;
    align-items: center;
}

textarea {
    width: 90%;
    width: calc(100% - 84px);
    padding: 5px;
    border-radius: 10px;
    border-width: 2px;
    overflow: hidden;
    font-size: 20px;
}

.send-button {
    width: 0;
    height: 0;
    margin-left: 9px;
    border-left: 45px solid gray;
    border-top: 21px solid transparent;
    border-bottom: 21px solid transparent;
}

@media (max-width: 767px) {
    .send {
        padding: 4px;
    }

    form[name="sendForm"] {
        display: flex;
        align-items: center;
    }

    textarea {
        width: calc(100% - 55px);
        padding: 3px;
        border-radius: 7px;
        border-width: 2px;
        font-size: 13px;
    }

    .send-button {
        margin-left: 6px;
        border-left: 30px solid gray;
        border-top: 14px solid transparent;
        border-bottom: 14px solid transparent;
    }
}
</style>
