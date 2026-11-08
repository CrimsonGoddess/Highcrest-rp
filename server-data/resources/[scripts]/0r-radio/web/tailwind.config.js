/** @type {import('tailwindcss').Config} */
export default {
    content: ["./index.html", "./src/**/*.{js,ts,jsx,tsx}"],
    darkMode: "class",
    theme: {
        extend: {
            colors: {
                primary: "var(--color-primary)",
            },
        },
        screens: {
            smdesktop: { max: "1300px" },
        },
    },
    plugins: [],
};
