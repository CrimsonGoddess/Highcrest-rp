import { useGlobalState } from "./providers/StateProvider";
import Hacking from "./pages/hacking";

function App() {
  const globalState = useGlobalState();

  function getTheCurrentPage() {
    if (globalState.currentPage == "hacking") {
      return <Hacking {...globalState.pageData}/>
    }

    return <></>
  }

  return (
    <div className="h-screen w-screen flex items-center justify-center" style={{"background": "rgba(0, 0, 0, 0.4)"}}>
        {getTheCurrentPage()}
    </div>
  );
}

export default App;
