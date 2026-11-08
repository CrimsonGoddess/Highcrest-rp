import { FC, Fragment, useEffect } from "react";
import { Transition } from "@headlessui/react";

type AlertProps = {
    alert: any;
    index: number;
    onClose: (index: number) => void;
    isLast: boolean;
};

const Alert: FC<AlertProps> = ({ alert, index, onClose, isLast }) => {
    return (
        <Transition show={alert.visible && isLast} appear={true} as={Fragment} enter="ease-out duration-300" enterFrom="scale-50 -translate-y-2/4" enterTo="scale-100" leave="ease-in duration-200" leaveFrom="scale-100" leaveTo="scale-90 blur" afterEnter={() => setTimeout(() => onClose(index), 2000)}>
            <div className={`absolute top-0 left-0 w-full z-[10] flex items-center custom-radial-gradient rounded-[4px] p-[13px] smdesktop:p-[8px]`}>
                <div className="absolute left-0 top-[-8px] w-full h-full custom-radial-gradient opacity-30 rounded-[4px] z-[-1] scale-90"></div>
                <div className="mr-[10px]">
                    <svg width="19" height="18" viewBox="0 0 19 18" fill="none" xmlns="http://www.w3.org/2000/svg">
                        <path
                            d="M18.615 14.134L11.2764 1.79433C10.8987 1.15782 10.2133 0.7677 9.47306 0.7677C8.73285 0.7677 8.04745 1.1578 7.66973 1.79433L0.362832 14.134C-0.0101867 14.7799 -0.011823 15.5755 0.358386 16.2231C0.728595 16.8706 1.41497 17.2728 2.16076 17.2792H16.8381C17.5801 17.2656 18.2599 16.8605 18.625 16.2142C18.99 15.5679 18.9862 14.7769 18.615 14.134ZM9.49954 15.1824C9.22153 15.1824 8.95475 15.072 8.75819 14.8754C8.56162 14.6788 8.45116 14.4121 8.45116 14.134C8.45116 13.856 8.56162 13.5893 8.75819 13.3927C8.95475 13.1961 9.22153 13.0857 9.49954 13.0857C9.77755 13.0857 10.0443 13.1961 10.2409 13.3927C10.4375 13.5893 10.5479 13.856 10.5479 14.134C10.5479 14.4121 10.4375 14.6788 10.2409 14.8754C10.0443 15.072 9.77755 15.1824 9.49954 15.1824ZM10.5479 10.4647C10.5479 10.8394 10.3481 11.1855 10.0237 11.3727C9.69939 11.5599 9.29969 11.5599 8.97535 11.3727C8.65101 11.1855 8.45116 10.8394 8.45116 10.4647V6.27121C8.45116 5.89655 8.65101 5.55046 8.97535 5.36325C9.2997 5.17604 9.69939 5.17604 10.0237 5.36325C10.3481 5.55046 10.5479 5.89656 10.5479 6.27121V10.4647Z"
                            fill="#7CFFAE"
                        />
                    </svg>
                </div>
                <div className="flex flex-col">
                    <span className="text-white text-[10px] leading-5">{alert.title}</span>
                    <span className="text-white/25 text-[7px]">{alert.message}</span>
                </div>
            </div>
        </Transition>
    );
};

export default Alert;
