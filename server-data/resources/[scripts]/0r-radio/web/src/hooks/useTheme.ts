import { useEffect, useState } from "react";
import { useNuiEvent } from "./useNuiEvent";

export const useTheme = () => {
    const [theme, setTheme] = useState<string>("theme1");

    useNuiEvent<string>("setTheme", setTheme);

    useEffect(() => {
        document.body.className = theme;
    }, [theme]);

    return { theme, setTheme };
};
