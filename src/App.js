import React, {useEffect} from 'react';

function App() {
  useEffect(() => {
    window.fetch('http://dftask-6ojqgs.ndev.imdada.cn/health').then(res => console.log(res))
  }, [])
  return (
    <div>
      hello world
    </div>
  );
}

export default App;
