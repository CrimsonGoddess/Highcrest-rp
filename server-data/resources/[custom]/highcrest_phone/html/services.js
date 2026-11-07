'use strict';

/* Find Friends, Taxi and 911. Loaded after apps.js helpers are defined, before the home icons are wired. */

const setWaypoint = (spot) => post_('setWaypoint', { x: spot.x, y: spot.y });

function expiryText(expiresAt) {
    if (!expiresAt) return 'Until you stop';
    return `Until ${new Date(expiresAt * 1000).toLocaleString([], { month: 'short', day: 'numeric', hour: '2-digit', minute: '2-digit' })}`;
}

/* Find Friends */

function renderFindFriends(data) {
    show('findFriends');

    $('friendsEmpty').hidden = data.friends.length > 0;
    $('friendsList').replaceChildren(...data.friends.map((friend) => {
        const card = el('article', 'card');
        const head = el('div', 'card-head');
        head.append(el('strong', '', friend.name || friend.number), el('span', 'muted', friend.online ? 'Online' : 'Offline'));
        const actions = el('div', 'card-actions');
        actions.append(
            button('Find on map', 'text-button', async () => {
                const spot = await post_('locationFind', friend.number);
                if (!spot || spot.error) {
                    setError('friendsError', (spot && spot.error) || 'They could not be found.');
                    return;
                }
                setError('friendsError', '');
                setWaypoint(spot);
            }),
            button('Remove', 'text-button', async () => {
                const result = await post_('locationHide', friend.number);
                if (result) renderFindFriends(result);
            }),
        );
        card.append(head, el('p', 'muted', expiryText(friend.expiresAt)), actions);
        return card;
    }));

    $('sharingEmpty').hidden = data.sharing.length > 0;
    $('sharingList').replaceChildren(...data.sharing.map((share) => {
        const card = el('article', 'card');
        const head = el('div', 'card-head');
        head.append(el('strong', '', share.name || share.number), el('span', 'muted', expiryText(share.expiresAt)));
        const actions = el('div', 'card-actions');
        actions.append(button('Stop sharing', 'text-button', async () => {
            const result = await post_('locationStop', share.number);
            if (result) renderFindFriends(result);
        }));
        card.append(head, actions);
        return card;
    }));

    $('shareContact').replaceChildren(el('option', '', 'Choose a contact'), ...contacts.map((contact) => {
        const option = el('option', '', contact.name);
        option.value = contact.number;
        return option;
    }));
}

openers.findFriends = async () => {
    show('findFriends');
    const data = await post_('locationGet');
    if (data) renderFindFriends(data);
};

document.querySelectorAll('[data-share]').forEach((choice) => {
    choice.addEventListener('click', async () => {
        const number = $('shareNumber').value.trim() || $('shareContact').value;
        const duration = choice.dataset.share;
        const result = await post_('locationShare', {
            number,
            hours: duration === 'forever' ? null : Number(duration),
            forever: duration === 'forever',
        });
        handleResult(result, 'shareError', (data) => {
            $('shareNumber').value = '';
            renderFindFriends(data);
        });
    });
});

/* Taxi */

function renderTaxi(data) {
    show('taxi');
    const request = data.request;

    $('taxiCompose').hidden = Boolean(request);
    $('taxiStatus').hidden = !request;
    if (request) {
        $('taxiStatusText').textContent = request.state === 'accepted'
            ? `${request.driverName} is on the way. Their number is ${request.driverNumber}.`
            : 'Waiting for a driver to accept...';
        $('taxiCallDriver').hidden = !request.driverNumber;
        $('taxiCallDriver').onclick = () => placeCall(request.driverNumber);
    }

    $('taxiDriver').hidden = !data.isDriver;
    if (!data.isDriver) return;

    $('taxiJob').replaceChildren();
    if (data.job) {
        const card = el('article', 'card');
        card.append(el('strong', '', `Current fare: ${data.job.name}`));
        if (data.job.note) card.append(el('p', 'card-body', data.job.note));
        const actions = el('div', 'card-actions');
        actions.append(
            button('Waypoint', 'text-button', () => setWaypoint(data.job)),
            button('Call', 'text-button', () => placeCall(data.job.number)),
            button('Finish fare', 'text-button', async () => {
                const result = await post_('taxiEnd');
                if (result) renderTaxi(result);
            }),
        );
        card.append(actions);
        $('taxiJob').append(card);
    }

    const open = data.open || [];
    $('taxiOpenEmpty').hidden = open.length > 0;
    $('taxiOpen').replaceChildren(...open.map((item) => {
        const card = el('article', 'card');
        card.append(el('strong', '', item.name));
        if (item.note) card.append(el('p', 'card-body', item.note));
        const actions = el('div', 'card-actions');
        actions.append(button('Accept', 'text-button', async () => {
            const result = await post_('taxiAccept', item.id);
            if (!result || result.error) {
                setError('taxiDriverError', (result && result.error) || 'That fare is gone.');
                openers.taxi();
                return;
            }
            setError('taxiDriverError', '');
            if (result.waypoint) setWaypoint(result.waypoint);
            renderTaxi(result);
        }));
        card.append(actions);
        return card;
    }));
}

openers.taxi = async () => {
    show('taxi');
    const data = await post_('taxiGet');
    if (data) renderTaxi(data);
};

$('taxiCall').addEventListener('click', async () => {
    const result = await post_('taxiRequest', { note: $('taxiNote').value });
    handleResult(result, 'taxiError', (data) => {
        $('taxiNote').value = '';
        renderTaxi(data);
    });
});

$('taxiCancel').addEventListener('click', async () => {
    const result = await post_('taxiEnd');
    if (result) renderTaxi(result);
});

/* 911 */

let emergencyService = 'police';

function renderEmergency(data) {
    show('emergency');
    document.querySelectorAll('[data-emergency]').forEach((choice) => {
        choice.classList.toggle('accent', choice.dataset.emergency === emergencyService);
    });

    $('emergencyDesk').hidden = !data.isResponder;
    if (!data.isResponder) return;

    $('emergencyEmpty').hidden = data.calls.length > 0;
    $('emergencyCalls').replaceChildren(...data.calls.map((call) => {
        const card = el('article', 'card');
        const head = el('div', 'card-head');
        head.append(el('strong', '', call.name), el('span', 'muted', timeAgo(call.time)));
        const actions = el('div', 'card-actions');
        actions.append(
            button('Waypoint', 'text-button', () => setWaypoint(call)),
            button('Call', 'text-button', () => placeCall(call.number)),
        );
        card.append(head, el('p', 'card-body', call.message), actions);
        return card;
    }));
}

openers.emergency = async () => {
    show('emergency');
    setError('emergencyError', '');
    $('emergencyResult').textContent = '';
    const data = await post_('emergencyGet');
    if (data) renderEmergency(data);
};

document.querySelectorAll('[data-emergency]').forEach((choice) => {
    choice.addEventListener('click', () => {
        emergencyService = choice.dataset.emergency;
        document.querySelectorAll('[data-emergency]').forEach((other) => {
            other.classList.toggle('accent', other === choice);
        });
    });
});

$('emergencySend').addEventListener('click', async () => {
    const result = await post_('emergencyCall', { service: emergencyService, message: $('emergencyMessage').value });
    handleResult(result, 'emergencyError', (data) => {
        $('emergencyMessage').value = '';
        $('emergencyResult').textContent = data.units > 0
            ? `Sent with your location. ${data.units} on duty notified.`
            : 'Sent, but no one is on duty right now.';
    });
});

/* Garage */

function renderGarage(data) {
    show('garage');
    setError('garageError', '');
    $('garageEmpty').hidden = data.vehicles.length > 0;
    $('garageList').replaceChildren(...data.vehicles.map((vehicle) => {
        const card = el('article', 'card');
        const head = el('div', 'card-head');
        head.append(el('strong', '', vehicle.brand ? `${vehicle.brand} ${vehicle.name}` : vehicle.name), el('span', `vehicle-state state-${vehicle.state}`, vehicle.stateLabel));

        const place = vehicle.state === 2 && vehicle.depotPrice > 0
            ? `Impound fee ${dollars(vehicle.depotPrice)}`
            : vehicle.garage;
        const stats = el('p', 'muted', `Plate ${vehicle.plate}${place ? ` | ${place}` : ''}`);
        const health = el('p', 'muted', `Fuel ${vehicle.fuel}% | Engine ${vehicle.engine}% | Body ${vehicle.body}%`);
        card.append(head, stats, health);

        if (vehicle.state === 0) {
            const actions = el('div', 'card-actions');
            actions.append(button('Find on map', 'text-button', async () => {
                const spot = await post_('garageLocate', vehicle.plate);
                if (!spot || spot.error) {
                    setError('garageError', (spot && spot.error) || 'Your vehicle could not be located.');
                    return;
                }
                setError('garageError', '');
                setWaypoint(spot);
            }));
            card.append(actions);
        }
        return card;
    }));
}

openers.garage = async () => {
    show('garage');
    const data = await post_('garageGet');
    if (data) renderGarage(data);
};

/* Mail */

let mailOpen = null;

function setMailBadge(count) {
    $('mailBadge').textContent = count;
    $('mailBadge').hidden = !(count > 0);
}

function renderMail(data) {
    show('mail');
    $('mailEmpty').hidden = data.mail.length > 0;
    $('mailList').replaceChildren(...data.mail.map((mail) => {
        const row = el('button', Number(mail.isRead) ? 'row' : 'row unread');
        const sender = el('strong', '', mail.sender || 'Unknown');
        row.append(sender, el('span', 'preview', mail.subject || '(No subject)'), el('span', 'muted preview', timeAgo(mail.sentAt)));
        row.addEventListener('click', () => showMailMessage(mail));
        return row;
    }));
    setMailBadge(data.mail.filter((mail) => !Number(mail.isRead)).length);
}

async function showMailMessage(mail) {
    mailOpen = mail;
    show('mailView');
    setError('mailError', '');
    $('mailSubject').textContent = mail.subject || '(No subject)';
    $('mailMeta').textContent = `${mail.sender || 'Unknown'} | ${timeAgo(mail.sentAt)}`;
    $('mailBody').textContent = mail.message || '';
    $('mailActionButton').hidden = !mail.hasAction;

    const remove = $('mailDeleteButton');
    remove.textContent = 'Delete';
    remove.classList.remove('danger');
    remove.dataset.armed = '';

    if (!Number(mail.isRead)) {
        const result = await post_('mailRead', mail.id);
        if (result) {
            mail.isRead = 1;
            setMailBadge(result.unread);
        }
    }
}

openers.mail = async () => {
    show('mail');
    const data = await post_('mailGet');
    if (data) renderMail(data);
};

backTargets.mailView = () => openers.mail();

$('mailActionButton').addEventListener('click', async () => {
    const result = await post_('mailAction', mailOpen.id);
    if (!result || result.error) {
        setError('mailError', (result && result.error) || 'That action is no longer available.');
        return;
    }
    setError('mailError', '');
    mailOpen.hasAction = false;
    $('mailActionButton').hidden = true;
});

$('mailDeleteButton').addEventListener('click', async () => {
    const remove = $('mailDeleteButton');
    if (!remove.dataset.armed) {
        remove.dataset.armed = '1';
        remove.textContent = 'Press again to delete';
        remove.classList.add('danger');
        return;
    }
    await post_('mailDelete', mailOpen.id);
    openers.mail();
});

window.addEventListener('message', ({ data }) => {
    if (data.action === 'open') setMailBadge(data.data.unreadMail || 0);
    if (data.action === 'newMail') {
        setMailBadge(Number($('mailBadge').textContent) + 1);
        if (currentView() === 'mail' && !$('phone').hidden) openers.mail();
    }
});

/* Browser preview only */
if (PREVIEW === 'garage') {
    renderGarage({ vehicles: [
        { name: 'Adder', brand: 'Truffade', plate: 'CRIM 777', state: 1, stateLabel: 'In garage', garage: 'Legion Square', fuel: 88, engine: 100, body: 96, depotPrice: 0 },
        { name: 'Sultan', brand: 'Karin', plate: 'HIGHCRST', state: 0, stateLabel: 'Out', fuel: 42, engine: 74, body: 61, depotPrice: 0 },
        { name: 'Bati 801', brand: 'Pegassi', plate: 'NIGHT 01', state: 2, stateLabel: 'Impounded', fuel: 10, engine: 40, body: 22, depotPrice: 1500 },
    ] });
}
if (PREVIEW === 'mail') {
    renderMail({ mail: [
        { id: 1, sender: 'Maze Bank', subject: 'Your statement is ready', message: 'Thanks for banking with us.', isRead: 0, sentAt: 1793000000, hasAction: false },
        { id: 2, sender: 'Pawn Shop', subject: 'Your items are ready', message: 'Come collect them.', isRead: 1, sentAt: 1792990000, hasAction: false },
    ] });
}
