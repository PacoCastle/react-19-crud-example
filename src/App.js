import logo from './logo.svg';
import './App.css';

function App() {
  return (
    <div className="App">
      <header className="App-header">
        <img src={logo} className="App-logo" alt="logo" />
        <h1>React 19 CRUD Example</h1>
        <p>
          A modern React 19.1.1 application with Docker and GCP deployment.
        </p>
        <a
          className="App-link"
          href="https://github.com/PacoCastle/react-19-crud-example"
          target="_blank"
          rel="noopener noreferrer"
        >
          View on GitHub
        </a>
      </header>
    </div>
  );
}

export default App;
