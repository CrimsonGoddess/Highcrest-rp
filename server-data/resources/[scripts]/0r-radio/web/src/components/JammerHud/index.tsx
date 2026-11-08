import { FC } from "react";
import noSignalGif from "../../assets/images/no-signal.gif";

const JammerHud: FC = () => {
  return (
    <>
      <div className="z-[500] w-full h-full top-0 left-0 absolute overflow-hidden flex items-center justify-center">
        <img src={noSignalGif} alt="no-signal" className="w-full h-full" />
        <div className="absolute top-[30%] text-center bg-black/75 px-20 py-10">
          <span className="text-[16px] text-white/75 font-bold time-font tracking-tight">NO SIGNAL</span>
        </div>
      </div>
    </>
  );
};

export default JammerHud;
