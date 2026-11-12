(async () => {
    const RESOURCE_NAME = 'qbx_chat_theme';

    const data = await fetchNui('config');

    /** @type {{ property: string; value: string | null }[]} */
    const vars = [
        { property: '--main-color', value: data.mainColor },
        { property: '--border-color', value: data.borderColor },
        { property: '--text-color', value: data.textColor },
        { property: '--faint-color', value: data.faintColor },
        { property: '--font-family', value: data.fontFamily },
        { property: '--console-font-family', value: data.consoleFontFamily },
        { property: '--suggestion-font-family', value: data.suggestionFontFamily },
        { property: '--input-icon-url', value: `url(${data.inputIconUrl})` },
        { property: '--message-icon-url', value: `url(${data.messageIconUrl})` },
        { property: '--console-icon-url', value: `url(${data.consoleIconUrl})` },
        { property: '--join-icon-url', value: `url(${data.joinIconUrl})` },
        { property: '--quit-icon-url', value: `url(${data.quitIconUrl})` },
        { property: '--user-icon-url', value: `url(${data.userIconUrl})` },
    ];

    for (const { property, value } of vars) {
        document.documentElement.style.setProperty(property, value);
    }

    /**
     * @param {string} endpoint
     * @param {unknown} data
     */
    async function fetchNui(endpoint, data) {
        const body = typeof data === 'undefined' || data === null ? null : JSON.stringify(data);

        const response = await fetch(`https://${RESOURCE_NAME}/${endpoint}`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body,
        });

        return await response.json();
    }
})();

// Highcrest: fade each chat message out after FADE_AFTER ms; show them all while the chat input is open.
(() => {
    const FADE_AFTER = 8000;

    const fadeLater = (node) => {
        if (!(node instanceof HTMLElement) || !node.classList.contains('msg')) return;
        setTimeout(() => node.classList.add('hc-faded'), FADE_AFTER);
    };

    const start = () => {
        const list = document.querySelector('.chat-messages');
        if (!list) return setTimeout(start, 500);
        list.querySelectorAll('.msg').forEach(fadeLater);
        new MutationObserver((changes) => {
            changes.forEach((change) => change.addedNodes.forEach(fadeLater));
        }).observe(list, { childList: true, subtree: true });
    };
    start();

    // The chat input only exists / shows while the player is typing.
    setInterval(() => {
        const input = document.querySelector('.chat-input');
        const typing = !!input && input.offsetParent !== null && getComputedStyle(input).display !== 'none';
        document.body.classList.toggle('hc-typing', typing);
    }, 250);
})();
