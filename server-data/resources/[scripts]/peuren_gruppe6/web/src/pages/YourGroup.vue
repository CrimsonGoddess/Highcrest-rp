<script setup>
    import { useGlobalState } from '../stores/globalStore';
    import Steps from 'primevue/steps';
    import Chip from 'primevue/chip';
    import Avatar from 'primevue/avatar';
    import Button from 'primevue/button';
    import ConfirmPopup from 'primevue/confirmpopup';
    import { useConfirm } from "primevue/useconfirm";
    import { fetchNui } from '../utils';

    const globalState = useGlobalState();
    const confirm = useConfirm();
    const kick = (event, member) => {
        confirm.require({
            target: event.currentTarget,
            message: globalState.locale.value.ui_group_kick_player_confirm,
            icon: 'pi pi-exclamation-triangle',
            rejectClass: 'p-button-secondary p-button-outlined p-button-sm',
            acceptClass: 'p-button-sm',
            rejectLabel: globalState.locale.value.ui_group_kick_player_confirm_no,
            acceptLabel: globalState.locale.value.ui_group_kick_player_confirm_yes,
            accept: () => {
                fetchNui("kickMember", member);
            },
        });
    };

    const end = (event) => {
        confirm.require({
            target: event.currentTarget,            
            message: globalState.locale.value.ui_group_end_job_confirm,
            icon: 'pi pi-exclamation-triangle',
            rejectClass: 'p-button-secondary p-button-outlined p-button-sm',
            acceptClass: 'p-button-sm',
            rejectLabel: globalState.locale.value.ui_group_end_job_confirm_no,
            acceptLabel: globalState.locale.value.ui_group_end_job_confirm_yes,
            accept: () => {
                fetchNui("close");
                fetchNui("endJob");
            },
        });
    };    
</script>

<template>
    <div class="Container">
        <img class="Logo" src="../assets/logo.png" alt="">
        <div class="Information">
            <div class="Group">
                <div class="JobDetails">
                    <div class="Header">{{ globalState.group.value.type }}</div>
                    <div class="Description">{{ globalState.group.value.description }}</div>
                </div>
                <div class="Data">
                    <Chip :label="globalState.locale.value.ui_group_id + globalState.group.value.id" />    
                    <Chip :label="globalState.locale.value.ui_group_password + globalState.group.value.pass" />        
                </div>
            </div>           
            <div class="Header">{{ globalState.locale.value.ui_group_members }}  </div> 
            <div class="Members">
                <div v-for="(member, index) in globalState.group.value.members" :key="index">
                    <div class="Member">
                        <Avatar icon="pi pi-user" style="background-color: #dee9fc; color: #1a2551" shape="circle" />
                        <div class="Name">{{ member.name.full }}</div>
                        <Button @click="kick($event, member)" v-if="!member.owner && globalState.group.value.owner" icon="pi pi-times" severity="danger" rounded outlined aria-label="Cancel" />
                        <Tag v-if="member.owner" severity="warning" :value="globalState.locale.value.ui_group_owner_tag"></Tag>
                        <ConfirmPopup></ConfirmPopup>
                    </div>
                </div>
            </div>
            <div class="Buttons" v-if="globalState.group.value.owner">
                <Button @click="end($event)" :label="globalState.locale.value.ui_group_end_job" severity="secondary" outlined class="w-full" />
            </div>
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

        .Logo {
            position: absolute;
            width: 12vh;
            height: 12vh;
            padding: 2vh;
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

        .Information {
            display: flex;
            align-items: center;
            justify-content: center;
            flex-flow: column;
            width: 100%;
            gap: 1vh;

            .JobDetails {
                display: flex;
                justify-content: center;
                align-items: center;
                flex-flow: column;
                gap: 1vh;

                .Header {
                    font-size: 2.5vh;
                    font-weight: bold;
                }

                .Description {
                    color: rgb(153, 153, 153);
                }
            }

            .Group {
                display: flex;
                justify-content: center;
                align-items: center;
                flex-flow: column;
                height: 12vh;
                width: 100%;
                gap: 2vh;  

                .Data {
                    display: flex;
                    justify-content: center;
                    align-items: center;
                    flex-flow: row;
                    gap: 1vh;
                }
            }
        }
        .Members {
            display: flex;
            align-items: center;      
            flex-flow: column;
            gap: 1vh;
            padding-right: 1vh;
            height: 19vh;            
            overflow: auto;

            .Member {
                display: flex;
                align-items: center;
                flex-flow: row;
                gap: 2vh;
                width: 50vh;
                background-color: #3f3f46;
                border-radius: 0.5vh;
                min-height: 4vh;
                padding: 1vh;
                height: 3vh;

                .Name {
                    font-size: 1.8vh;
                    font-family: 'Poppins', sans-serif;
                    width: 100%;
                    overflow: hidden;
                    text-overflow: ellipsis;
                    white-space: nowrap;
                }

                .p-avatar {
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    height: 3vh;
                    width: 3vh;
                    min-width: 3vh;
                    background-color: rgb(158, 161, 161);
                    border-radius: 50vh;    
                    color: white;   
                    font-size: 2.5vh;

                }

                .p-button {
                    width: 3vh;
                    height: 3vh;
                    min-width: 3vh;
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