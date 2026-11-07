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
