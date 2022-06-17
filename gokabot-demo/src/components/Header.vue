<template>
    <header>ごかぼっと</header>
</template>

<script setup lang="ts"></script>

<style scoped>
header {
    position: fixed;
    top: 0;
    width: 100%;
    padding: 15px;
    background-color: #203750;
    color: white;
    font-size: 36px;
}

@media (max-width: 767px) {
    header {
        padding: 10px;
        font-size: 24px;
    }
}
</style>
