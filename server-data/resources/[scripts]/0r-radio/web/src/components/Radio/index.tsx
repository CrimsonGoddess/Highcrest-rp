import React, { useState, useEffect, KeyboardEvent, useRef } from "react";
import HorizontalRadio from "./horizontal";
import VerticalRadio from "./vertical";
import { fetchNui } from "../../utils/fetchNui";
import { useTheme } from "../../hooks/useTheme";
import { debugData } from "../../utils/debugData";
import { useNuiEvent } from "../../hooks/useNuiEvent";
import MemberList from "../MemberList";
import { isEnvBrowser } from "../../utils/misc";

debugData([
    {
        action: "setRadioVisible",
        data: true,
    },
    {
        action: "setGameTime",
        data: { hour: "12", minute: "00" },
    },
    {
        action: "setPlayersInRadioChannel",
        data: [
            { source: 1, name: "Adez Soydan", isMuted: false },
            { source: 2, name: "Adez Soydan Development", isMuted: false },
            { source: 3, name: "Player 3", isMuted: false },
            { source: 4, name: "Player 4", isMuted: false },
            { source: 5, name: "Player 5", isMuted: false },
            { source: 6, name: "Player 6", isMuted: false },
            { source: 7, name: "Player 7", isMuted: false },
            { source: 8, name: "Player 8", isMuted: false },
            { source: 9, name: "Player 9", isMuted: false },
            { source: 10, name: "Player 10", isMuted: false },
            { source: 11, name: "Player 11", isMuted: false },
            { source: 12, name: "Player 12", isMuted: false },
            { source: 13, name: "Player 13", isMuted: false },
            { source: 14, name: "Player 14", isMuted: false },
            { source: 15, name: "Player 15", isMuted: false },
            { source: 16, name: "Player 16", isMuted: false },
            { source: 17, name: "Player 17", isMuted: false },
            { source: 18, name: "Player 18", isMuted: false },
            { source: 19, name: "Player 19", isMuted: false },
            { source: 20, name: "Player 20", isMuted: false },
        ],
    },
]);

type PlayerOnRadioType = {
    source: number;
    name: string;
    isMuted: boolean;
};

type ChannelsType = {
    channel: number;
    active: boolean;
};

const RadioContainer: React.FC = () => {
    const [inputValue, setInputValue] = useState<string>("");
    const [serverVoiceSystem, setServerVoiceSystem] = useState<string | null>(null);
    const [gameTime, setGameTime] = useState<string>("");
    const [isLoading, setIsLoading] = useState<boolean>(false);
    const [radioVolume, setRadioVolume] = useState<number>(50);
    const [playersInRadio, setPlayersInRadio] = useState<PlayerOnRadioType[] | null>(null);
    const [channels, setChannels] = useState<ChannelsType[] | null>(null);
    const [jammerHud, setJammerHud] = useState<boolean>(false);
    const [radioVisible, setRadioVisible] = useState<boolean>(false);
    const [visibleSoundBar, setVisibleSoundBar] = useState<boolean>(false);
    const [visibleMenu, setVisibleMenu] = useState<boolean>(false);
    const [visibleMembersList, setVisibleMembersList] = useState<boolean>(false);
    const [tab, setTab] = useState<"channels" | "members">("members");
    const [alerts, setAlerts] = useState<{ title: string; message: string; visible: boolean }[]>([]);
    const [onRadio, setOnRadio] = useState<boolean>(false);
    const [horizontal, setHorizontal] = useState<boolean>(false);
    const { theme } = useTheme();

    useEffect(() => {
        if (!radioVisible) return;

        const keyHandler = (e: { code: string }) => {
            if (["Escape"].includes(e.code)) {
                if (!isEnvBrowser()) {
                    fetchNui("hideFrame");

                    if (!onRadio) {
                        setVisibleMembersList(false);
                    }
                } else {
                    setRadioVisible(false);

                    if (!onRadio) {
                        setVisibleMembersList(false);
                    }
                }
            }
        };

        window.addEventListener("keydown", keyHandler);

        return () => window.removeEventListener("keydown", keyHandler);
    }, [radioVisible, onRadio]);

    const showAlert = (title: string, message: string) => {
        setAlerts((prev) => [...prev, { title, message, visible: true }]);
    };

    const handleCloseAlert = (index: number) => {
        setAlerts((prevAlerts) => prevAlerts.map((alert, i) => (i === index ? { ...alert, visible: false } : alert)));
    };

    useNuiEvent<boolean>("setRadioVisible", setRadioVisible);
    useNuiEvent<boolean>("setHorizontal", setHorizontal);
    useNuiEvent<boolean>("setJammerHud", setJammerHud);

    useEffect(() => {
        fetchNui<string>("getServerVoiceSystem").then((data) => {
            setServerVoiceSystem(data);
        });

        // setHorizontal(true);
    }, []);

    useNuiEvent<boolean>("resetRadio", () => {
        setOnRadio(false);
        setRadioVisible(false);
        setPlayersInRadio(null);
    });

    useNuiEvent<{ title: string; message: string }>("showAlert", (value) => {
        showAlert(value.title, value.message);
    });

    useNuiEvent<{ hour: string; minute: string }>("setGameTime", (value) => {
        setGameTime(value.hour + ":" + value.minute);
    });

    useNuiEvent<PlayerOnRadioType[]>("setPlayersInRadioChannel", (data) => {
        setPlayersInRadio(data);
    });

    const addChannel = (channel: number) => {
        deactiveChannels();

        setChannels((prevChannels) => {
            if (!prevChannels) {
                return [{ channel, active: true }];
            }

            const ch = prevChannels.find((ch) => ch.channel === channel);

            if (ch) {
                ch.active = true;

                return prevChannels;
            }

            return [{ channel, active: true }, ...prevChannels];
        });
    };

    const deactiveChannels = () => {
        setChannels((prevChannels) => {
            return prevChannels?.map((channel) => {
                return { ...channel, active: false };
            });
        });
    };

    const setRadioChannel = (channel: number) => {
        if (isLoading) return;
        setIsLoading(true);
        fetchNui("joinRadio", channel, {
            status: true,
            connected: true,
            channel: 24,
        }).then((data) => {
            setIsLoading(false);
            if (data.status) {
                setOnRadio(data.connected);
                setJammerHud(false);

                addChannel(channel);

                showAlert("Radio", `You have connected to channel ${channel}`);
            }
        });
    };

    const leaveChannel = () => {
        if (isLoading) return;
        setIsLoading(true);
        fetchNui(
            "leaveRadio",
            {},
            {
                status: true,
            }
        ).then((data) => {
            setIsLoading(false);
            if (data.status) {
                setOnRadio(false);
                setPlayersInRadio(null);
                deactiveChannels();
            }
        });
    };

    const handleRadioPower = () => {
        if (isLoading) return;
        setIsLoading(true);
        fetchNui("poweredOff").then(() => {
            setIsLoading(false);
            setOnRadio(false);
            setPlayersInRadio(null);
            setVisibleMembersList(false);
            deactiveChannels();
        });
    };

    const handleVolumeSet = (type: "volumeUp" | "volumeDown") => {
        if (isLoading) return;
        setVisibleSoundBar(true);

        if (type === "volumeUp") {
            setRadioVolume((prev) => (prev >= 100 ? 100 : prev + 10));
        } else {
            setRadioVolume((prev) => (prev <= 0 ? 0 : prev - 10));
        }

        setIsLoading(true);
        fetchNui(type).then((data) => {
            setIsLoading(false);
            if (data.status) {
                setRadioVolume(data.newVolume);
            }
        });
    };

    useEffect(() => {
        let timer = 0;

        if (visibleSoundBar) {
            timer = setTimeout(() => {
                setVisibleSoundBar(false);
            }, 3000);
        }

        return () => clearTimeout(timer);
    }, [visibleSoundBar]);

    const handleKeyDown = (event: KeyboardEvent<HTMLInputElement>) => {
        if (event.key === "Enter") {
            const { value } = event.target as HTMLInputElement;
            setRadioChannel(parseInt(value));
        }
    };

    const handleConnect = (e, value = inputValue) => {
        if (value == inputValue && onRadio) return;

        if (value != inputValue) {
            leaveChannel();
            setInputValue(value);
            setVisibleMenu(false);
        }

        if (value) {
            setRadioChannel(parseInt(value));
        }
    };

    const handleMutePlayer = (source: number) => {
        const src = source;
        fetchNui("setMutePlayer", source, {
            status: true,
        }).then(() => {
            setPlayersInRadio((prevPlayers) => {
                return (
                    prevPlayers &&
                    prevPlayers.map((player) => {
                        if (player.source === src) {
                            return { ...player, isMuted: !player.isMuted };
                        }
                        return player;
                    })
                );
            });
        });
    };

    const handleMenu = () => {
        setVisibleMenu((prev) => !prev);
    };

    const handleMemberMenu = () => {
        setVisibleMembersList((prev) => !prev);
    };

    return (
        <>
            <div className="drag-container w-full h-full absolute bottom-0 left-0 right-0 z-[100]">
                <HorizontalRadio inputValue={inputValue} setInputValue={setInputValue} visible={radioVisible && horizontal} radioVolume={radioVolume} playersInRadio={playersInRadio} jammerHud={jammerHud} visibleSoundBar={visibleSoundBar} tab={tab} onRadio={onRadio} channels={channels} setTab={setTab} leaveChannel={leaveChannel} handleRadioPower={handleRadioPower} handleVolumeSet={handleVolumeSet} handleKeyDown={handleKeyDown} handleConnect={handleConnect} handleMutePlayer={handleMutePlayer} handleMemberMenu={handleMemberMenu} setVisibleMembersList={setVisibleMembersList} />
                <VerticalRadio
                    inputValue={inputValue}
                    setInputValue={setInputValue}
                    visible={radioVisible && !horizontal}
                    gameTime={gameTime}
                    radioVolume={radioVolume}
                    playersInRadio={playersInRadio}
                    jammerHud={jammerHud}
                    visibleSoundBar={visibleSoundBar}
                    visibleMenu={visibleMenu}
                    tab={tab}
                    onRadio={onRadio}
                    theme={theme}
                    alerts={alerts}
                    channels={channels}
                    handleCloseAlert={handleCloseAlert}
                    setTab={setTab}
                    leaveChannel={leaveChannel}
                    handleRadioPower={handleRadioPower}
                    handleVolumeSet={handleVolumeSet}
                    handleKeyDown={handleKeyDown}
                    handleConnect={handleConnect}
                    handleMenu={handleMenu}
                    handleMutePlayer={handleMutePlayer}
                    handleMemberMenu={handleMemberMenu}
                    setVisibleMembersList={setVisibleMembersList}
                />
                <MemberList inputValue={inputValue} radioVisible={radioVisible} visible={visibleMembersList} playersInRadio={playersInRadio} onRadio={onRadio} handleMutePlayer={handleMutePlayer} />
            </div>
        </>
    );
};

export default RadioContainer;
