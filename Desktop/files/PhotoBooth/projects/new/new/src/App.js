
// src/App.jsx
import Portfolio from './components/Portfolio';
import Project from './components/Project';
import Contact  from './components/Contact';
import { Routes, Route } from "react-router-dom";
import './App.css';

function App() {
  return (
    <>

      <Routes>
        <Route path="/" element={<Portfolio />} />
        <Route path="/projects" element={<Project />} />
        <Route path="/contact" element={<Contact />} />
        <Route path="/contact" element={<Contact />} />
      </Routes>
    </>
  );
}

export default App;
