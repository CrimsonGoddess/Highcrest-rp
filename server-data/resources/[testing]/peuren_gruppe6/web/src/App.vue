<script setup>
  import Header from "./components/Header.vue";
  import Contracts from "./pages/Contracts.vue";
  import YourGroup from  "./pages/YourGroup.vue";
  import CurrentOrder from "./pages/CurrentOrder.vue";

  import { useGlobalState } from "./stores/globalStore";
  const globalState = useGlobalState();
</script>

<template>
  <div class="MainContainer" v-if="globalState.visible.value">
    <div class="Content">
      <Header v-if="globalState.currentTab.value != 'current'" />
      <div class="Contents">
        <Contracts v-if="globalState.currentTab.value == 'contracts'" />
        <YourGroup v-if="globalState.currentTab.value == 'group'" />
        <CurrentOrder v-if="globalState.currentTab.value == 'current'" />
      </div>
    </div>
  </div>
</template>

<style scoped lang="scss">
  .MainContainer {
    display: flex;
    justify-content: center;
    align-items: center;
    height: 100vh;

    .Content {
      display: flex;
      align-items: center;
      flex-flow: column;
      width: 90vh;
      background-color: rgb(32, 32, 32);
      border-radius: 0.5vh;

      .Contents {
        display: flex;
        justify-content: center;
        align-items: center;
        height: 45vh;
        width: 100%;        
        padding: 1.5vh;
      }
    }
  }
</style>
