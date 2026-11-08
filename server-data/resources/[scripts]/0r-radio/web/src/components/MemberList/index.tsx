import React, { Fragment, useEffect, useState, useRef } from "react";
import { Transition } from "@headlessui/react";
import Draggable, { DraggableData } from "react-draggable";
import bgArrowBig from "../../assets/images/bg-arrow-big.svg";

type PlayerOnRadioType = {
    source: number;
    name: string;
    isMuted: boolean;
    isTalking: boolean;
};

const MemberList: React.FC = ({ inputValue, radioVisible, visible, playersInRadio, onRadio, handleMutePlayer }) => {
    const nodeRef = useRef(null);
    const [dragPosition, setDragPosition] = useState({ x: 0, y: 0 });

    useEffect(() => {
        const position = localStorage.getItem("membersMenuPosition");
        if (position) {
            setDragPosition(JSON.parse(position));
        }
    }, []);

    const handleResetPosition = () => {
        setDragPosition({ x: 0, y: 0 });
        localStorage.removeItem("membersMenuPosition");
    };

    const handleDragStop = (data: DraggableData) => {
        localStorage.setItem("membersMenuPosition", JSON.stringify({ x: data.x, y: data.y }));
    };

    return (
        <>
            <Draggable nodeRef={nodeRef} bounds=".drag-container" scale={1} handle=".handle" position={dragPosition} onDrag={(e, data) => setDragPosition({ x: data.x, y: data.y })} onStop={(e, data) => handleDragStop(data)} disabled={!visible}>
                <Transition unmount={false} show={visible} as={Fragment} enter="transition-all duration-300 ease-out" enterFrom="bottom-[-70%] opacity-0" enterTo="bottom-[5vh] opacity-1" leave="transition-all duration-300 ease-in" leaveFrom="bottom-[5vh] opacity-1" leaveTo="bottom-[-70%] opacity-0">
                    <div ref={nodeRef} className="z-[120] absolute top-[26px] left-[29px] w-[135px] h-[185px] overflow-hidden">
                        <div className="w-full h-full max-h-full flex flex-col">
                            <div className="handle flex items-center shrink-0 mb-[8px] cursor-grab">
                                <span className="flex items-center text-white text-[10px] shrink-0">
                                    <svg className="mr-[3px]" width="11" height="10" viewBox="0 0 11 10" fill="none" xmlns="http://www.w3.org/2000/svg">
                                        <path
                                            d="M6.51758 1.00009C6.26545 0.659712 5.79901 0.59668 5.45863 0.836204C5.31996 0.937056 5.21911 1.08833 5.18129 1.25222L3.81978 6.35787L2.81126 4.22736C2.68519 3.96263 2.42046 3.79874 2.13051 3.79874H0.305078C0.136588 3.79874 0 3.93533 0 4.10382V5.00645C0 5.17494 0.136588 5.31153 0.305078 5.31153H1.65146L3.34073 8.85396C3.4668 9.1187 3.73154 9.28259 4.02149 9.28259H4.08452C4.39968 9.25737 4.66442 9.03046 4.74006 8.7279L6.22763 3.15581L7.58914 4.99636C7.72781 5.18546 7.95473 5.29892 8.19425 5.29892H10.3727C10.5412 5.29892 10.6777 5.16233 10.6777 4.99384V4.09121C10.6777 3.92272 10.5412 3.78613 10.3727 3.78613H8.59766L6.51758 1.00009Z"
                                            fill="white"
                                        />
                                    </svg>
                                    Members List
                                </span>
                                <span className="text-[10px] text-white shrink-0 ml-auto">{onRadio && inputValue ? inputValue : "0"} mhz</span>
                            </div>
                            <hr className="border-white/25 mb-[10px]" />

                            <div className="overflow-auto no-scrollbar w-full grow flex flex-col">
                                {playersInRadio &&
                                    playersInRadio?.map((player: PlayerOnRadioType, index: number) => (
                                        <div key={index} className="w-full flex items-center mb-[8px]">
                                            <svg className="shrink-0 mr-[4px]" width="6" height="7" viewBox="0 0 6 7" fill="none" xmlns="http://www.w3.org/2000/svg">
                                                <rect x="0.847575" y="1.48625" width="3.87456" height="3.87456" rx="1.93728" stroke="white" strokeWidth="1.45296" />
                                            </svg>

                                            <span className="text-[12px] text-white font-medium truncate mr-[4px]">{player.name}</span>

                                            <div className="flex items-center ml-auto">
                                                <button className={`mr-[6px] ${player.isMuted ? "text-[#C65353]" : "text-white"}`} onClick={() => handleMutePlayer(player.source)}>
                                                    <svg width="12" height="15" viewBox="0 0 15 13" fill="currentColor" xmlns="http://www.w3.org/2000/svg">
                                                        <path
                                                            d="M10.1397 3.42803C9.83388 3.62502 9.75093 4.02937 9.94274 4.33522C10.71 5.52752 10.7203 7.07232 9.96866 8.27499C9.77685 8.58084 9.87016 8.98518 10.176 9.17699C10.2849 9.24438 10.4041 9.27548 10.5233 9.27548C10.7411 9.27548 10.9536 9.16662 11.078 8.96963C12.0992 7.3367 12.0837 5.2424 11.0417 3.62502C10.8499 3.31917 10.4404 3.23104 10.1397 3.42803ZM13.333 2.23055C13.1412 1.9247 12.7369 1.83657 12.431 2.02838C12.1252 2.22018 12.0319 2.62453 12.2288 2.93038C13.5611 5.04023 13.5352 7.74623 12.1563 9.83016C11.9593 10.1308 12.0422 10.5404 12.3429 10.7373C12.4518 10.8099 12.5813 10.8462 12.7006 10.8462C12.9131 10.8462 13.1205 10.7425 13.2501 10.5507C14.9037 8.03653 14.94 4.77585 13.333 2.23055Z"
                                                            fill="currentColor"
                                                        />
                                                        <path d="M7.32486 0.328054L3.51987 3.26733H0.876081C0.388793 3.27252 0 3.66131 0 4.14341V8.50826C0 8.99037 0.388793 9.37916 0.870897 9.37916H3.51469L7.31968 12.3184C7.89509 12.7643 8.72452 12.3547 8.72452 11.629V1.01751C8.7297 0.296951 7.90028 -0.112578 7.32486 0.328054Z" fill="currentColor" />
                                                    </svg>
                                                </button>
                                                <button>
                                                    <svg width="12" height="15" viewBox="0 0 18 15" fill="none" xmlns="http://www.w3.org/2000/svg">
                                                        <path d="M5.47096 2.65097C4.078 2.65097 4.71367 6.6378 2.32567 6.86281C-0.0616003 7.08782 -0.124063 7.42533 2.32567 7.65034C4.77613 7.87535 3.92535 11.6964 5.47096 11.6964C7.01579 11.6964 6.48985 8.26507 8.51346 8.26507C10.5378 8.26507 9.86353 14.8967 11.7916 14.8967C13.719 14.8967 12.7971 8.22439 15.3806 7.94718C17.9641 7.67083 17.9641 7.31294 15.3806 6.91143C12.7971 6.51062 13.4639 0 11.7916 0C10.1188 0 10.4254 6.70604 8.51346 6.70604C6.60231 6.70604 6.86315 2.65097 5.47096 2.65097Z" fill={player.isTalking ? "#7CFFAE" : "white"} />
                                                    </svg>
                                                </button>
                                            </div>
                                        </div>
                                    ))}
                            </div>

                            <hr className="border-white/25 mb-[10px]" />

                            {radioVisible && (
                            <div>
                                <button className="flex items-center justify-center bg-white/40 p-[6px] rounded-[1px] hover:opacity-80" onClick={handleResetPosition}>
                                    <svg width="15" height="15" viewBox="0 0 20 20" fill="none" xmlns="http://www.w3.org/2000/svg">
                                        <path
                                            d="M9.77344 12.2963V10.7963C9.77344 10.3796 9.91927 10.0254 10.2109 9.73376C10.5026 9.4421 10.8568 9.29626 11.2734 9.29626H12.7734L9.77344 12.2963ZM9.77344 16.3213V14.1963L14.6734 9.29626H16.7984L9.77344 16.3213ZM9.82344 18.1963L18.6484 9.34626C18.9151 9.41293 19.1443 9.5421 19.3359 9.73376C19.5276 9.92543 19.6568 10.1546 19.7234 10.4213L10.8734 19.2463C10.6068 19.1629 10.3859 19.0338 10.2109 18.8588C10.0359 18.6838 9.90677 18.4629 9.82344 18.1963ZM12.7484 19.2963L19.7734 12.2713V14.3963L14.8734 19.2963H12.7484ZM16.7734 19.2963L19.7734 16.2963V17.7963C19.7734 18.2129 19.6276 18.5671 19.3359 18.8588C19.0443 19.1504 18.6901 19.2963 18.2734 19.2963H16.7734ZM18.5484 7.29626H16.4734C16.0401 5.8296 15.2151 4.6296 13.9984 3.69626C12.7818 2.76293 11.3734 2.29626 9.77344 2.29626C7.82344 2.29626 6.16927 2.97543 4.81094 4.33376C3.4526 5.6921 2.77344 7.34626 2.77344 9.29626C2.77344 10.4963 3.04427 11.5963 3.58594 12.5963C4.1276 13.5963 4.85677 14.4129 5.77344 15.0463V12.2963H7.77344V18.2963H1.77344V16.2963H4.12344C3.0901 15.4629 2.27344 14.4421 1.67344 13.2338C1.07344 12.0254 0.773438 10.7129 0.773438 9.29626C0.773438 8.04626 1.01094 6.87543 1.48594 5.78376C1.96094 4.6921 2.6026 3.7421 3.41094 2.93376C4.21927 2.12543 5.16927 1.48376 6.26094 1.00876C7.3526 0.533765 8.52344 0.296265 9.77344 0.296265C11.9234 0.296265 13.8109 0.958765 15.4359 2.28376C17.0609 3.60876 18.0984 5.2796 18.5484 7.29626Z"
                                            fill="white"
                                        />
                                    </svg>
                                </button>
                            </div>
                            )}
                        </div>
                    </div>
                </Transition>
            </Draggable>
        </>
    );
};

export default MemberList;
