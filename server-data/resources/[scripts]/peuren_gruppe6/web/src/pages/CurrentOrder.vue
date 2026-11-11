<script setup>
    import { useGlobalState } from '../stores/globalStore';
    import Steps from 'primevue/steps';
    import { ref } from "vue";
    import ConfirmPopup from 'primevue/confirmpopup';
    import { useConfirm } from "primevue/useconfirm";
    import { fetchNui } from '../utils';

    const globalState = useGlobalState();
    const confirm = useConfirm();
    const cancel = (event, contract) => {
        confirm.require({
            target: event.currentTarget,            
            message: globalState.locale.value.ui_cancel_contract_confirm,
            icon: 'pi pi-exclamation-triangle',
            rejectClass: 'p-button-secondary p-button-outlined p-button-sm',
            acceptClass: 'p-button-sm',
            rejectLabel: globalState.locale.value.ui_cancel_contract_confirm_no,
            acceptLabel: globalState.locale.value.ui_cancel_contract_confirm_yes,
            accept: () => {
                globalState.changeCurrentTab("contracts");
                globalState.current.value = {};
                fetchNui("cancelOrder", contract);
            }
        });
    };

    const items = ref([
        {
            label: globalState.locale.value.ui_contract_progress_pickup
        },
        {
            label: globalState.locale.value.ui_contract_progress_transport,
        },
        {
            label: globalState.locale.value.ui_contract_progress_deliver
        }
    ]);
</script>

<template>
    <div class="Container">
        <Card>
            <template #header >
                <div class="LogoHeader">
                    <img src="../assets/atm.png" alt="">
                </div>
            </template>
            <template #title>{{ globalState.current.value.title }}</template>
            <template #subtitle>{{ globalState.current.value.description }}</template>  
            <template #footer>
                <div class="Buttons">
                    <ConfirmPopup></ConfirmPopup>
                    <Button @click="cancel($event, globalState.current.value)" :label="globalState.locale.value.ui_cancel_contract" severity="secondary" outlined class="w-full" />
                </div>
            </template>
        </Card>
        <div class="Information">
            <div class="Progress">
                <div class="Header">{{ globalState.locale.value.ui_job_progress }}</div>
                <div class="Steps">
                    <Steps v-model:activeStep="globalState.current.value.progress" :model="items" />
                </div>
            </div>
            <Panel :header="globalState.locale.value.ui_contract_progress_header">
                <p class="m-0">
                    {{ globalState.locale.value.ui_contract_progress_description }}
                </p>
            </Panel>
        </div>
    </div>
</template>

<style scoped lang="scss">
    .Container {
        display: flex;
        flex-flow: row;
        color: white;
        width: 100%;
        height: 100%;
        background-color: #18181b;
        border-radius: 0.5vh;
        margin: 1vh;

        .p-card {
            display: flex;
            width: 30vh;
            overflow: hidden;
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

        .Information {
            display: flex;
            align-items: center;
            flex-flow: column;
            width: 100%;

            .p-panel {
                border: none;
                border-radius: 0;
                width: 100%;
            }

            .Progress {
                display: flex;
                justify-content: center;
                align-items: center;
                flex-flow: column;
                padding: 1vh;
                height: 12vh;
                width: 100%;
                gap: 2vh;
    
                .Steps {
                    width: 100%;
                }
            }
        }

    }
</style>