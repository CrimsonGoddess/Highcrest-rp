import classNames from "classnames";
import { ButtonHTMLAttributes, FC } from "react";

type ElementProps = ButtonHTMLAttributes<HTMLButtonElement> & {
  onClick?: () => void;
  rounded?: "none" | "sm" | "md" | "lg" | "xl" | "2xl" | "3xl" | "full";
};

const Button: FC<ElementProps> = ({ children, rounded, onClick, ...props }) => {
  const commonClasses =
    "absolute hover:bg-sky-200/10 flex items-center justify-center outline-none";
  const buttonClasses = classNames(commonClasses, {
    "rounded-none": rounded === "none",
    "rounded-sm": rounded === "sm",
    "rounded-md": rounded === "md",
    "rounded-lg": rounded === "lg",
    "rounded-xl": rounded === "xl",
    "rounded-2xl": rounded === "2xl",
    "rounded-3xl": rounded === "3xl",
    "rounded-full": rounded === "full",
  });

  return (
    <button className={buttonClasses} onClick={onClick} {...props}>
      {children}
    </button>
  );
};

export default Button;
