import "./index.css";
import React, { Fragment, useEffect, useRef, useState } from "react";
import { Transition } from "@headlessui/react";
import { isEnvBrowser } from "../../utils/misc";
import radioSrcTheme1 from "../../assets/images/_radio-horizontal.png";
import bg from "../../assets/images/bg-1.png";
import bgArrow from "../../assets/images/bg-arrow.svg";
import bgArrowBig from "../../assets/images/bg-arrow-big.svg";
import bgArrowLeftButton from "../../assets/images/bg-arrow-left-button.svg";
import bgArrowRightButton from "../../assets/images/bg-arrow-right-button.svg";
import plus from "../../assets/images/plus.svg";
import minus from "../../assets/images/minus.svg";
import BootAnimation from "../BootAnimation";
import Button from "../Button";
import JammerHud from "../JammerHud";
import { debugData } from "../../utils/debugData";
import Draggable, { DraggableData } from "react-draggable";
import { fetchNui } from "../../utils/fetchNui";

type PlayerOnRadioType = {
    source: number;
    name: string;
    isMuted: boolean;
};

type ChannelsType = {
    channel: number;
    active: boolean;
};

const HorizontalRadio: React.FC = ({ inputValue, setInputValue, visible, radioVolume, playersInRadio, jammerHud, visibleSoundBar, tab, onRadio, channels, setTab, leaveChannel, handleRadioPower, handleVolumeSet, handleKeyDown, handleConnect, handleMutePlayer, handleMemberMenu }) => {
    const inputRef = useRef<HTMLInputElement>(null);
    const nodeRef = useRef(null);
    const [dragPosition, setDragPosition] = useState({ x: 0, y: 0 });

    useEffect(() => {
        const position = localStorage.getItem("horizontalRadioPosition");
        if (position) {
            setDragPosition(JSON.parse(position));
        }
    }, []);

    const handleResetPosition = () => {
        setDragPosition({ x: 0, y: 0 });
        localStorage.removeItem("horizontalRadioPosition");
    };

    const handleDragStop = (data: DraggableData) => {
        localStorage.setItem("horizontalRadioPosition", JSON.stringify({ x: data.x, y: data.y }));
    };

    useEffect(() => {
        const handleFocus = () => {
            fetchNui("setKeepInput", { keepInput: false });
        };

        const handleBlur = () => {
            fetchNui("setKeepInput", { keepInput: true });
        };

        if (inputRef.current) {
            inputRef.current.addEventListener('focus', handleFocus);
            inputRef.current.addEventListener('blur', handleBlur);
        }

        // Cleanup on unmount
        return () => {
            if (inputRef.current) {
                inputRef.current.removeEventListener('focus', handleFocus);
                inputRef.current.removeEventListener('blur', handleBlur);
            }
        };
    }, [inputRef.current]);

    return (
        <>
            <Draggable nodeRef={nodeRef} bounds=".drag-container" scale={1} handle=".handle" position={dragPosition} onDrag={(e, data) => setDragPosition({ x: data.x, y: data.y })} onStop={(e, data) => handleDragStop(data)} disabled={!visible}>
                <Transition unmount={false} show={visible} as={Fragment} enter="transition-all duration-300 ease-out" enterFrom="bottom-[-70%] opacity-0" enterTo="bottom-[5vh] opacity-1" leave="transition-all duration-300 ease-in" leaveFrom="bottom-[5vh] opacity-1" leaveTo="bottom-[-70%] opacity-0">
                    <div ref={nodeRef} className="radio absolute bottom-[5vh] right-[5vh] mx-auto px-3 z-[100]">
                        <img className="w-[58vh]" src={radioSrcTheme1} alt="Radio" />

                        <div className="bottom-[2.2vh] right-[11.8vh] rounded-xl w-[35.7vh] h-[20.5vh] absolute flex flex-col justify-between">
                            {jammerHud && onRadio && <JammerHud />}

                            <img className="absolute top-0 left-0 w-full h-full z-0" src={bg} alt="Background" />

                            {!isEnvBrowser() && <BootAnimation />}
                            <div className="w-full h-full z-10">
                                <div className="flex justify-between w-full h-full absolute top-0 left-0 px-[10px] py-[8px]">
                                    <div className="flex-1 flex flex-col justify-between w-[58%] mr-[5px]">
                                        <div className="shrink-0 flex items-center justify-between mb-[8px] smdesktop:mb-[5px]">
                                            <button className={`flex-1 mr-[6px] smdesktop:mr-[2px] relative custom-gradient-button box-border border-r-2 rounded-l-[4px] ${tab === "channels" ? `custom-gradient-button-active text-primary border-primary` : "text-[#4D4D4F] border-[#4D4D4F]"}`} onClick={() => setTab("channels")}>
                                                <img src={bgArrowLeftButton} className="absolute top-0 left-0 h-full z-[-1]" />

                                                <div className="flex items-center justify-center p-[8px] text-[0.8vh]">
                                                    <svg className="mr-[5px] smdesktop:w-[10px] smdesktop:h-[8px]" width="14" height="12" viewBox="0 0 18 16" fill="none" xmlns="http://www.w3.org/2000/svg">
                                                        <path
                                                            d="M16.9516 13.6058L16.1595 12.2375C16.0089 11.9776 15.9561 11.6554 16.0155 11.3325C16.5802 8.59295 14.2554 5.84673 11.4912 5.89103C9.09995 5.84325 6.9409 7.8603 6.85768 10.2495C6.65423 12.8406 8.90016 15.1778 11.4666 15.1372C12.3709 15.135 13.2628 14.8708 14.0093 14.3734C14.2852 14.1953 14.5979 14.1135 14.8984 14.1511L16.4702 14.3394C16.8561 14.3966 17.1565 13.9412 16.9524 13.6067L16.9516 13.6058ZM10.7369 12.9731C10.6217 13.2084 10.3358 13.2996 10.1077 13.1888C9.04923 12.6719 8.38895 11.617 8.38895 10.4333C8.38968 9.27711 9.04126 8.19551 10.1077 7.67784C10.3082 7.58083 10.5428 7.6373 10.6775 7.8031C10.8969 8.05577 10.7564 8.44238 10.4581 8.55749C8.93556 9.30684 8.97827 11.6446 10.5211 12.3426C10.7528 12.4555 10.8498 12.7371 10.7369 12.9717L10.7369 12.9731ZM11.4507 11.8675C9.55818 11.7995 9.55596 9.06923 11.4507 9.00269C13.3497 9.07147 13.3462 11.798 11.4507 11.8675ZM12.7908 13.1888C12.2319 13.448 11.8308 12.6227 12.384 12.3432C13.1195 11.9863 13.5771 11.2536 13.5771 10.4332C13.5771 9.61584 13.1203 8.88316 12.3811 8.52328C12.1494 8.40745 12.0524 8.12582 12.1653 7.89414C12.2811 7.66246 12.5628 7.56545 12.7945 7.67838C15.0758 8.75641 15.0764 12.1179 12.7916 13.1886L12.7908 13.1888Z"
                                                            fill="currentColor"
                                                        />
                                                        <path
                                                            d="M10.7572 5.31475C11.0091 5.28218 11.2553 5.26842 11.5058 5.26769C11.4681 4.37501 11.1894 3.50477 10.6884 2.74388C7.65264 -1.74048 0.70007 1.04902 1.59565 6.37975C1.65791 6.73016 1.60216 7.08131 1.43926 7.36294L0.58133 8.84712C0.358344 9.20189 0.68631 9.70144 1.10116 9.62977L2.80111 9.42632C3.1269 9.38867 3.46791 9.47338 3.76546 9.67031C4.42936 10.1083 5.17436 10.3776 5.97938 10.4653C6.206 10.5036 6.24798 10.4928 6.22989 10.2524C6.27695 9.32281 6.56799 8.41491 7.08782 7.62574C7.92042 6.36743 9.25773 5.52475 10.7572 5.31475ZM4.67346 3.11956H8.73729C9.3534 3.12897 9.35557 4.04699 8.73729 4.05858H4.67346C4.05735 4.04699 4.05518 3.12897 4.67346 3.11956ZM3.5216 4.80067H8.02042C8.63654 4.81225 8.6387 5.73027 8.02042 5.73969H3.5216C2.9062 5.73028 2.90331 4.81225 3.5216 4.80067ZM6.01353 7.42438H3.5216C2.90476 7.41497 2.90331 6.49478 3.5216 6.48536H6.01353C6.63037 6.49477 6.63181 7.41497 6.01353 7.42438Z"
                                                            fill="currentColor"
                                                        />
                                                    </svg>
                                                    CHANNELS
                                                </div>
                                            </button>
                                            <button className={`flex-1 relative custom-gradient-button box-border border-l-2 rounded-r-[4px] ${tab === "members" ? `custom-gradient-button-active text-primary border-primary` : "text-[#4D4D4F] border-[#4D4D4F]"}`} onClick={() => setTab("members")}>
                                                <img src={bgArrowRightButton} className="absolute top-0 right-0 h-full z-[-1]" />
                                                <div className="flex items-center justify-center p-[8px] text-[0.8vh]">
                                                    <svg className="mr-[5px] smdesktop:w-[10px] smdesktop:h-[7px]" width="14" height="11" viewBox="0 0 17 14" fill="none" xmlns="http://www.w3.org/2000/svg">
                                                        <path
                                                            d="M9.04513 10.3486H5.44228C5.30012 10.3486 5.18478 10.4639 5.18478 10.6061C5.18478 10.7482 5.30012 10.8636 5.44228 10.8636H9.04513V11.4503C9.04513 11.5925 9.16047 11.7078 9.30263 11.7078H13.9797C13.9321 12.1001 13.7511 12.4528 13.4849 12.7197C13.1717 13.0328 12.7399 13.2273 12.2645 13.2273H2.0586C1.58385 13.2273 1.15133 13.0328 0.838184 12.7197C0.525037 12.4065 0.330578 11.9747 0.330578 11.4993V4.71326C0.330578 4.23851 0.525037 3.80598 0.838184 3.49284C1.15133 3.17969 1.58317 2.98523 2.0586 2.98523H10.3312C10.3299 3.02345 10.3285 3.06167 10.3285 3.0999C10.3285 3.84086 10.6289 4.51143 11.1151 4.99763C11.2452 5.12771 11.388 5.24372 11.5416 5.34497H11.2988C11.2371 5.34497 11.1754 5.34765 11.1151 5.35235C11.1003 5.34966 11.0856 5.34832 11.0701 5.34832H2.82296C2.6808 5.34832 2.56546 5.46366 2.56546 5.60582C2.56546 5.74797 2.6808 5.86331 2.82296 5.86331H9.86456C9.81024 5.90824 9.75794 5.95585 9.70765 6.00614C9.29928 6.41451 9.0458 6.97778 9.0458 7.59803V7.84815H2.82303C2.68087 7.84815 2.56554 7.96348 2.56554 8.10564C2.56554 8.2478 2.68087 8.36314 2.82303 8.36314H9.0458V10.3479L9.04513 10.3486ZM11.2982 5.85995H14.7287C15.2061 5.85995 15.6407 6.05574 15.9558 6.37092C16.271 6.68607 16.4668 7.1206 16.4668 7.5987V9.69244C16.4668 10.5214 15.7948 11.1935 14.9658 11.1935H11.0619C10.2328 11.1935 9.56081 10.5214 9.56081 9.69244V7.5987C9.56081 7.12127 9.75661 6.68607 10.0718 6.37092C10.3869 6.05576 10.8215 5.85995 11.2989 5.85995H11.2982ZM11.4786 1.56495C11.8709 1.17266 12.414 0.929932 13.0135 0.929932C13.6069 0.929932 14.1447 1.16798 14.5417 1.55892C14.94 1.9579 15.1834 2.50039 15.1834 3.09987C15.1834 3.69935 14.9407 4.24249 14.5484 4.63477C14.1561 5.02706 13.613 5.26979 13.0135 5.26979C12.414 5.26979 11.8709 5.02704 11.4786 4.63477C11.0863 4.24249 10.8436 3.69935 10.8436 3.09987C10.8436 2.50039 11.0863 1.9579 11.4786 1.56495Z"
                                                            fill="currentColor"
                                                        />
                                                    </svg>
                                                    MEMBERS
                                                </div>
                                            </button>
                                        </div>

                                        <div className="relative custom-radial-gradient rounded-[4px] shrink-0">
                                            <img src={bgArrow} className="w-full absolute top-0 right-0 z-0" />
                                            <div className="relative flex justfiy-between items-stretch z-10">
                                                <div className="w-3/4 py-[14px] pl-[14px] pr-[23px] smdesktop:p-[8px]">
                                                    <span className="flex items-center text-white text-[0.9vh]">
                                                        <svg className="mr-[3px]" width="9" height="8" viewBox="0 0 9 8" fill="none" xmlns="http://www.w3.org/2000/svg">
                                                            <path
                                                                d="M5.29018 1.08656C5.09483 0.822831 4.73342 0.773992 4.46969 0.95958C4.36224 1.03772 4.2841 1.15494 4.2548 1.28192L3.19988 5.23787L2.41845 3.58712C2.32077 3.38199 2.11565 3.25501 1.89099 3.25501H0.476615C0.346066 3.25501 0.240234 3.36084 0.240234 3.49139V4.19077C0.240234 4.32131 0.346066 4.42715 0.476615 4.42715H1.51982L2.8287 7.1719C2.92638 7.37702 3.1315 7.504 3.35616 7.504H3.405C3.64919 7.48446 3.85432 7.30864 3.91292 7.07422L5.06552 2.75685L6.12045 4.18295C6.22789 4.32947 6.40371 4.41738 6.5893 4.41738H8.27717C8.40772 4.41738 8.51355 4.31155 8.51355 4.181V3.48162C8.51355 3.35107 8.40772 3.24524 8.27717 3.24524H6.90187L5.29018 1.08656Z"
                                                                fill="white"
                                                            />
                                                        </svg>
                                                        Radio Channel
                                                    </span>
                                                    <span className="block text-[2vh] text-white">CHANNEL</span>
                                                    <span className="flex items-center">
                                                        <span className="text-primary truncate text-[0.8vh] smdesktop:text-[6px]">{onRadio ? "Connected" : "Not Connected"}</span>
                                                        <svg className="shrink-0 ml-[5px] smdesktop:w-[8px] smdesktop:h-[6px]" width="12" height="11" viewBox="0 0 12 11" fill="none" xmlns="http://www.w3.org/2000/svg">
                                                            <rect x="0.593048" y="0.630859" width="2.8609" height="9.4001" rx="0.4087" fill="#7CFFAE" />
                                                            <rect x="4.68007" y="3.08305" width="2.8609" height="6.9479" rx="0.4087" fill="#7CFFAE" />
                                                            <rect x="8.76709" y="5.94403" width="2.8609" height="4.087" rx="0.4087" fill="#7CFFAE" />
                                                        </svg>
                                                    </span>
                                                    <hr className="border-white/20 mt-[5px]" />
                                                    <input ref={inputRef} value={inputValue} onChange={(e) => setInputValue(e.target.value)} onKeyDown={handleKeyDown} type="number" className="w-full h-[32px] smdesktop:h-auto smdesktop:text-[14px] smdesktop:p-[4px] bg-white/10 mt-[8px] rounded-[3px] text-center text-white text-[17px] focus:ring-0 focus:outline-none" placeholder="0.00" max={9999} maxLength={4} disabled={onRadio} />
                                                </div>
                                                <div className="w-1/4 flex flex-col w-25 p-[6px] bg-black/10 shrink-0 gap-2 smdesktop:gap-1">
                                                    {onRadio ? (
                                                        <button className="flex-1 flex items-center justify-center bg-[#C65353] px-[6px] py-[4px] rounded-[1px] hover:opacity-80 smdesktop:mb-0 smdesktop:p-[2px]" onClick={leaveChannel}>
                                                            <svg className="smdesktop:w-[10px] smdesktop:h-[12px]" width="15" height="17" viewBox="0 0 15 17" fill="none" xmlns="http://www.w3.org/2000/svg">
                                                                <path
                                                                    d="M11.618 2.37645H2.6266V14.9644H11.618V14.0653C11.618 13.5687 12.0206 13.1661 12.5171 13.1661C13.0137 13.1661 13.4163 13.5687 13.4163 14.0653V15.1442C13.4163 16.0381 12.6917 16.7627 11.7978 16.7627H2.44677C1.55293 16.7627 0.828323 16.0381 0.828323 15.1442V2.19662C0.828323 1.30278 1.55293 0.578171 2.44677 0.578171H11.7978C12.6917 0.578171 13.4163 1.30278 13.4163 2.19662V3.27559C13.4163 3.77217 13.0137 4.17473 12.5171 4.17473C12.0206 4.17473 11.618 3.77217 11.618 3.27559V2.37645ZM11.1176 9.58897L5.32197 9.56957C4.82539 9.56843 4.42375 9.16496 4.42489 8.66838C4.42602 8.1718 4.8295 7.77016 5.32608 7.77129L11.137 7.79074V7.77129L10.0063 6.64059C9.63764 6.27189 9.63764 5.67413 10.0063 5.30543C10.375 4.93674 10.9728 4.93674 11.3415 5.30543L14.0389 8.00285C14.4076 8.37155 14.4076 8.96931 14.0389 9.33801L11.3415 12.0354C10.9728 12.4041 10.375 12.4041 10.0063 12.0354C9.63764 11.6667 9.63764 11.069 10.0063 10.7003L11.1176 9.58897Z"
                                                                    fill="white"
                                                                />
                                                            </svg>
                                                        </button>
                                                    ) : (
                                                        <button className="flex-1 flex items-center justify-center bg-[#7CFFAE61] px-[6px] py-[4px] rounded-[1px] hover:opacity-80 smdesktop:mb-0 smdesktop:p-[2px]" onClick={handleConnect}>
                                                            <svg className="smdesktop:w-[10px] smdesktop:h-[12px]" width="15" height="17" viewBox="0 0 15 17" fill="none" xmlns="http://www.w3.org/2000/svg">
                                                                <path
                                                                    d="M11.618 2.37645H2.6266V14.9644H11.618V14.0653C11.618 13.5687 12.0206 13.1661 12.5171 13.1661C13.0137 13.1661 13.4163 13.5687 13.4163 14.0653V15.1442C13.4163 16.0381 12.6917 16.7627 11.7978 16.7627H2.44677C1.55293 16.7627 0.828323 16.0381 0.828323 15.1442V2.19662C0.828323 1.30278 1.55293 0.578171 2.44677 0.578171H11.7978C12.6917 0.578171 13.4163 1.30278 13.4163 2.19662V3.27559C13.4163 3.77217 13.0137 4.17473 12.5171 4.17473C12.0206 4.17473 11.618 3.77217 11.618 3.27559V2.37645ZM11.1176 9.58897L5.32197 9.56957C4.82539 9.56843 4.42375 9.16496 4.42489 8.66838C4.42602 8.1718 4.8295 7.77016 5.32608 7.77129L11.137 7.79074V7.77129L10.0063 6.64059C9.63764 6.27189 9.63764 5.67413 10.0063 5.30543C10.375 4.93674 10.9728 4.93674 11.3415 5.30543L14.0389 8.00285C14.4076 8.37155 14.4076 8.96931 14.0389 9.33801L11.3415 12.0354C10.9728 12.4041 10.375 12.4041 10.0063 12.0354C9.63764 11.6667 9.63764 11.069 10.0063 10.7003L11.1176 9.58897Z"
                                                                    fill="white"
                                                                />
                                                            </svg>
                                                        </button>
                                                    )}
                                                    <button className="flex-1 flex items-center justify-center bg-white px-[6px] py-[4px] rounded-[1px] hover:opacity-80 smdesktop:mb-0 smdesktop:p-[2px]" onClick={handleMemberMenu}>
                                                        <svg className="smdesktop:w-[10px] smdesktop:h-[12px]" width="15" height="13" viewBox="0 0 15 13" fill="none" xmlns="http://www.w3.org/2000/svg">
                                                            <path
                                                                d="M9.15021 1.05155C8.81245 0.595561 8.18757 0.511119 7.73159 0.831999C7.54581 0.967107 7.41071 1.16977 7.36004 1.38932L5.53609 8.22913L4.18502 5.37499C4.01613 5.02033 3.66147 4.80078 3.27304 4.80078H0.827596C0.601877 4.80078 0.418896 4.98376 0.418896 5.20948V6.41869C0.418896 6.64441 0.601877 6.82739 0.827596 6.82739H2.63128L4.89433 11.573C5.06321 11.9277 5.41787 12.1472 5.8063 12.1472H5.89075C6.31296 12.1135 6.66761 11.8095 6.76895 11.4042L8.76178 3.93947L10.5857 6.40518C10.7715 6.65851 11.0755 6.8105 11.3964 6.8105H14.3147C14.5404 6.8105 14.7234 6.62752 14.7234 6.4018V5.19259C14.7234 4.96687 14.5404 4.78389 14.3147 4.78389H11.9368L9.15021 1.05155Z"
                                                                fill="#7091FF"
                                                            />
                                                        </svg>
                                                    </button>
                                                    <button className="handle flex-1 flex items-center justify-center bg-white/10 px-[6px] py-[4px] rounded-[1px] hover:opacity-80 smdesktop:mb-0 smdesktop:p-[2px]">
                                                        <svg className="smdesktop:w-[10px] smdesktop:h-[12px]" width="13" height="13" viewBox="0 0 17 17" fill="none" xmlns="http://www.w3.org/2000/svg">
                                                            <path d="M5.7 12C4.1 11.9167 2.75 11.3 1.65 10.15C0.55 9 0 7.61667 0 6C0 4.33333 0.583333 2.91667 1.75 1.75C2.91667 0.583333 4.33333 0 6 0C7.61667 0 9 0.55 10.15 1.65C11.3 2.75 11.9167 4.1 12 5.7L9.9 5.075C9.68333 4.175 9.21667 3.4375 8.5 2.8625C7.78333 2.2875 6.95 2 6 2C4.9 2 3.95833 2.39167 3.175 3.175C2.39167 3.95833 2 4.9 2 6C2 6.95 2.2875 7.78333 2.8625 8.5C3.4375 9.21667 4.175 9.68333 5.075 9.9L5.7 12ZM14.525 16.5L10.25 12.225L9 16L6 6L16 9L12.225 10.25L16.5 14.525L14.525 16.5Z" fill="white" />
                                                        </svg>
                                                    </button>
                                                    <button className="flex-1 flex items-center justify-center bg-white/10 px-[6px] py-[4px] rounded-[1px] hover:opacity-80 smdesktop:mb-0 smdesktop:p-[2px]" onClick={handleResetPosition}>
                                                        <svg className="smdesktop:w-[10px] smdesktop:h-[12px]" width="15" height="15" viewBox="0 0 20 20" fill="none" xmlns="http://www.w3.org/2000/svg">
                                                            <path
                                                                d="M9.77344 12.2963V10.7963C9.77344 10.3796 9.91927 10.0254 10.2109 9.73376C10.5026 9.4421 10.8568 9.29626 11.2734 9.29626H12.7734L9.77344 12.2963ZM9.77344 16.3213V14.1963L14.6734 9.29626H16.7984L9.77344 16.3213ZM9.82344 18.1963L18.6484 9.34626C18.9151 9.41293 19.1443 9.5421 19.3359 9.73376C19.5276 9.92543 19.6568 10.1546 19.7234 10.4213L10.8734 19.2463C10.6068 19.1629 10.3859 19.0338 10.2109 18.8588C10.0359 18.6838 9.90677 18.4629 9.82344 18.1963ZM12.7484 19.2963L19.7734 12.2713V14.3963L14.8734 19.2963H12.7484ZM16.7734 19.2963L19.7734 16.2963V17.7963C19.7734 18.2129 19.6276 18.5671 19.3359 18.8588C19.0443 19.1504 18.6901 19.2963 18.2734 19.2963H16.7734ZM18.5484 7.29626H16.4734C16.0401 5.8296 15.2151 4.6296 13.9984 3.69626C12.7818 2.76293 11.3734 2.29626 9.77344 2.29626C7.82344 2.29626 6.16927 2.97543 4.81094 4.33376C3.4526 5.6921 2.77344 7.34626 2.77344 9.29626C2.77344 10.4963 3.04427 11.5963 3.58594 12.5963C4.1276 13.5963 4.85677 14.4129 5.77344 15.0463V12.2963H7.77344V18.2963H1.77344V16.2963H4.12344C3.0901 15.4629 2.27344 14.4421 1.67344 13.2338C1.07344 12.0254 0.773438 10.7129 0.773438 9.29626C0.773438 8.04626 1.01094 6.87543 1.48594 5.78376C1.96094 4.6921 2.6026 3.7421 3.41094 2.93376C4.21927 2.12543 5.16927 1.48376 6.26094 1.00876C7.3526 0.533765 8.52344 0.296265 9.77344 0.296265C11.9234 0.296265 13.8109 0.958765 15.4359 2.28376C17.0609 3.60876 18.0984 5.2796 18.5484 7.29626Z"
                                                                fill="white"
                                                                fillOpacity="0.20"
                                                            />
                                                        </svg>
                                                    </button>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <div className="flex flex-col w-[42%]">
                                        <Transition show={tab === "members"} as={Fragment} enter="transition-all duration-300 ease-out" enterFrom="opacity-0 transform translate-y-20" enterTo="opacity-100 transform translate-y-0" leave="transition-all duration-300 ease-in" leaveFrom="opacity-100 transform translate-y-0" leaveTo="opacity-0 transform translate-y-20">
                                            <div className="relative grow custom-radial-gradient rounded-[4px] overflow-hidden">
                                                <img src={bgArrowBig} className="w-full absolute bottom-0 left-0 z-[-1]" />
                                                <div className="w-full h-full max-h-full p-[14px] flex flex-col smdesktop:p-[8px]">
                                                    <div className="flex items-center shrink-0 mb-[8px]">
                                                        <span className="flex items-center text-white text-[10px] smdesktop:text-[6px] shrink-0">
                                                            <svg className="mr-[3px]" width="6" height="5" viewBox="0 0 9 8" fill="none" xmlns="http://www.w3.org/2000/svg">
                                                                <path
                                                                    d="M5.29018 1.08656C5.09483 0.822831 4.73342 0.773992 4.46969 0.95958C4.36224 1.03772 4.2841 1.15494 4.2548 1.28192L3.19988 5.23787L2.41845 3.58712C2.32077 3.38199 2.11565 3.25501 1.89099 3.25501H0.476615C0.346066 3.25501 0.240234 3.36084 0.240234 3.49139V4.19077C0.240234 4.32131 0.346066 4.42715 0.476615 4.42715H1.51982L2.8287 7.1719C2.92638 7.37702 3.1315 7.504 3.35616 7.504H3.405C3.64919 7.48446 3.85432 7.30864 3.91292 7.07422L5.06552 2.75685L6.12045 4.18295C6.22789 4.32947 6.40371 4.41738 6.5893 4.41738H8.27717C8.40772 4.41738 8.51355 4.31155 8.51355 4.181V3.48162C8.51355 3.35107 8.40772 3.24524 8.27717 3.24524H6.90187L5.29018 1.08656Z"
                                                                    fill="white"
                                                                />
                                                            </svg>
                                                            Members List
                                                        </span>
                                                        <span className="w-full bg-white/10 rounded h-[1px] mx-[5px]"></span>
                                                        <span className="text-[6px] text-white/25 shrink-0">{onRadio && inputValue ? inputValue : "0"} MHZ</span>
                                                    </div>
                                                    <div className="overflow-auto no-scrollbar w-full grow flex flex-col gap-[6px]">
                                                        {playersInRadio?.map((player: PlayerOnRadioType, index: number) => (
                                                            <div key={index} className="w-full flex items-center p-[5px] bg-white/5 rounded-[4px]">
                                                                <svg className="shrink-0 mr-[4px]" width="5" height="6" viewBox="0 0 5 6" fill="none" xmlns="http://www.w3.org/2000/svg">
                                                                    <rect x="1.33633" y="1.51138" width="3.00209" height="3.00209" rx="1.50104" stroke="white" strokeWidth="1.12578" />
                                                                </svg>

                                                                <span className="text-[6px] text-white truncate">{player.name}</span>

                                                                <div className="flex items-center shrink-0 ml-auto">
                                                                    <button className={`mr-[6px] smdesktop:mr-[2px] ${player.isMuted ? "text-[#C65353]" : "text-white"}`} onClick={() => handleMutePlayer(player.source)}>
                                                                        <svg className="smdesktop:w-[10px] smdesktop:h-[12px]" width="15" height="13" viewBox="0 0 15 13" fill="currentColor" xmlns="http://www.w3.org/2000/svg">
                                                                            <path
                                                                                d="M10.3328 3.66973C10.0323 3.86327 9.95086 4.26051 10.1393 4.56099C10.893 5.73236 10.9032 7.25005 10.1648 8.43161C9.97632 8.73209 10.068 9.12934 10.3685 9.31777C10.4754 9.38398 10.5926 9.41454 10.7097 9.41454C10.9236 9.41454 11.1324 9.30759 11.2546 9.11406C12.2579 7.50979 12.2427 5.45225 11.219 3.86327C11.0306 3.56278 10.6282 3.4762 10.3328 3.66973ZM13.4701 2.49327C13.2816 2.19279 12.8844 2.10621 12.5839 2.29465C12.2834 2.48309 12.1917 2.88033 12.3853 3.18082C13.6941 5.25363 13.6687 7.91213 12.314 9.95948C12.1204 10.2549 12.2019 10.6572 12.4973 10.8507C12.6043 10.922 12.7316 10.9577 12.8487 10.9577C13.0575 10.9577 13.2612 10.8558 13.3886 10.6674C15.0132 8.19733 15.0489 4.99389 13.4701 2.49327Z"
                                                                                fill="currentColor"
                                                                                fillOpacity={!player.isMuted ? "0.22" : "1"}
                                                                            />
                                                                            <path d="M7.56738 0.624175L3.82918 3.51185H1.2318C0.753062 3.51695 0.371094 3.89892 0.371094 4.37256V8.66079C0.371094 9.13443 0.753062 9.51639 1.2267 9.51639H3.82409L7.56228 12.4041C8.1276 12.8421 8.94246 12.4397 8.94246 11.7267V1.30153C8.94755 0.593617 8.13269 0.191277 7.56738 0.624175Z" fill="currentColor" fillOpacity={!player.isMuted ? "0.22" : "1"} />
                                                                        </svg>
                                                                    </button>
                                                                    <button>
                                                                        <svg className="smdesktop:w-[10px] smdesktop:h-[12px]" width="17" height="16" viewBox="0 0 17 16" fill="none" xmlns="http://www.w3.org/2000/svg">
                                                                            <path
                                                                                d="M5.13 3.32221C3.76149 3.32221 4.386 7.23905 2.03992 7.46011C-0.305442 7.68117 -0.366809 8.01276 2.03992 8.23382C4.44736 8.45488 3.61152 12.2088 5.13 12.2088C6.64771 12.2088 6.131 8.83776 8.11909 8.83776C10.1079 8.83776 9.44546 15.3529 11.3397 15.3529C13.2332 15.3529 12.3275 8.79779 14.8657 8.52544C17.4038 8.25395 17.4038 7.90234 14.8657 7.50788C12.3276 7.11411 12.9826 0.717773 11.3397 0.717773C9.69623 0.717773 9.99744 7.30609 8.11909 7.30609C6.24149 7.30609 6.49775 3.32221 5.13 3.32221Z"
                                                                                fill="white"
                                                                                fillOpacity="0.17"
                                                                            />
                                                                        </svg>
                                                                    </button>
                                                                </div>
                                                            </div>
                                                        ))}
                                                    </div>
                                                </div>
                                            </div>
                                        </Transition>

                                        <Transition show={tab === "channels"} as={Fragment} enter="transition-all duration-300 ease-out" enterFrom="opacity-0 transform translate-y-20" enterTo="opacity-100 transform translate-y-0" leave="transition-all duration-300 ease-in" leaveFrom="opacity-100 transform translate-y-0" leaveTo="opacity-0 transform translate-y-20">
                                            <div>
                                                <div className="relative w-full custom-gradient-button rounded-[4px] mr-[14px]" onClick={() => setTab("channels")}>
                                                    <img src={bgArrowLeftButton} className="absolute top-0 left-0 h-full z-[-1]" />

                                                    <div className="flex items-center p-[11px] text-white text-[10px] smdesktop:p-[7px] smdesktop:text-[6px]">
                                                        <svg className="mr-[4px]" width="9" height="8" viewBox="0 0 9 8" fill="none" xmlns="http://www.w3.org/2000/svg">
                                                            <path
                                                                d="M5.25307 1.14808C5.05772 0.884354 4.69631 0.835515 4.43258 1.0211C4.32513 1.09925 4.24699 1.21646 4.21769 1.34344L3.16277 5.2994L2.38134 3.64864C2.28366 3.44352 2.07854 3.31653 1.85388 3.31653H0.439506C0.308956 3.31653 0.203125 3.42237 0.203125 3.55291V4.25229C0.203125 4.38284 0.308956 4.48867 0.439506 4.48867H1.48271L2.79159 7.23342C2.88927 7.43854 3.09439 7.56552 3.31905 7.56552H3.36789C3.61208 7.54599 3.81721 7.37017 3.87582 7.13574L5.02841 2.81838L6.08334 4.24447C6.19078 4.39099 6.3666 4.4789 6.55219 4.4789H8.24006C8.37061 4.4789 8.47645 4.37307 8.47645 4.24252V3.54315C8.47645 3.4126 8.37061 3.30677 8.24006 3.30677H6.86476L5.25307 1.14808Z"
                                                                fill="white"
                                                            />
                                                        </svg>
                                                        All Channels
                                                    </div>
                                                </div>
                                            </div>
                                        </Transition>

                                        <Transition show={tab === "channels"} as={Fragment} enter="transition-all duration-300 ease-out" enterFrom="opacity-0 transform translate-y-20" enterTo="opacity-100 transform translate-y-0" leave="transition-all duration-300 ease-in" leaveFrom="opacity-100 transform translate-y-0" leaveTo="opacity-0 transform translate-y-20">
                                            <div className="relative grow custom-radial-gradient rounded-[4px] mt-[12px] overflow-hidden smdesktop:mt-[8px]">
                                                <img src={bgArrowBig} className="w-full absolute bottom-0 left-0 z-[-1]" />
                                                <div className="w-full h-full max-h-full p-[14px] smdesktop:p-[8px] flex flex-col">
                                                    <div className="overflow-auto no-scrollbar w-full grow flex flex-col gap-[6px]">
                                                        {channels?.map((item: ChannelsType, index: number) => (
                                                            <div key={index} className="w-full flex items-center justify-between p-[7px] bg-white/10 rounded-[4px] smdesktop:p-[4px]">
                                                                <div className="text-[12px] text-white smdesktop:text-[7px]">
                                                                    <span className="text-[12px] smdesktop:text-[7px] text-[#637CCA]">#</span>
                                                                    {item.channel}
                                                                    <small>mhz</small>
                                                                </div>

                                                                <div className="flex items-center">
                                                                    <button onClick={(e) => handleConnect(e, item.channel)}>
                                                                        <svg className="smdesktop:w-[14px] smdesktop:h-[14px]" width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                                                                            <rect x="0.382812" y="0.204102" width="23.2229" height="23.2229" rx="1.65878" fill={item.active ? "#C65353" : "#7CFFAE"} fillOpacity="0.38" />
                                                                            <path
                                                                                d="M15.5029 6.59391H8.25602V16.7395H15.5029V16.0148C15.5029 15.6146 15.8273 15.2902 16.2276 15.2902C16.6278 15.2902 16.9523 15.6146 16.9523 16.0148V16.8845C16.9523 17.6049 16.3682 18.1889 15.6478 18.1889H8.11108C7.39066 18.1889 6.80664 17.6049 6.80664 16.8845V6.44897C6.80664 5.72855 7.39066 5.14453 8.11108 5.14453H15.6478C16.3682 5.14453 16.9523 5.72855 16.9523 6.44897V7.31859C16.9523 7.71883 16.6278 8.04328 16.2276 8.04328C15.8273 8.04328 15.5029 7.71883 15.5029 7.31859V6.59391ZM15.0996 12.407L10.4284 12.3914C10.0282 12.3905 9.70448 12.0653 9.70539 11.6651C9.70631 11.2648 10.0315 10.9411 10.4317 10.942L15.1152 10.9577V10.942L14.2039 10.0307C13.9068 9.73355 13.9068 9.25176 14.2039 8.9546C14.5011 8.65744 14.9829 8.65744 15.28 8.9546L17.4541 11.1287C17.7512 11.4258 17.7512 11.9076 17.4541 12.2048L15.28 14.3788C14.9829 14.676 14.5011 14.676 14.2039 14.3788C13.9068 14.0817 13.9068 13.5999 14.2039 13.3027L15.0996 12.407Z"
                                                                                fill={item.active ? "#C65353" : "#7CFFAE"}
                                                                            />
                                                                        </svg>
                                                                    </button>
                                                                </div>
                                                            </div>
                                                        ))}
                                                    </div>
                                                </div>
                                            </div>
                                        </Transition>
                                    </div>
                                </div>
                            </div>

                            <Transition show={visibleSoundBar} as={Fragment} enter="transition-all duration-300 ease-out" enterFrom="opacity-0" enterTo="opacity-100" leave="transition-all duration-300 ease-in" leaveFrom="opacity-100" leaveTo="opacity-0">
                                <div className="absolute top-[18%] left-[15px] rounded-[18px] w-[13px] h-[80px] bg-white/10 z-10 p-[5px]">
                                    <div className="flex items-end bg-white/10 w-full h-full rounded-[2px]">
                                        <div className="bg-white w-full h-0 transition-all" style={{ height: `${radioVolume}%` }}></div>
                                    </div>
                                </div>
                            </Transition>
                        </div>

                        <div className="absolute overflow-hidden top-[7%] left-[1vh] h-[5vh] flex items-center justify-center">
                            <button className="w-[5.5vh] h-full rounded-full hover:bg-sky-200/10 outline-none" onClick={handleRadioPower}></button>
                        </div>

                        <div className="absolute overflow-hidden bottom-[13vh] left-[1.3vh] w-[6vh] h-[4.5vh]">
                            <div>
                                <Button
                                    onClick={() => {
                                        handleVolumeSet("volumeUp");
                                    }}
                                    rounded="full"
                                    style={{
                                        bottom: "1.25vh",
                                        left: "0vh",
                                        width: "3vh",
                                        height: "1.5vh",
                                    }}
                                ></Button>
                            </div>
                            <div>
                                <Button
                                    onClick={() => {
                                        handleVolumeSet("volumeDown");
                                    }}
                                    rounded="full"
                                    style={{
                                        bottom: "1.25vh",
                                        right: "0vh",
                                        width: "3vh",
                                        height: "1.5vh",
                                    }}
                                ></Button>
                            </div>
                        </div>
                    </div>
                </Transition>
            </Draggable>
        </>
    );
};

export default HorizontalRadio;
