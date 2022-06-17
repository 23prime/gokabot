<template>
    <div>
        <div class="messages">
            <div v-for="msg in msgs" v-bind:key="msg.id">
                <div :class="msg.sender">
                    <div class="message">
                        <pre>{{ msg.text }}</pre>
                    </div>
                </div>
            </div>
        </div>
        <Send @input="printMsg($event)" />
    </div>
</template>

<script setup lang="ts">
import { Ref, ref } from "vue";
import { Message } from "@/dto/message";
import Send from "@/components/Send.vue";
import $ from "jquery";

let msgId = 0;
const msgs: Ref<Message[]> = ref([]);

const printMsg = (msg: Message) => {
    msg.id = msgId;
    console.info(msg);
    console.info(msgs);
    msgId++;
    msgs.value.push(msg);
    scrollBottom();
};

const scrollBottom = () => {
    $("html, body").animate({ scrollTop: $(document).height() }, "fast");
};

const initialMsg = new Message(msgId, "こん", "reply-message");
printMsg(initialMsg);
</script>

<style scoped>
pre {
    white-space: pre-wrap;
}

.messages {
    margin: 72px 0;
}

.message {
    background-color: white;
    margin: 8px;
    text-align: left;
    border-radius: 14px;
    display: inline-block;
    padding: 16px;
    max-width: 80%;
    font-size: 24px;
}

.reply-message {
    padding-right: 42px;
}

.my-message {
    padding-left: 42px;
    text-align: right;
}

@media (max-width: 767px) {
    .messages {
        margin: 48px 0;
    }

    .message {
        margin: 6px;
        border-radius: 10px;
        padding: 10px;
        font-size: 16px;
    }

    .reply-message {
        padding-right: 28px;
    }

    .my-message {
        padding-left: 28px;
    }
}
</style>
