import { FC, useEffect, useState } from "react";
import "./index.css";
import { ImSpinner7 } from "react-icons/im";
import { fetchNui } from "../../utils/fetchNui";

const BootAnimation: FC = () => {
  const [canUse, setCanUse] = useState<boolean>(false);
  const [hidden, setHidden] = useState<boolean>(false);
  const [percentage, setPercentage] = useState<number>(1);

  useEffect(() => {
    fetchNui<boolean>("getHasBootAnimation").then((data) => {
      setCanUse(!data);
      setHidden(data);
    });
  }, []);

  useEffect(() => {
    if (canUse) {
      if (percentage < 100) {
        const interval = setInterval(() => {
          setPercentage((prevPercentage) => prevPercentage + 1);
        }, 5);
        return () => clearInterval(interval);
      } else {
        setHidden(true);
        setCanUse(false);
      }
    }
  }, [percentage, canUse]);

  return (
    <>
      {!hidden && (
        <div className="bg-gray-900 h-full absolute w-full flex flex-col items-center justify-center z-[999]">
          <span className="text-orange-100 text-sm mb-2">Loading...</span>
          <ImSpinner7 size={32} className="animate-spin text-orange-100 mb-2" />
          <div>
            <span className="font-medium text-orange-100">%{percentage}</span>
          </div>
        </div>
      )}
    </>
  );
};

export default BootAnimation;
