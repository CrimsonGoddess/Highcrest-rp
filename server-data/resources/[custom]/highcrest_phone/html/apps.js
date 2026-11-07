'use strict';

const post_ = post; // Named separately because `post` reads naturally as a loop variable.

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

/* Pulse (social media) */

let pulseState = { tab: 'all', profile: null, photo: null };
let pulseViewing = null;
let pulseThread = null;
let pulseDraft = {};

function avatarElement(photoId, name, size = '') {
    const avatar = el('div', `avatar ${size}`, (name || '?').charAt(0).toUpperCase());
    if (photoId) {
        requestPhoto(photoId).then((src) => {
            if (!src) return;
            avatar.textContent = '';
            avatar.style.backgroundImage = `url("${src}")`;
        });
    }
    return avatar;
}

function authorElement(item) {
    const author = el('button', 'author');
    const names = el('span', 'author-names');
    names.append(el('strong', '', item.displayName), el('span', 'muted', `@${item.handle} · ${timeAgo(item.createdAt)}`));
    author.append(avatarElement(item.avatarId, item.displayName), names);
    author.addEventListener('click', () => showPulseProfile(item.handle));
    return author;
}

function postCard(item, refresh) {
    const card = el('article', 'post');
    card.append(authorElement(item), el('p', 'card-body', item.body));
    if (item.photoId) card.append(photoElement(item.photoId));

    const actions = el('div', 'post-actions');
    const like = button(`${Number(item.liked) ? '♥' : '♡'} ${item.likes}`, Number(item.liked) ? 'action liked' : 'action', async () => {
        await post_('feedLike', item.id);
        refresh();
    });
    actions.append(button(`💬 ${item.comments}`, 'action', () => showPulseThread(item, refresh)), like);
    if (Number(item.mine)) {
        actions.append(deleteButton(async () => {
            await post_('feedDelete', item.id);
            refresh();
        }));
    }
    card.append(actions);
    return card;
}

function renderPulse(data) {
    pulseState.tab = data.tab || pulseState.tab;
    pulseState.profile = data.profile || null;
    show('pulse');
    document.querySelectorAll('[data-pulse-tab]').forEach((tab) => {
        tab.classList.toggle('active', tab.dataset.pulseTab === pulseState.tab);
    });
    $('pulseMe').replaceChildren(avatarElement(data.profile && data.profile.avatarId, data.profile && data.profile.displayName, 'small'));
    $('pulseEmpty').hidden = data.posts.length > 0;
    $('pulsePosts').replaceChildren(...data.posts.map((item) => postCard(item, loadPulseFeed)));
}

async function loadPulseFeed() {
    const data = await post_('feedGet', { tab: pulseState.tab });
    if (!data) return;
    if (!data.profile) {
        showPulseEdit(null);
        return;
    }
    renderPulse(data);
}

openers.pulse = loadPulseFeed;

document.querySelectorAll('[data-pulse-tab]').forEach((tab) => {
    tab.addEventListener('click', () => {
        pulseState.tab = tab.dataset.pulseTab;
        loadPulseFeed();
    });
});

$('pulseMe').addEventListener('click', () => {
    if (pulseState.profile) showPulseProfile(pulseState.profile.handle);
});

$('pulseSend').addEventListener('click', async () => {
    const result = await post_('feedPost', { body: $('pulseBody').value, photoId: pulseState.photo, tab: pulseState.tab });
    handleResult(result, 'pulseError', (data) => {
        $('pulseBody').value = '';
        pulseState.photo = null;
        $('pulseAttach').textContent = 'Add photo';
        renderPulse(data);
    });
});

attachControl('pulseAttach', 'pulse', (id) => { pulseState.photo = id; });

/* Profile page */

function renderPulseProfile(profile) {
    pulseViewing = profile;
    show('pulseProfile');

    const banner = $('profileBanner');
    banner.style.backgroundImage = '';
    if (profile.bannerId) {
        requestPhoto(profile.bannerId).then((src) => {
            if (src) banner.style.backgroundImage = `url("${src}")`;
        });
    }
    $('profileAvatar').replaceChildren(avatarElement(profile.avatarId, profile.displayName, 'large'));
    $('profileName').textContent = profile.displayName;
    $('profileHandle').textContent = `@${profile.handle}`;
    $('profileBio').textContent = profile.bio || '';
    $('profilePosts').textContent = profile.postCount;
    $('profileFollowers').textContent = profile.followers;
    $('profileFollowing').textContent = profile.following;

    const action = $('profileAction');
    action.textContent = profile.isMine ? 'Edit profile' : (profile.isFollowing ? 'Following' : 'Follow');
    action.classList.toggle('accent', !profile.isMine && !profile.isFollowing);

    $('profileFeedEmpty').hidden = profile.posts.length > 0;
    $('profileFeed').replaceChildren(...profile.posts.map((item) => postCard(item, () => showPulseProfile(profile.handle))));
}

async function showPulseProfile(handle) {
    const profile = await post_('feedProfile', handle);
    if (profile) renderPulseProfile(profile);
}

$('profileAction').addEventListener('click', async () => {
    if (pulseViewing.isMine) {
        showPulseEdit(pulseViewing);
        return;
    }
    const profile = await post_('feedFollow', pulseViewing.handle);
    if (profile) renderPulseProfile(profile);
});

backTargets.pulseProfile = () => loadPulseFeed();

/* Editing a profile */

function showPulseEdit(profile) {
    pulseDraft = profile
        ? { avatarId: profile.avatarId, bannerId: profile.bannerId }
        : { avatarId: null, bannerId: null };
    $('editHandle').value = profile ? profile.handle : '';
    $('editName').value = profile ? profile.displayName : '';
    $('editBio').value = profile ? profile.bio : '';
    $('editAvatar').textContent = pulseDraft.avatarId ? 'Change profile picture' : 'Add profile picture';
    $('editBanner').textContent = pulseDraft.bannerId ? 'Change banner' : 'Add banner';
    $('pulseEditTitle').textContent = profile ? 'Edit profile' : 'Create your profile';
    setError('editError', '');
    show('pulseEdit');
}

attachControl('editAvatar', 'pulseEdit', (id) => { pulseDraft.avatarId = id; });
attachControl('editBanner', 'pulseEdit', (id) => { pulseDraft.bannerId = id; });

$('editSave').addEventListener('click', async () => {
    const result = await post_('feedSaveProfile', {
        handle: $('editHandle').value,
        displayName: $('editName').value,
        bio: $('editBio').value,
        avatarId: pulseDraft.avatarId,
        bannerId: pulseDraft.bannerId,
    });
    handleResult(result, 'editError', renderPulseProfile);
});

backTargets.pulseEdit = () => {
    if (pulseViewing) showPulseProfile(pulseViewing.handle);
    else show('home');
};

/* Comments */

function renderThread(comments) {
    const { item } = pulseThread;
    $('threadEmpty').hidden = comments.length > 0;
    $('threadComments').replaceChildren(...comments.map((comment) => {
        const row = el('article', 'post');
        row.append(authorElement(comment), el('p', 'card-body', comment.body));
        if (Number(comment.mine)) {
            const actions = el('div', 'post-actions');
            actions.append(deleteButton(async () => {
                const result = await post_('feedDeleteComment', { id: comment.id, postId: item.id });
                if (result) renderThread(result.comments);
            }));
            row.append(actions);
        }
        return row;
    }));
}

async function showPulseThread(item, refresh) {
    pulseThread = { item, refresh };
    show('pulseThread');
    setError('threadError', '');
    $('threadBody').value = '';
    const original = el('article', 'post');
    original.append(authorElement(item), el('p', 'card-body', item.body));
    if (item.photoId) original.append(photoElement(item.photoId));
    $('threadPost').replaceChildren(original);
    $('threadComments').replaceChildren();
    const result = await post_('feedComments', item.id);
    if (result) renderThread(result.comments);
}

$('threadSend').addEventListener('click', async () => {
    const result = await post_('feedComment', { postId: pulseThread.item.id, body: $('threadBody').value });
    handleResult(result, 'threadError', (data) => {
        $('threadBody').value = '';
        renderThread(data.comments);
    });
});

backTargets.pulseThread = () => pulseThread.refresh();

/* Browser preview only */

if (PREVIEW === 'pulse' || PREVIEW === 'pulseProfile') {
    const sample = [
        { id: 1, body: 'Just landed at the Vanilla Unicorn. Who is out tonight?', handle: 'crim', displayName: 'Crim Johnson', createdAt: 1793000000, likes: 12, comments: 3, liked: 1, mine: 1 },
        { id: 2, body: 'Car meet at the docks, midnight. Bring something loud.', handle: 'nightshift', displayName: 'Night Shift', createdAt: 1792990000, likes: 41, comments: 9, liked: 0, mine: 0 },
    ];
    if (PREVIEW === 'pulse') {
        renderPulse({ tab: 'all', profile: { handle: 'crim', displayName: 'Crim Johnson' }, posts: sample });
    } else {
        renderPulseProfile({ handle: 'crim', displayName: 'Crim Johnson', bio: 'Everybody wants the top.', isMine: false, isFollowing: false, postCount: 24, followers: 318, following: 77, posts: sample });
    }
}

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
        const card = el('article', 'card spark-card');
        const picture = el('div', 'spark-photo');
        if (candidate.photoId) {
            requestPhoto(candidate.photoId).then((src) => {
                if (src) picture.style.backgroundImage = `url("${src}")`;
            });
        }
        picture.append(el('h3', 'spark-name', `${candidate.name}, ${candidate.age}`));
        card.append(picture, el('p', 'card-body', candidate.bio));
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
        const card = el('article', 'card match-card');
        card.append(avatarElement(match.photoId, match.name), el('strong', '', match.name));
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


