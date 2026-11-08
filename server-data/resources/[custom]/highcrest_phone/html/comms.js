'use strict';

let contacts = [];
let activeCall = null;
let openConversation = null;
let openContact = null;

const displayName = (name, number) => name || number;
const formatTime = (seconds) => new Date(seconds * 1000).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });

function setError(id, text) {
    $(id).textContent = text || '';
}

/* Dialer */

function showDialer() {
    show('dialer');
    setError('dialError', '');
}

async function placeCall(number) {
    if (!number) return;
    show('dialer');
    const result = await post('startCall', number);
    if (!result || result.error) {
        setError('dialError', (result && result.error) || 'The call could not be placed.');
        return;
    }
    activeCall = { number: result.number, name: result.name, state: 'ringing', incoming: false };
    showCall();
}

document.querySelectorAll('[data-digit]').forEach((key) => {
    key.addEventListener('click', () => { $('dialNumber').value += key.dataset.digit; });
});
$('dialClear').addEventListener('click', () => { $('dialNumber').value = $('dialNumber').value.slice(0, -1); });
$('dialCall').addEventListener('click', () => placeCall($('dialNumber').value));

/* Call screen */

function showCall() {
    if (!activeCall) return;
    show('call');
    $('callName').textContent = displayName(activeCall.name, activeCall.number);
    const labels = { ringing: activeCall.incoming ? 'Incoming call' : 'Calling...', active: 'Connected' };
    $('callState').textContent = labels[activeCall.state];
    $('callAnswer').hidden = !(activeCall.incoming && activeCall.state === 'ringing');
    $('callStrip').hidden = true;
}

function updateCallStrip() {
    $('callStrip').hidden = !activeCall || currentView() === 'call';
}

$('callAnswer').addEventListener('click', () => post('answerCall'));
$('callHangUp').addEventListener('click', () => post('hangUp'));
$('callStrip').addEventListener('click', showCall);

/* Contacts */

function renderContacts() {
    $('contactsEmpty').hidden = contacts.length > 0;
    $('contactList').replaceChildren(...contacts.map((contact) => {
        const row = document.createElement('button');
        row.className = 'row';
        const name = document.createElement('strong');
        name.textContent = contact.name;
        const number = document.createElement('span');
        number.className = 'muted';
        number.textContent = contact.number;
        row.append(name, number);
        row.addEventListener('click', () => showContact(contact));
        return row;
    }));
}

function showContacts() {
    renderContacts();
    show('contacts');
}

function showContact(contact, number = '') {
    openContact = contact;
    $('contactName').value = contact ? contact.name : '';
    $('contactNumber').value = contact ? contact.number : number;
    $('contactActions').hidden = !contact;
    setError('contactError', '');
    const remove = $('contactDelete');
    remove.textContent = 'Delete';
    remove.classList.remove('danger');
    remove.dataset.armed = '';
    show('contact');
}

$('contactAdd').addEventListener('click', () => showContact(null));

/* Share number: send yours to someone standing next to you, and save ones you receive. */

let receivedCards = [];

function clearShare() {
    setError('shareError', '');
    $('shareNotice').textContent = '';
    $('shareNearbyBox').hidden = true;
}

function renderReceived() {
    $('receivedBox').hidden = receivedCards.length === 0;
    $('receivedList').replaceChildren(...receivedCards.map((card) => {
        const node = el('article', 'card');
        node.append(el('strong', '', card.name), el('p', 'muted', card.number));
        const actions = el('div', 'card-actions');
        const dismiss = () => {
            receivedCards = receivedCards.filter((other) => other !== card);
            renderReceived();
        };
        actions.append(
            button('Dismiss', 'text-button', dismiss),
            button('Save', 'text-button', async () => {
                const result = await post('saveContact', { name: card.name, number: card.number });
                if (!result || result.error) {
                    setError('shareError', (result && result.error) || 'That contact could not be saved.');
                    return;
                }
                contacts = result.contacts;
                dismiss();
                showContacts();
                $('shareNotice').textContent = `Saved ${card.name}.`;
            }),
        );
        node.append(actions);
        return node;
    }));
}

$('shareNumber').addEventListener('click', async () => {
    clearShare();
    const nearby = await post('shareNearby');
    if (!nearby || nearby.length === 0) {
        setError('shareError', 'Nobody is standing close enough.');
        return;
    }
    $('shareNearbyBox').hidden = false;
    $('shareNearby').replaceChildren(...nearby.map((person, index) => {
        const row = el('button', 'row');
        row.append(el('strong', '', `Person ${index + 1}`), el('span', 'muted', `${person.distance} m away`));
        row.addEventListener('click', async () => {
            const result = await post('shareNumber', person.id);
            clearShare();
            if (!result || result.error) {
                setError('shareError', (result && result.error) || 'Your number could not be shared.');
                return;
            }
            $('shareNotice').textContent = 'Your number was sent.';
        });
        return row;
    }));
});
$('contactSave').addEventListener('click', async () => {
    const result = await post('saveContact', {
        id: openContact && openContact.id,
        name: $('contactName').value,
        number: $('contactNumber').value,
    });
    if (!result || result.error) {
        setError('contactError', (result && result.error) || 'That contact could not be saved.');
        return;
    }
    contacts = result.contacts;
    showContacts();
});
$('contactCall').addEventListener('click', () => placeCall(openContact.number));
$('contactMessage').addEventListener('click', () => showConversation(openContact.number));
$('contactDelete').addEventListener('click', async () => {
    const button = $('contactDelete');
    if (!button.dataset.armed) {
        button.dataset.armed = '1';
        button.textContent = 'Press again to delete';
        button.classList.add('danger');
        return;
    }
    const result = await post('deleteContact', openContact.id);
    if (result) contacts = result.contacts;
    showContacts();
});

/* Messages */

async function showMessages() {
    show('messages');
    setError('newMessageError', '');
    const rows = (await post('listConversations')) || [];
    $('messagesEmpty').hidden = rows.length > 0;
    $('conversationList').replaceChildren(...rows.map((row) => {
        const item = document.createElement('button');
        item.className = 'row';
        const name = document.createElement('strong');
        name.textContent = displayName(row.name, row.other);
        if (row.unread > 0) {
            const badge = document.createElement('b');
            badge.className = 'badge';
            badge.textContent = row.unread;
            name.append(' ', badge);
        }
        const preview = document.createElement('span');
        preview.className = 'muted preview';
        preview.textContent = row.body;
        item.append(name, preview);
        item.addEventListener('click', () => showConversation(row.other));
        return item;
    }));
    setUnread(0, true);
}

function addBubble(message) {
    const bubble = document.createElement('div');
    bubble.className = message.mine ? 'bubble mine' : 'bubble';
    bubble.textContent = message.body;
    const time = document.createElement('small');
    time.textContent = formatTime(message.sentAt);
    bubble.append(time);
    if (message.x !== null && message.x !== undefined) {
        const pin = document.createElement('button');
        pin.className = 'bubble-pin';
        pin.textContent = 'Set waypoint';
        pin.addEventListener('click', () => post('setWaypoint', { x: message.x, y: message.y }));
        bubble.append(pin);
    }
    $('bubbles').append(bubble);
    $('bubbles').scrollTop = $('bubbles').scrollHeight;
}

async function showConversation(number) {
    openConversation = number;
    show('conversation');
    setError('messageError', '');
    $('bubbles').replaceChildren();
    $('conversationName').textContent = number;
    const result = await post('getConversation', number);
    if (!result || openConversation !== number) return;
    $('conversationName').textContent = displayName(result.name, number);
    result.messages.forEach(addBubble);
    $('messageInput').focus();
}

async function sendMessage() {
    const input = $('messageInput');
    const body = input.value.trim();
    if (!body) return;
    const result = await post('sendMessage', { number: openConversation, body });
    if (!result || result.error) {
        setError('messageError', (result && result.error) || 'That message could not be sent.');
        return;
    }
    setError('messageError', '');
    input.value = '';
    addBubble(result.message);
}

$('messageSend').addEventListener('click', sendMessage);
$('messageLocation').addEventListener('click', async () => {
    const result = await post('sendMessage', { number: openConversation, location: true });
    if (!result || result.error) {
        setError('messageError', (result && result.error) || 'Your location could not be sent.');
        return;
    }
    setError('messageError', '');
    addBubble(result.message);
});
$('messageInput').addEventListener('keydown', (event) => {
    if (event.key === 'Enter') sendMessage();
});
$('newMessageGo').addEventListener('click', () => {
    const number = $('newMessageNumber').value.trim();
    if (!number) {
        setError('newMessageError', 'Enter a number first.');
        return;
    }
    $('newMessageNumber').value = '';
    showConversation(number);
});

/* Unread badge on the home screen */

let unread = 0;
function setUnread(count, replace) {
    unread = replace ? count : unread + count;
    $('messagesBadge').textContent = unread;
    $('messagesBadge').hidden = unread < 1;
}

/* Hook into the phone shell */

openers.phone = showDialer;
openers.contacts = showContacts;
openers.messages = showMessages;
backTargets.contact = showContacts;
backTargets.conversation = showMessages;
onViewChange.push(updateCallStrip);

window.addEventListener('message', ({ data }) => {
    switch (data.action) {
        case 'open':
            contacts = data.data.contacts || [];
            setUnread(data.data.unreadMessages || 0, true);
            if (activeCall) showCall();
            break;
        case 'incomingCall':
            activeCall = { number: data.call.number, name: data.call.name, state: 'ringing', incoming: true };
            if (!$('phone').hidden) showCall();
            break;
        case 'callConnected':
            if (activeCall) {
                activeCall.state = 'active';
                if (currentView() === 'call') showCall();
            }
            updateCallStrip();
            break;
        case 'callEnded': {
            const wasOnCallScreen = currentView() === 'call';
            activeCall = null;
            updateCallStrip();
            if (wasOnCallScreen) {
                showDialer();
                setError('dialError', data.reason);
            }
            break;
        }
        case 'message':
            if (currentView() === 'conversation' && openConversation === data.message.from && !$('phone').hidden) {
                addBubble({ ...data.message, mine: 0 });
                post('getConversation', openConversation);
            } else {
                setUnread(1);
                if (currentView() === 'messages' && !$('phone').hidden) showMessages();
                if (!$('phone').hidden) post('notifyMessage', { name: data.message.name || data.message.from, body: data.message.body });
            }
            break;
        case 'numberShared':
            receivedCards = [data.card, ...receivedCards.filter((card) => card.number !== data.card.number)].slice(0, 5);
            renderReceived();
            break;
    }
});
