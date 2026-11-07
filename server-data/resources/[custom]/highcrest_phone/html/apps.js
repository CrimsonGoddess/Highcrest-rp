'use strict';

/* Small helpers. All player text goes through textContent, so it can't inject markup. */

function el(tag, className, text) {
    const node = document.createElement(tag);
    if (className) node.className = className;
    if (text !== undefined) node.textContent = text;
    return node;
}

function button(label, className, onClick) {
    const node = el('button', className, label);
    node.addEventListener('click', onClick);
    return node;
}

function photoElement(photoId) {
    const image = el('img', 'card-image');
    image.alt = '';
    requestPhoto(photoId).then((src) => { if (src) image.src = src; });
    return image;
}

const timeAgo = (seconds) => new Date(seconds * 1000).toLocaleString([], { month: 'short', day: 'numeric', hour: '2-digit', minute: '2-digit' });
const dollars = (value) => `$${Number(value).toLocaleString('en-US')}`;

// There are no confirm dialogs in-game, so the first press arms the button.
function deleteButton(onConfirm) {
    const node = el('button', 'text-button', 'Delete');
    node.addEventListener('click', () => {
        if (node.dataset.armed) {
            onConfirm();
            return;
        }
        node.dataset.armed = '1';
        node.textContent = 'Press again to delete';
    });
    return node;
}

function handleResult(result, errorId, onSuccess) {
    if (!result || result.error) {
        setError(errorId, (result && result.error) || 'That did not work. Try again.');
        return;
    }
    setError(errorId, '');
    onSuccess(result);
}

/* Choosing a gallery photo to attach */

let pickerReturn = null;

function pickPhoto(returnView, onPick) {
    pickerReturn = returnView;
    show('picker');
    $('pickerEmpty').hidden = phone.photos.length > 0;
    $('pickerGrid').replaceChildren(...phone.photos.map((photo) => {
        const tile = el('button', 'photo');
        requestPhoto(photo.id).then((src) => {
            if (src) tile.style.backgroundImage = `url("${src}")`;
        });
        tile.addEventListener('click', () => {
            onPick(photo.id);
            show(returnView);
        });
        return tile;
    }));
}

function attachControl(buttonId, returnView, setValue) {
    $(buttonId).addEventListener('click', () => pickPhoto(returnView, (id) => {
        setValue(id);
        $(buttonId).textContent = 'Photo attached';
    }));
}

backTargets.picker = () => show(pickerReturn);

/* Pulse (Twitter-style) */

let pulsePhoto = null;

function renderPulse(data) {
    show('pulse');
    $('pulseSetup').hidden = Boolean(data.profile);
    $('pulseCompose').hidden = !data.profile;
    $('pulsePosts').replaceChildren(...data.posts.map((post) => {
        const card = el('article', 'card');
        const head = el('div', 'card-head');
        head.append(el('strong', '', post.displayName), el('span', 'muted', `@${post.handle}`));
        card.append(head, el('p', 'card-body', post.body));
        if (post.photoId) card.append(photoElement(post.photoId));

        const actions = el('div', 'card-actions');
        actions.append(
            button(`${Number(post.liked) ? 'Liked' : 'Like'} ${post.likes}`, 'text-button', async () => {
                const result = await post_('feedLike', post.id);
                if (result) renderPulse(result);
            }),
            el('span', 'muted', timeAgo(post.createdAt)),
        );
        if (Number(post.mine)) {
            actions.append(deleteButton(async () => {
                const result = await post_('feedDelete', post.id);
                if (result) renderPulse(result);
            }));
        }
        card.append(actions);
        return card;
    }));
    $('pulseEmpty').hidden = data.posts.length > 0;
}

const post_ = post; // `post` is also a common loop variable in this file.

openers.pulse = async () => {
    show('pulse');
    const data = await post_('feedGet');
    if (data) renderPulse(data);
};

$('pulseSaveProfile').addEventListener('click', async () => {
    const result = await post_('feedSaveProfile', { handle: $('pulseHandle').value, displayName: $('pulseName').value });
    handleResult(result, 'pulseSetupError', renderPulse);
});

$('pulseSend').addEventListener('click', async () => {
    const result = await post_('feedPost', { body: $('pulseBody').value, photoId: pulsePhoto });
    handleResult(result, 'pulseError', (data) => {
        $('pulseBody').value = '';
        pulsePhoto = null;
        $('pulseAttach').textContent = 'Add photo';
        renderPulse(data);
    });
});

attachControl('pulseAttach', 'pulse', (id) => { pulsePhoto = id; });

/* Marketplace */

let marketPhoto = null;

function renderMarket(data) {
    show('market');
    $('marketEmpty').hidden = data.listings.length > 0;
    $('marketList').replaceChildren(...data.listings.map((listing) => {
        const card = el('article', 'card');
        const head = el('div', 'card-head');
        head.append(el('strong', '', listing.title), el('span', 'price', dollars(listing.price)));
        card.append(head);
        if (listing.photoId) card.append(photoElement(listing.photoId));
        if (listing.description) card.append(el('p', 'card-body', listing.description));

        const actions = el('div', 'card-actions');
        if (Number(listing.mine)) {
            actions.append(deleteButton(async () => {
                const result = await post_('marketDelete', listing.id);
                if (result) renderMarket(result);
            }));
        } else {
            actions.append(
                button('Call', 'text-button', () => placeCall(listing.phone)),
                button('Message', 'text-button', () => showConversation(listing.phone)),
            );
        }
        card.append(actions);
        return card;
    }));
}

openers.market = async () => {
    show('market');
    const data = await post_('marketGet');
    if (data) renderMarket(data);
};

$('marketNew').addEventListener('click', () => {
    setError('marketError', '');
    show('marketForm');
});

$('marketSubmit').addEventListener('click', async () => {
    const result = await post_('marketCreate', {
        title: $('marketTitle').value,
        description: $('marketDescription').value,
        price: $('marketPrice').value,
        photoId: marketPhoto,
    });
    handleResult(result, 'marketError', (data) => {
        $('marketTitle').value = '';
        $('marketDescription').value = '';
        $('marketPrice').value = '';
        marketPhoto = null;
        $('marketAttach').textContent = 'Add photo';
        renderMarket(data);
    });
});

attachControl('marketAttach', 'marketForm', (id) => { marketPhoto = id; });
backTargets.marketForm = () => openers.market();

/* Spark (dating) */

let sparkPhoto = null;

function renderSpark(data) {
    if (!data.profile) {
        showSparkForm(null);
        return;
    }
    show('spark');

    const candidate = data.nextProfile;
    const slot = $('sparkCandidate');
    slot.replaceChildren();
    if (candidate) {
        const card = el('article', 'card');
        if (candidate.photoId) card.append(photoElement(candidate.photoId));
        card.append(
            el('h3', 'spark-name', `${candidate.name}, ${candidate.age}`),
            el('p', 'card-body', candidate.bio),
        );
        const actions = el('div', 'spark-actions');
        const swipe = (liked) => async () => {
            const result = await post_('datingSwipe', { id: candidate.id, liked });
            if (result) renderSpark(result);
        };
        actions.append(button('Pass', 'button', swipe(false)), button('Like', 'button accent', swipe(true)));
        card.append(actions);
        slot.append(card);
    } else {
        slot.append(el('p', 'empty', 'No one new right now. Check back later.'));
    }

    $('sparkMatchesEmpty').hidden = data.matches.length > 0;
    $('sparkMatches').replaceChildren(...data.matches.map((match) => {
        const card = el('article', 'card');
        card.append(el('strong', '', match.name));
        const actions = el('div', 'card-actions');
        actions.append(
            button('Call', 'text-button', () => placeCall(match.phone)),
            button('Message', 'text-button', () => showConversation(match.phone)),
        );
        card.append(actions);
        return card;
    }));

    $('sparkEdit').onclick = () => showSparkForm(data.profile);
}

function showSparkForm(profile) {
    show('sparkForm');
    setError('sparkError', '');
    $('sparkName').value = profile ? profile.name : '';
    $('sparkAge').value = profile ? profile.age : '';
    $('sparkBio').value = profile ? profile.bio : '';
    sparkPhoto = profile ? profile.photoId : null;
    $('sparkAttach').textContent = sparkPhoto ? 'Change photo' : 'Add photo';
    $('sparkRemove').hidden = !profile;
    $('sparkRemove').textContent = 'Delete my profile';
    $('sparkRemove').dataset.armed = '';
}

openers.spark = async () => {
    show('spark');
    const data = await post_('datingGet');
    if (data) renderSpark(data);
};

$('sparkSave').addEventListener('click', async () => {
    const result = await post_('datingSave', {
        name: $('sparkName').value,
        age: $('sparkAge').value,
        bio: $('sparkBio').value,
        photoId: sparkPhoto,
    });
    handleResult(result, 'sparkError', renderSpark);
});

$('sparkRemove').addEventListener('click', async () => {
    const node = $('sparkRemove');
    if (!node.dataset.armed) {
        node.dataset.armed = '1';
        node.textContent = 'Press again to delete';
        return;
    }
    await post_('datingDelete');
    show('home');
});

attachControl('sparkAttach', 'sparkForm', (id) => { sparkPhoto = id; });

/* Darkweb */

function renderDarkweb(data) {
    show('darkweb');
    $('darkwebAlias').textContent = data.alias ? `You are ${data.alias}` : '';
    $('darkwebEmpty').hidden = data.posts.length > 0;
    $('darkwebPosts').replaceChildren(...data.posts.map((entry) => {
        const card = el('article', 'card dark-card');
        const head = el('div', 'card-head');
        head.append(el('strong', '', entry.alias), el('span', 'muted', timeAgo(entry.createdAt)));
        card.append(head, el('p', 'card-body', entry.body));
        if (Number(entry.mine)) {
            const actions = el('div', 'card-actions');
            actions.append(deleteButton(async () => {
                const result = await post_('darkwebDelete', entry.id);
                if (result) renderDarkweb(result);
            }));
            card.append(actions);
        }
        return card;
    }));
}

openers.darkweb = async () => {
    show('darkweb');
    const data = await post_('darkwebGet');
    if (data) renderDarkweb(data);
};

$('darkwebSend').addEventListener('click', async () => {
    const result = await post_('darkwebPost', { body: $('darkwebBody').value });
    handleResult(result, 'darkwebError', (data) => {
        $('darkwebBody').value = '';
        renderDarkweb(data);
    });
});

/* Icons on the home screen are wired up in app.js, so this file loads before that runs. */
wireAppButtons();
