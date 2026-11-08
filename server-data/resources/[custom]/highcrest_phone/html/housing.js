'use strict';

/* Housing. Houses come from the server, which also does every purchase and rental. */

const housePhotoCache = new Map();
const housePhotoWaiters = new Map();

function requestHousePhoto(id) {
    if (housePhotoCache.has(id)) return Promise.resolve(housePhotoCache.get(id));
    return new Promise((resolve) => {
        if (!housePhotoWaiters.has(id)) {
            housePhotoWaiters.set(id, []);
            post_('housingPhotoGet', id);
            setTimeout(() => finishHousePhoto(id, null), 20000);
        }
        housePhotoWaiters.get(id).push(resolve);
    });
}

function finishHousePhoto(id, src) {
    const waiters = housePhotoWaiters.get(id);
    if (!waiters) return;
    housePhotoWaiters.delete(id);
    if (src) housePhotoCache.set(id, src);
    waiters.forEach((resolve) => resolve(src));
}

window.addEventListener('message', ({ data }) => {
    if (data.action === 'housePhoto') finishHousePhoto(data.id, data.src || null);
});

function housingMessage(result, fallback) {
    setError('housingError', '');
    $('housingNotice').textContent = '';
    if (!result || result.error) {
        setError('housingError', (result && result.error) || fallback);
        return false;
    }
    if (result.message) $('housingNotice').textContent = result.message;
    return true;
}

function housePrices(house) {
    const parts = [];
    if (house.salePrice) parts.push(`Buy ${dollars(house.salePrice)}`);
    if (house.rentPrice) parts.push(`Rent ${dollars(house.rentPrice)} every ${house.rentHours}h`);
    return parts.join(' | ');
}

function renderHousing(data) {
    show('housing');

    $('housingMineBox').hidden = data.mine.length === 0;
    $('housingMine').replaceChildren(...data.mine.map((home) => {
        const card = el('article', 'card');
        const status = home.renting ? `Renting, ${dollars(home.rentPrice)} every ${home.rentHours}h` : 'Owned';
        const actions = el('div', 'card-actions');
        actions.append(button('Waypoint', 'text-button', () => setWaypoint(home)));
        card.append(el('strong', '', home.address), el('p', 'muted', status), actions);
        return card;
    }));

    $('housingEmpty').hidden = data.houses.length > 0;
    $('housingManageHint').hidden = !data.canManage;
    $('housingList').replaceChildren(...data.houses.map((house) => {
        const card = el('article', 'card');
        if (house.hasPhoto) {
            const image = el('img', 'card-image');
            image.alt = '';
            requestHousePhoto(house.id).then((src) => { if (src) image.src = src; });
            card.append(image);
        }

        const head = el('div', 'card-head');
        head.append(el('strong', '', house.address));
        card.append(head, el('p', 'muted', housePrices(house)));
        if (house.shellLabel) card.append(el('p', 'muted', house.shellLabel));

        const act = (op, label, armed) => confirmButton(label, armed, async () => {
            const result = await post_(op, house.id);
            if (housingMessage(result, 'That did not work. Try again.')) refreshHousing();
        });

        const actions = el('div', 'card-actions');
        actions.append(button('Waypoint', 'text-button', () => setWaypoint(house)));
        if (house.salePrice) actions.append(act('housingBuy', 'Buy', `Press again to pay ${dollars(house.salePrice)}`));
        if (house.rentPrice) actions.append(act('housingRent', 'Rent', `Press again to rent for ${dollars(house.rentPrice)}`));
        if (data.canManage) actions.append(act('housingRemove', 'Remove', 'Press again to remove'));
        card.append(actions);
        return card;
    }));
}

async function refreshHousing() {
    const data = await post_('housingGet');
    if (data) renderHousing(data);
}

openers.housing = async () => {
    show('housing');
    setError('housingError', '');
    $('housingNotice').textContent = '';
    await refreshHousing();
};
