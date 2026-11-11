<script setup>
    import { useGlobalState } from '../stores/globalStore';
    import TabMenu from 'primevue/tabmenu';
    import { fetchNui } from '../utils';
    import { ref } from "vue";

    const globalState = useGlobalState();

    const TakeContract = (data) => {
        fetchNui("takeOrder", data);
        globalState.changeCurrentTab("current");
        globalState.current.value = data
    }
</script>

<template>
    <div class="Container">
        <div v-for="(item, index) in globalState.contracts.value" :key="index">
            <Card>
                <template #header >
                    <div class="LogoHeader">
                        <img src="../assets/atm.png" alt="">
                    </div>
                </template>
                <template #title>{{ item.title }}</template>
                <template #subtitle>{{ item.description }}</template>  
                <template #footer>
                    <div class="Buttons">
                        <Button @click="TakeContract(item)" :label="globalState.locale.value.ui_take_contract" class="w-full" />
                    </div>
                </template>
            </Card>
        </div>

    </div>
</template>

<style scoped lang="scss">
    .Container {
        display: flex;
        flex-flow: row wrap;
        color: white;
        overflow: auto;
        width: 100%;
        height: 100%; 
        gap: 2vh;
        padding-left: 5%;
        
        .p-card {
            display: flex;
            width: 25vh;
            height: 35vh;
            overflow: hidden;
            background-color: #18181b;
            border-radius: 0.5vh;

            .LogoHeader {
                width: 100%;

                img {
                    width: 100%;
                    height: 13vh;
                }
            }

            .Buttons {
                display: flex;
                justify-content: center;
                flex-flow: row;
                gap: 1vh;

                Button {
                    width: 100%;
                }
            }
        }

    }

    ::-webkit-scrollbar {
        width: 1vh;
    }
    
    ::-webkit-scrollbar-track {
    }
    
    ::-webkit-scrollbar-thumb {
        background: #888;
        border-radius: 1vh;
    }

    ::-webkit-scrollbar-thumb:hover {
        background: #555;
    }
</style>