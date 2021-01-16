<template>
    <div class="home">
        <Header />
        <Messages />
    </div>
</template>

<script lang="ts">
import { Component, Vue } from "vue-property-decorator";
import Header from "@/components/Header.vue";
import Messages from "@/components/Messages.vue";

@Component({
    components: {
        Header,
        Messages,
    },
})
export default class Home extends Vue {}
</script>
