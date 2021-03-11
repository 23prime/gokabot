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
                v-bind:style="{ 'border-left-color': this.buttonColor }"
            ></div>
        </form>
    </div>
</template>

<script lang="ts">
import { Component, Emit, Prop, Vue } from "vue-property-decorator";
import { Message } from "@/dto/message";

@Component
export default class Send extends Vue {
    private local_url = "http://localhost:8080/callback";
    private dev_url = "https://gokabot.com/callback";
    private url = this.dev_url;

    private buttonColor = "gray";

    private inputText = "";

    @Prop()
    private value?: Message;

    @Emit()
    // eslint-disable-next-line @typescript-eslint/no-unused-vars, @typescript-eslint/no-empty-function
    private input(value: Message) {}

    private activateButton() {
        this.buttonColor = this.isActive() ? "royalblue" : "gray";
    }

    private isActive() {
        return this.inputText.length > 0;
    }

    private switchUrl(msgText: string) {
        if (msgText != "dev" && msgText != "local") {
            return false;
        }

        if (msgText == "dev" && this.url != this.dev_url) {
            this.url = this.local_url;
        }

        if (msgText == "local" && this.url != this.local_url) {
            this.url = this.local_url;
        }

        return true;
    }

    private send() {
        if (!this.isActive()) {
            return;
        }

        const msgText = this.inputText;
        this.inputText = "";

        // send myself message to super-component
        this.input(new Message(0, msgText, "my-message"));
        console.info("Message: " + msgText);

        // send switching URL info as reply message to super-component
        if (this.switchUrl(msgText)) {
            this.input(new Message(0, "Switch URL to " + this.url, "reply-message"));
            return;
        }

        this.sendRequest(msgText)
            .then((resJson) => {
                const reply = this.getReply(resJson);

                if (reply) {
                    console.info("Reply: " + reply);
                    this.input(new Message(0, reply, "reply-message"));
                }
            })
            .catch((err) => {
                console.error(err);
            });
    }

    private async sendRequest(msgText: string) {
        console.debug(this.mkRequest(msgText));
        const response = await fetch(this.mkRequest(msgText));
        console.info(response);

        if (response.ok) {
            const resJson = await response.json();
            console.info(resJson);
            return resJson;
        }

        throw new Error("Response error");
    }

    private mkRequest(msgText: string) {
        const reqHeaders = {
            Accept: "application/json",
            "Content-Type": "application/json; charset=utf-8",
        };

        const reqBody = {
            msg: msgText,
            user_id: "U0123456789abcdefghijklmnopqrstuv",
            user_name: "gokabot-demo",
        };

        return new Request(this.url, {
            method: "POST",
            mode: "cors",
            headers: reqHeaders,
            body: JSON.stringify(reqBody),
        });
    }

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    private getReply(resJson: any) {
        if (resJson["type"] == "text") {
            return resJson["text"];
        }
    }
}
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
