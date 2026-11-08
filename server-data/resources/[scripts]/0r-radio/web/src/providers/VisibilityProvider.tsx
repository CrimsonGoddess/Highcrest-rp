import React, { createContext, useMemo, useState } from "react";

export interface VisibilityProviderValue {
    setVisible: (visible: boolean) => void;
    visible: boolean;
    setHorizontal: (horizontal: boolean) => void;
    horizontal: boolean;
}

export const VisibilityCtx = createContext<VisibilityProviderValue>({} as VisibilityProviderValue);

export const VisibilityProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
    const [visible, setVisible] = useState(true);

    const value = useMemo(() => {
        return {
            visible,
            setVisible,
        };
    }, [visible]);

    return (
        <VisibilityCtx.Provider value={value}>
            <div style={{ visibility: visible ? "visible" : "hidden" }} className="h-[100vh]">
                {children}
            </div>
        </VisibilityCtx.Provider>
    );
};
