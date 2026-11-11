<script setup>
  import { useGlobalState } from '../stores/globalStore';
  import TabMenu from 'primevue/tabmenu';
  import { ref } from "vue";

  const globalState = useGlobalState();
  const items = ref([
      { label: globalState.locale.value.ui_header_contracts, icon: 'pi pi-home', command: () => {
        globalState.changeCurrentTab("contracts");
      } },
      { label: globalState.locale.value.ui_header_your_group, icon: 'pi pi-chart-line', command: () => {
        globalState.changeCurrentTab("group");
      }  },
  ]);
</script>

<template>
  <div class="Container">
    <TabMenu :model="items" />
  </div>
</template>

<style scoped lang="scss">
  .Container {
    width: 100%;
    border-radius: 1vh;
    color: white !important;    
  }

</style>