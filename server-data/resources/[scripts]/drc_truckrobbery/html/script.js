let hackTime = 10;
let hackingStarted = false;
let hackTimeout;
let blackOverlay;
let progressBar;
let progressBarContainer;
let progressText;
let invitedPlayers = [];
let MAX_TEAM_MEMBERS = 2;
let playersAddedSinceLastShown = false;
let overlay;  // Declare overlay in the outer scope

window.addEventListener('message', (event) => {
    if (event.data.action === 'startMinigame') {
        document.getElementById('miniGame').classList.remove('hidden');
        document.getElementById('miniGame').style.display = 'flex';
        hackTime = event.data.hackTime || 10;

        const timerElement = document.getElementById('timer');
        timerElement.textContent = hackTime;
        startCountdown(hackTime, timerElement);

        // Reset minigame state
        hackingStarted = false;
        resetMinigameElements();

        if (hackTimeout) {
            clearTimeout(hackTimeout);
        }

        hackTimeout = setTimeout(() => {
            if (!hackingStarted) {
                blackOverlay.style.display = 'block';
                progressBarContainer.style.display = 'block';

                progressBar.style.backgroundColor = 'green';
                progressBar.style.width = '0%';

                setTimeout(() => {
                    progressBar.style.width = '50%';

                    setTimeout(() => {
                        progressBar.style.backgroundColor = 'red';
                    }, 2000);
                }, 100);

                setTimeout(() => {
                    const failureMessage = document.getElementById('failureMessage');
                    failureMessage.style.display = 'block';
                    failureMessage.classList.add('pulse');
                    progressText.textContent = 'HACK FAILED';
                    sendFailure();
                }, 2500);
            }
        }, hackTime * 1000);
    }
});

function startCountdown(duration, timerElement) {
    let remainingTime = duration;
    const countdown = setInterval(() => {
        timerElement.textContent = remainingTime;

        if (--remainingTime < 0) {
            clearInterval(countdown);
            timerElement.textContent = '0';
        }
    }, 1000);
}

document.addEventListener('DOMContentLoaded', () => {
    const gameArea = document.getElementById('gameArea');

    overlay = document.createElement('div');  // Initialize overlay here
    overlay.classList.add('overlay');
    gameArea.appendChild(overlay);

    blackOverlay = document.createElement('div');
    blackOverlay.id = 'blackOverlay';
    blackOverlay.classList.add('black-overlay');
    blackOverlay.style.display = 'none';
    gameArea.appendChild(blackOverlay);

    progressBar = document.getElementById('progressBar');
    progressBarContainer = document.getElementById('progressBarContainer');
    progressText = document.getElementById('progressText');

    const truckImage = document.getElementById('truckImage');
    const locations = JSON.parse(truckImage.getAttribute('data-locations'));
    const randomIndex = Math.floor(Math.random() * locations.length);
    const selectedLocation = locations[randomIndex];

    truckImage.style.left = `${selectedLocation.x}px`;
    truckImage.style.top = `${selectedLocation.y}px`;

    const mouseMoveHandler = (e) => {
        if (!hackingStarted) {
            const rect = overlay.getBoundingClientRect();
            const x = e.clientX - rect.left;
            const y = e.clientY - rect.top;
            overlay.style.background = `radial-gradient(circle at ${x}px ${y}px, transparent 50px, black 50px)`;
        }
    };

    gameArea.addEventListener('mousemove', mouseMoveHandler);
    truckImage.addEventListener('mouseenter', () => {
        clearTimeout(hackTimeout);
        hackingStarted = true;
        overlay.style.display = 'none';

        truckImage.classList.add('pulse');

        setTimeout(() => {
            truckImage.classList.remove('pulse');

            setTimeout(() => {
                truckImage.classList.add('pulse');

                setTimeout(() => {
                    truckImage.classList.remove('pulse');

                    blackOverlay.style.display = 'block';
                    progressBarContainer.style.display = 'block';

                    let progress = 0;
                    const interval = 30;
                    const duration = 3000;
                    const increment = 100 / (duration / interval);

                    const fillProgressBar = setInterval(() => {
                        progress += increment;
                        progressBar.style.width = `${progress}%`;

                        if (progress >= 100) {
                            clearInterval(fillProgressBar);
                            setTimeout(() => {
                                document.getElementById('successMessage').style.display = 'block';
                                document.getElementById('successMessage').classList.add('pulse');
                                sendSuccess();
                            }, 3000);
                        }
                    }, interval);

                }, 1000);
            }, 100);
        }, 500);
    });
});

function sendSuccess() {
    fetch(`https://${GetParentResourceName()}/minigameOutcome`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8'
        },
        body: JSON.stringify({
            outcome: 'success'
        })
    });
}

function sendFailure() {
    fetch(`https://${GetParentResourceName()}/minigameOutcome`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8'
        },
        body: JSON.stringify({ outcome: 'failure' })
    });
}



function updatePlayerList(playerNames) {
    const nearestPlayersContainer = document.querySelector('.nearest-players');
    nearestPlayersContainer.innerHTML = '<h2>NEARBY PLAYERS</h2>';

    playerNames.forEach(name => {
        const playerElement = document.createElement('div');
        playerElement.className = 'member';
        playerElement.setAttribute('data-player-name', name);
        playerElement.innerHTML = `
            <i class="fas fa-user"></i>
            <p class="player-name">${name}</p>`;

        const addButton = document.createElement('button');
        addButton.className = 'add-player-btn';
        addButton.innerHTML = '<i class="fas fa-plus-circle green-plus"></i>';
        addButton.onclick = function() { requestToAddPlayer(name); };
        playerElement.appendChild(addButton);

        nearestPlayersContainer.appendChild(playerElement);
    });
}


function removePlayerFromNearby(playerName) {
    const playerElement = document.querySelector(`[data-player-name="${playerName}"]`);
    if (playerElement) {
        playerElement.remove();
    }
}

function addPlayerToTeam(playerName) {
    const teamContainer = document.querySelector('.team');
    const newMember = document.createElement('div');
    newMember.className = 'member';
    newMember.innerHTML = `
        <i class="fas fa-user"></i><p>${playerName}</p>
        <button class="remove-player-btn"><i class="fas fa-minus-circle blue-minus"></i></button>`;
    
    const removeButton = newMember.querySelector('.remove-player-btn');
    removeButton.onclick = function() { removePlayerFromTeam(playerName, newMember); };

    teamContainer.appendChild(newMember);

    removePlayerFromNearby(playerName);
    playersAddedSinceLastShown = true;
}   


function removePlayerFromTeam(playerName, playerElement) {
    playerElement.remove();
    fetch(`https://${GetParentResourceName()}/removeFromTeam`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify({
            playerName: playerName
        })
    });
}
window.addEventListener('keydown', function(event) {
    if (event.key === "Escape") {
        setTeamLeader('');
        resetTeamList();
        resetNearbyPlayersList();
        invitedPlayers = [];

        hideGroupLobby();

        fetch(`https://${GetParentResourceName()}/closeMenu`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify({ action: 'close' })
        });
    }
});

function resetTeamList() {
    const teamContainer = document.querySelector('.team');
    const members = teamContainer.querySelectorAll('.member:not(.team-leader)');

    members.forEach(member => member.remove());
}


function resetNearbyPlayersList() {
    const nearestPlayersContainer = document.querySelector('.nearest-players');
    nearestPlayersContainer.innerHTML = '<h2>NEARBY PLAYERS</h2>';
}



    function showInvitationDialog(invitingPlayerId) {
        document.querySelector('#customAlert p').textContent = `Player ${invitingPlayerId} invited you to the team. Do you accept?`;

        document.getElementById("customAlert").classList.remove("hidden");

        document.getElementById("yesButton").onclick = function() {
            acceptInvitation(invitingPlayerId);
            hideAlert();
        };

        document.getElementById("noButton").onclick = function() {
            hideAlert();
        };
    }

    function acceptInvitation(invitingPlayerId) {
        fetch(`https://${GetParentResourceName()}/acceptInvitation`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify({
                playerServerId: invitingPlayerId
            })
        }).then(() => {
            invitedPlayers = invitedPlayers.filter(name => name !== invitingPlayerId);
        }).catch(()=>{});
        hideAlert();
    }
    
    
    function showAlert() {
        document.getElementById("customAlert").classList.remove("hidden");
    }

    function hideAlert() {
        document.getElementById("customAlert").classList.add("hidden");
    }
    
    
    function setTeamLeader(name) {
        var teamLeaderElement = document.getElementById('teamLeaderName');
        if (teamLeaderElement) {
            teamLeaderElement.textContent = name;
        }
    }
    

    function requestToAddPlayer(playerServerId) {
        const currentTeamSize = document.querySelectorAll('.team .member').length;
    
        if (currentTeamSize >= MAX_TEAM_MEMBERS) {
            fetch(`https://${GetParentResourceName()}/teamFull`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json; charset=UTF-8',
                },
                body: JSON.stringify({ action: 'teamFull' })
            });
            return;
        }
    
        if (!invitedPlayers.includes(playerServerId)) {
            fetch(`https://${GetParentResourceName()}/invitePlayer`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json; charset=UTF-8',
                },
                body: JSON.stringify({
                    playerServerId: playerServerId
                })
            }).catch(()=>{});
            invitedPlayers.push(playerServerId);
        } else {
            fetch(`https://${GetParentResourceName()}/alreadyInvited`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json; charset=UTF-8',
                },
                body: JSON.stringify({ action: 'alreadyInvited' })
            });
        }
    }
    
    

    document.getElementById("yesButton").addEventListener("click", function() {
        document.getElementById("customAlert").classList.add("hidden");
    });

    document.getElementById("noButton").addEventListener("click", function() {
        document.getElementById("customAlert").classList.add("hidden");
        fetch(`https://${GetParentResourceName()}/closeAlert`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify({ action: 'alertClosed' })
        });
    });
    

    function showAlert() {
        document.getElementById("customAlert").classList.remove("hidden");
    }

    function showGroupLobby() {
        const groupLobby = document.querySelector('.flex-container');
        groupLobby.style.display = 'flex';
        groupLobby.style.visibility = 'visible';
        groupLobby.style.opacity = 0;
        groupLobby.style.transition = 'opacity 0.5s ease-out';
    
        void groupLobby.offsetWidth;
    
        if (playersAddedSinceLastShown) {
            setTimeout(() => {
                groupLobby.style.opacity = 1;
            }, 10);
            playersAddedSinceLastShown = false;
        } else {
            groupLobby.style.opacity = 1;
        }
    }
    
    
    
    function hideGroupLobby() {
        const groupLobby = document.querySelector('.flex-container');
        groupLobby.style.opacity = 0;
        groupLobby.style.transition = 'opacity 0.5s ease-out';
        
        setTimeout(() => {
            groupLobby.style.display = 'none';
            groupLobby.style.visibility = 'hidden';
        }, 500);
    }

    function onAddPlayerClick(playerName) {
        addToTeam(playerName);
    }


    document.getElementById("mainMenuButton").addEventListener("click", function() {
        const teamMembers = document.querySelectorAll('.team .member');
        const teamMemberIds = Array.from(teamMembers).map(member => member.getAttribute('data-player-id'));
        const groupLobby = document.querySelector('.flex-container');
        groupLobby.style.display = 'none';
    
        fetch(`https://${GetParentResourceName()}/startJob`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify({ teamMemberIds })
        }).catch(error => {
            
        });
    });



    function startStickybombMinigame() {
        document.body.style.display = 'block';
        document.documentElement.style.display = '';
        document.getElementById("stickybombMinigame").classList.remove("hidden");
    
        document.getElementById('stickybombMinigame').style.position = 'fixed';
        document.getElementById('stickybombMinigame').style.top = '50%';
        document.getElementById('stickybombMinigame').style.left = '50%';
        document.getElementById('stickybombMinigame').style.transform = 'translate(-50%, -50%)';
    }

    document.getElementById("clickableSquare").addEventListener("click", function() {
        this.style.display = 'none';

        var imgButton = document.getElementById("changeableImageButton");
        imgButton.style.display = imgButton.style.display === 'none' ? 'block' : 'none';

        var img = document.getElementById("changeableImage");
        img.style.display = img.style.display === 'none' ? 'block' : 'none';

        var beepSound = document.getElementById("beepSound");
        beepSound.play();
        setTimeout(function() {
            var beepArmedSound = document.getElementById("beepArmedSound");
            beepArmedSound.play();
        }, 1000);

        setTimeout(function() {
            document.getElementById("stickybombMinigame").classList.add("hidden");
            fetch(`https://${GetParentResourceName()}/minigameCompleted`, { method: 'POST' }).catch(() => {})
            resetStickybombMinigameElements()
        }, 2000);
    });
    
    function resetMinigameElements() {
        document.getElementById('successMessage').style.display = 'none';
        document.getElementById('failureMessage').style.display = 'none';
        document.getElementById('failureMessage').classList.remove('pulse');
        document.getElementById('progressBar').style.width = '0%';
        document.getElementById('progressBar').style.backgroundColor = 'green';
        blackOverlay.style.display = 'none';
        progressBarContainer.style.display = 'none';
        overlay.style.display = 'block';
    }
    
    function resetStickybombMinigameElements() {
        document.getElementById('stickybombMinigame').classList.add('hidden');
        document.getElementById("clickableSquare").style.display = 'block';
        document.getElementById("changeableImageButton").style.display = 'none';
        document.getElementById("changeableImage").style.display = 'none';
    }


    
    window.addEventListener('message', function(event) {
        if (event.data.action === "updatePlayers") {
            updatePlayerList(event.data.playerNames);
        }
        if (event.data.action === "showInvitation") {
            showInvitationDialog(event.data.invitingPlayerId);
        }
        if (event.data.action === "updatePlayerLists") {
            removePlayerFromNearby(event.data.acceptedPlayerId);
            addPlayerToTeam(event.data.acceptedPlayerName);
        }
        if (event.data.action === "newTeamMember") {
            addPlayerToTeam(event.data.playerName);
        }
        if (event.data.action === "receiveMaxTeamMembers") {
            MAX_TEAM_MEMBERS = event.data.maxTeamMembers;
        }
        if (event.data.action === 'stopMinigame') {
            clearTimeout(hackTimeout);
            document.getElementById('miniGame').style.display = 'none';
            document.getElementById('miniGame').classList.add('hidden');
            document.getElementById('successMessage').style.display = 'none';
            resetMinigameElements();
        }
        if (event.data.action === "updatePlayers") {
            setTeamLeader(event.data.teamLeader);
            updatePlayerList(event.data.playerNames);
            showGroupLobby();
        }
        if (event.data.action === "startMinigameStickyBomb") {
            startStickybombMinigame();
        }
    });
    