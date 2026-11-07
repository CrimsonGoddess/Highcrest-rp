'use strict';

/* Empire. The phone only shows what the highcrest_empire server sends and asks it to act. */

const empire = (op, args) => post_('empire', { op, args });
let empireBusiness = null;
let empireMemberRank = null;

function empireError(id, result) {
    setError(id, (result && result.error) || 'That did not work. Try again.');
}

const LEDGER_LABELS = {
    deposit: 'Deposit',
    withdraw: 'Withdrawal',
    pay: 'Wage',
    revenue: 'Revenue',
    purchase: 'Ownership',
    staff: 'Staff',
};

/* Overview: my businesses, offers and the market */

function renderEmpire(data) {
    show('empire');
    setError('empireError', '');

    $('empireOffersBox').hidden = data.offers.length === 0;
    $('empireOffers').replaceChildren(...data.offers.map((offer) => {
        const card = el('article', 'card');
        card.append(el('strong', '', offer.businessName), el('p', 'muted', `Job offer: ${offer.rankName}`));
        const respond = (accept) => async () => {
            const result = await empire('respondOffer', { id: offer.id, accept });
            if (!result || result.error) {
                empireError('empireError', result);
                openers.empire();
                return;
            }
            renderEmpire(result);
        };
        const actions = el('div', 'spark-actions');
        actions.append(button('Decline', 'button', respond(false)), button('Accept', 'button accent', respond(true)));
        card.append(actions);
        return card;
    }));

    $('empireMineEmpty').hidden = data.mine.length > 0;
    $('empireMine').replaceChildren(...data.mine.map((business) => {
        const row = el('button', 'row');
        row.append(el('strong', '', business.name), el('span', 'muted', `${business.typeLabel} | ${business.rankName}`));
        row.addEventListener('click', () => showEmpireBusiness(business.id));
        return row;
    }));

    $('empireMarketEmpty').hidden = data.market.length > 0;
    $('empireMarket').replaceChildren(...data.market.map((business) => {
        const card = el('article', 'card');
        const head = el('div', 'card-head');
        head.append(el('strong', '', business.name), el('span', 'price', dollars(business.price)));
        const actions = el('div', 'card-actions');
        actions.append(
            button('Waypoint', 'text-button', () => setWaypoint(business)),
            confirmButton('Buy', 'Press again to buy', async () => {
                const result = await empire('buy', business.id);
                if (!result || result.error) {
                    empireError('empireError', result);
                    return;
                }
                renderEmpire(result);
            }),
        );
        card.append(head, el('p', 'muted', business.typeLabel), actions);
        return card;
    }));
}

// There are no confirm dialogs in-game, so the first press arms the button.
function confirmButton(label, armedLabel, onConfirm) {
    const node = el('button', 'text-button', label);
    node.addEventListener('click', () => {
        if (node.dataset.armed) {
            onConfirm();
            return;
        }
        node.dataset.armed = '1';
        node.textContent = armedLabel;
    });
    return node;
}

openers.empire = async () => {
    show('empire');
    const data = await empire('overview');
    if (data && !data.error) renderEmpire(data);
};

/* A business */

function renderEmpireBusiness(business) {
    empireBusiness = business;
    show('empireBusiness');
    setError('bizError', '');
    $('bizNotice').textContent = business.notice || '';

    $('bizName').textContent = business.name;
    $('bizMeta').textContent = `${business.typeLabel} | Your rank: ${business.rankName}`;

    const can = business.can;
    const handlesMoney = business.balance !== undefined && business.balance !== null;
    $('bizMoney').hidden = !handlesMoney;
    if (handlesMoney) $('bizBalance').textContent = dollars(business.balance);
    $('bizDeposit').hidden = !can.deposit;
    $('bizWithdraw').hidden = !can.withdraw;
    $('bizAmountRow').hidden = !(can.deposit || can.withdraw);

    $('bizHireRow').hidden = !can.hire;

    $('bizStaff').replaceChildren(...business.staff.map((member) => staffCard(member, business)));

    $('bizLedgerBox').hidden = !can.ledger;
    if (can.ledger) {
        const entries = business.ledger || [];
        $('bizLedgerEmpty').hidden = entries.length > 0;
        $('bizLedger').replaceChildren(...entries.map((entry) => {
            const row = el('div', 'ledger-row');
            const top = el('div', 'card-head');
            const money = Number(entry.amount) > 0 ? ` ${dollars(entry.amount)}` : '';
            top.append(el('strong', '', `${LEDGER_LABELS[entry.type] || entry.type}${money}`), el('span', 'muted', timeAgo(entry.createdAt)));
            row.append(top, el('p', 'muted', entry.note ? `${entry.actor}: ${entry.note}` : entry.actor));
            return row;
        }));
    }

    $('bizRanksButton').hidden = !business.isOwner;
    $('bizLeave').hidden = business.isOwner;
    $('bizSell').hidden = !business.isOwner;
    if (business.isOwner) {
        $('bizSell').textContent = `Sell for ${dollars(business.sellPrice)}`;
        $('bizSell').dataset.armed = '';
    }
    $('bizLeave').textContent = 'Leave this job';
    $('bizLeave').dataset.armed = '';
}

function staffCard(member, business) {
    const can = business.can;
    const card = el('article', 'card');
    const head = el('div', 'card-head');
    head.append(el('strong', '', member.name), el('span', 'muted', member.rankName));
    card.append(head);

    const actions = el('div', 'card-actions');
    if (can.pay) {
        actions.append(button('Pay', 'text-button', async () => {
            const amount = $('bizAmount').value;
            if (!amount) {
                setError('bizError', 'Enter an amount at the top first.');
                return;
            }
            const result = await empire('pay', { id: business.id, memberId: member.id, amount });
            handleBusinessResult(result);
        }));
    }
    if (member.manageable && can.promote) {
        business.ranks.filter((rank) => rank.id !== member.rankId && !rank.isOwnerRank).forEach((rank) => {
            actions.append(button(`Make ${rank.name}`, 'text-button', async () => {
                const result = await empire('setRank', { id: business.id, memberId: member.id, rankId: rank.id });
                handleBusinessResult(result);
            }));
        });
    }
    if (member.manageable && can.fire) {
        actions.append(confirmButton('Fire', 'Press again to fire', async () => {
            const result = await empire('fire', { id: business.id, memberId: member.id });
            handleBusinessResult(result);
        }));
    }
    if (actions.childElementCount) card.append(actions);
    return card;
}

function handleBusinessResult(result) {
    if (!result || result.error) {
        empireError('bizError', result);
        return false;
    }
    renderEmpireBusiness(result);
    return true;
}

async function showEmpireBusiness(id) {
    const result = await empire('business', id);
    if (!result || result.error) {
        empireError('empireError', result);
        return;
    }
    renderEmpireBusiness(result);
}

function moveMoney(op) {
    return async () => {
        const amount = $('bizAmount').value;
        const result = await empire(op, { id: empireBusiness.id, amount });
        if (handleBusinessResult(result)) $('bizAmount').value = '';
    };
}

$('bizDeposit').addEventListener('click', moveMoney('deposit'));
$('bizWithdraw').addEventListener('click', moveMoney('withdraw'));
$('bizWaypoint').addEventListener('click', () => setWaypoint(empireBusiness));

$('bizHire').addEventListener('click', async () => {
    const result = await empire('hire', { id: empireBusiness.id, number: $('bizHireNumber').value });
    if (handleBusinessResult(result)) $('bizHireNumber').value = '';
});

$('bizSell').addEventListener('click', async () => {
    const node = $('bizSell');
    if (!node.dataset.armed) {
        node.dataset.armed = '1';
        node.textContent = 'Press again to sell. Staff will be let go.';
        return;
    }
    const result = await empire('sell', empireBusiness.id);
    if (!result || result.error) {
        empireError('bizError', result);
        return;
    }
    renderEmpire(result);
});

$('bizLeave').addEventListener('click', async () => {
    const node = $('bizLeave');
    if (!node.dataset.armed) {
        node.dataset.armed = '1';
        node.textContent = 'Press again to leave';
        return;
    }
    const result = await empire('leave', empireBusiness.id);
    if (!result || result.error) {
        empireError('bizError', result);
        return;
    }
    renderEmpire(result);
});

backTargets.empireBusiness = () => openers.empire();

/* Ranks and permissions (owner only) */

function renderEmpireRanks() {
    show('empireRanks');
    setError('ranksError', '');
    $('ranksList').replaceChildren(...empireBusiness.ranks.map((rank) => {
        const card = el('article', 'card');
        const name = el('input', 'field');
        name.maxLength = 30;
        name.value = rank.name;
        card.append(name);

        const chosen = new Set(rank.permissions);
        if (rank.isOwnerRank) {
            card.append(el('p', 'muted', 'Owners can always do everything.'));
        } else {
            const grid = el('div', 'perm-grid');
            empireBusiness.permissionList.forEach((permission) => {
                const toggle = el('button', chosen.has(permission.id) ? 'perm on' : 'perm', permission.label);
                toggle.addEventListener('click', () => {
                    if (chosen.has(permission.id)) chosen.delete(permission.id);
                    else chosen.add(permission.id);
                    toggle.classList.toggle('on', chosen.has(permission.id));
                });
                grid.append(toggle);
            });
            card.append(grid);
        }

        card.append(button('Save rank', 'button accent', async () => {
            const result = await empire('saveRank', {
                id: empireBusiness.id,
                rankId: rank.id,
                name: name.value,
                permissions: [...chosen],
            });
            if (!result || result.error) {
                empireError('ranksError', result);
                return;
            }
            empireBusiness = result;
            renderEmpireRanks();
            setError('ranksError', '');
            $('ranksSaved').textContent = `${name.value} saved.`;
        }));
        return card;
    }));
}

$('bizRanksButton').addEventListener('click', () => {
    $('ranksSaved').textContent = '';
    renderEmpireRanks();
});

backTargets.empireRanks = () => renderEmpireBusiness(empireBusiness);

/* Browser preview only */
if (PREVIEW === 'empire') {
    renderEmpire({
        offers: [{ id: 1, businessName: 'Vanilla Lounge', rankName: 'Employee' }],
        mine: [{ id: 2, name: 'Crimson Room', typeLabel: 'Nightclub', rankName: 'Owner' }],
        market: [{ id: 3, name: 'Legion Auto', typeLabel: 'Mechanic', price: 250000, x: 0, y: 0 }],
    });
}
const PREVIEW_BUSINESS = {
    id: 2,
    name: 'Crimson Room',
    typeLabel: 'Nightclub',
    rankName: 'Owner',
    isOwner: true,
    sellPrice: 500000,
    balance: 182500,
    can: { hire: true, fire: true, promote: true, deposit: true, withdraw: true, pay: true, ledger: true },
    staff: [
        { id: 1, name: 'Crim Johnson', rankId: 1, rankName: 'Owner', level: 100, manageable: false },
        { id: 2, name: 'Night Shift', rankId: 2, rankName: 'Manager', level: 50, manageable: true },
    ],
    ranks: [
        { id: 1, name: 'Owner', level: 100, permissions: [], isOwnerRank: true },
        { id: 2, name: 'Manager', level: 50, permissions: ['hire', 'deposit'], isOwnerRank: false },
        { id: 3, name: 'Employee', level: 10, permissions: [], isOwnerRank: false },
    ],
    permissionList: [
        { id: 'hire', label: 'Hire staff' }, { id: 'fire', label: 'Fire staff' }, { id: 'promote', label: 'Change ranks' },
        { id: 'deposit', label: 'Deposit money' }, { id: 'withdraw', label: 'Withdraw money' }, { id: 'pay', label: 'Pay staff' }, { id: 'ledger', label: 'See transactions' },
    ],
    ledger: [{ type: 'deposit', amount: 5000, actor: 'Crim Johnson', note: '', createdAt: 1793000000 }],
    x: 0,
    y: 0,
};
if (PREVIEW === 'empireBusiness') renderEmpireBusiness(PREVIEW_BUSINESS);
if (PREVIEW === 'empireRanks') {
    empireBusiness = PREVIEW_BUSINESS;
    renderEmpireRanks();
}
