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
        <Send v-model="newMsg" />
    </div>
</template>

<script lang="ts">
import { Component, Vue, Watch } from "vue-property-decorator";
import { Message } from "@/dto/message";
import Send from "@/components/Send.vue";
import $ from "jquery";

@Component({
    components: {
        Send,
    },
})
export default class Messages extends Vue {
    private msgId = 0;

    private newMsg: Message = new Message(this.msgId, "こん", "reply-message");

    private msgs: Message[] = [];

    private created() {
        // print initial message
        this.printMsg();
    }

    @Watch("newMsg")
    private printMsg() {
        this.newMsg.id = this.msgId;
        console.info(this.newMsg);
        this.msgId++;
        this.msgs.push(this.newMsg);
        this.scrollBottom();
    }

    private scrollBottom() {
        $("html, body").animate({ scrollTop: $(document).height() }, "fast");
    }
}
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
