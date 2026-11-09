import { ref } from 'vue';
import { createGlobalState } from '@vueuse/core';
import { fetchNui, isEnvBrowser } from '../utils';

export const useGlobalState = createGlobalState(() => {
        const visible = ref(isEnvBrowser());
        const currentTab = ref("contracts");
        const contracts = ref([]);
        const group = ref({});
        const current = ref({});
        const locale = ref({});

        const changeCurrentTab = (newTab) => {
            currentTab.value = newTab;
        };

        window.addEventListener("message", (event) => {
            if (event.data.type == "visible") {
                visible.value = event.data.value;
            } else if (event.data.type == "contracts") {
                contracts.value = event.data.value;
            } else if (event.data.type == "group") {
                group.value = event.data.value;
            } else if (event.data.type == "locale") {
                locale.value = event.data.value;
            } else if (event.data.type == "page") {
                currentTab.value = event.data.value;
            } else if (event.data.type == "current") {
                current.value = event.data.value;
            }
        });

        window.addEventListener("keydown", (event) => {
            if (event.key == "Escape") {
                fetchNui("close");
            }
        })

        return { visible, currentTab, changeCurrentTab, contracts, group, current, locale }
    }
);