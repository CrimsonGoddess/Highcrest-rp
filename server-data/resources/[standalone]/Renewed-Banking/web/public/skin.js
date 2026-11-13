// Adds body.atm-skin while the ATM screen is open. Reads the `atm` flag the client already sends with setVisible.
// shortcut: relies on Renewed-Banking's setVisible message shape, re-check after a Renewed update.
// Keypad keys sent from client/atm_dui.lua. Typed into whichever input the mouse focused.
function typeKey(key) {
    const el = document.activeElement;
    if (!el || el.tagName !== 'INPUT') return;
    if (key === 'Enter') return el.blur();
    el.value = key === 'Backspace' ? el.value.slice(0, -1) : el.value + key;
    el.dispatchEvent(new Event('input', { bubbles: true }));
}

window.addEventListener('message', (event) => {
    const data = event.data;
    if (!data) return;
    if (data.type === 'key') return typeKey(data.key);
    if (data.action !== 'setVisible') return;
    document.body.classList.toggle('atm-skin', data.atm === true && data.status === true);
});
