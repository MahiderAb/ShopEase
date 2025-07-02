import React, { useState, useEffect } from 'react';
import './port.css';
import { Link } from "react-router-dom";
import ProfileImage from '../assets/IMG_20241106_011726_311-modified.png';
import ProfileImage2 from '../assets/5.png';
function Portfolio() {
  const [typedText, setTypedText] = useState('');
  const [typingIndex, setTypingIndex] = useState(0);
  const [isDeleting, setIsDeleting] = useState(false);
  const [loopNum, setLoopNum] = useState(0);
  const [isPaused, setIsPaused] = useState(false);
  const [funFact, setFunFact] = useState('');

  const typingTextArray = ["Hi, I'm Meklit Anteneh"];
  const funFacts = [
    "I had no idea what coding meant until I dove into it.",
    "I love watching podcasts related to coding in my free time.",
    "My favorite programming language is JavaScript because of its versatility.",
    "I’m a big fan of sci-fi movies and books.",
    "I started coding because I wanted to solve societal problems.",
    "I’m passionate about writing journals and documenting my thoughts and experiences.",
    "I’m always curious about how things work under the hood.",
    "I believe technology can solve some of the world’s biggest problems."
  ];

  // Typing Effect
  useEffect(() => {
    let typingInterval;
    if (!isPaused) {
      typingInterval = setTimeout(() => {
        const fullText = typingTextArray[loopNum % typingTextArray.length];
        if (!isDeleting) {
          setTypedText(fullText.substring(0, typingIndex + 1));
          setTypingIndex(prev => prev + 1);

          if (typingIndex + 1 === fullText.length) {
            setIsPaused(true);
            setTimeout(() => {
              setIsDeleting(true);
              setIsPaused(false);
            }, 1000);
          }
        } else {
          setTypedText(fullText.substring(0, typingIndex - 1));
          setTypingIndex(prev => prev - 1);

          if (typingIndex - 1 === 0) {
            setIsDeleting(false);
            setLoopNum(prev => prev + 1);
          }
        }
      }, isDeleting ? 50 : 100);
    }
    return () => clearTimeout(typingInterval);
  }, [typedText, typingIndex, isDeleting, isPaused, loopNum]);

  // Animate on Load
  useEffect(() => {
    const els = Array.from(document.querySelectorAll('.animate-on-load'));
    els.forEach((el, i) => {
      el.style.animationDelay = `${i * 0.2}s`;
    });
    requestAnimationFrame(() => {
      document.body.classList.add('loaded');
    });
  }, []);

  // Menu + Theme Toggle Logic
  useEffect(() => {
    const menuIcon = document.getElementById('menuIcon');
    const navBar = document.getElementById('navBar');
    const themeToggle = document.getElementById('theme-toggle');
    const body = document.body;

    const savedTheme = localStorage.getItem('theme');
    if (savedTheme) {
      body.setAttribute('data-theme', savedTheme);
      if (themeToggle) themeToggle.textContent = savedTheme === 'dark' ? '☀️' : '🌙';
    }

    const toggleMenu = () => navBar.classList.toggle('active');
    const toggleTheme = () => {
      const currentTheme = body.getAttribute('data-theme');
      const newTheme = currentTheme === 'dark' ? 'light' : 'dark';
      body.setAttribute('data-theme', newTheme);
      localStorage.setItem('theme', newTheme);
      if (themeToggle) themeToggle.textContent = newTheme === 'dark' ? '☀️' : '🌙';
    };

    menuIcon?.addEventListener('click', toggleMenu);
    themeToggle?.addEventListener('click', toggleTheme);

    const navLinks = document.querySelectorAll('#navBar ul li a');
    navLinks.forEach(link => {
      link.addEventListener('click', () => navBar.classList.remove('active'));
    });

    return () => {
      menuIcon?.removeEventListener('click', toggleMenu);
      themeToggle?.removeEventListener('click', toggleTheme);
    };
  }, []);

  // Show Fun Fact
  const showRandomFact = () => {
    const randomFact = funFacts[Math.floor(Math.random() * funFacts.length)];
    setFunFact(randomFact);
  };

  useEffect(() => {
    const factButton = document.getElementById('showFactButton');
    factButton?.addEventListener('click', showRandomFact);
    return () => {
      factButton?.removeEventListener('click', showRandomFact);
    };
  }, []);

  return (
    <>
      <header className="animate-on-load">
        <div className="container">
        <h1 className="logo-motion"><span>Meklit.</span></h1>
          <div id="menuIcon">&#9776;</div>
          <nav id="navBar">
            <ul>
            <li><Link to="/">Home</Link></li>
            <li><Link to="/projects">Projects</Link></li>
            <li><Link to="/contact">Contact</Link></li>
            </ul>
          </nav>
        </div>
      </header>

      <section id="home" className="hero animate-on-load">
        <div className="container">
          <div className="hero-image">
          <div className='logo-motion'></div>
            <img src={ProfileImage} alt="Profile" />
          </div>
          <div className="hero-content">
            <p className="typing-line">
              <span id="typing-effect">{typedText}</span>
              <span className="cursor">|</span>
            </p>
            <p>
            A builder of ideas, a learner by nature, and a woman determined to make her mark in the tech world. What started as curiosity has become a journey of growth, resilience, and purpose.
            </p>
          </div>
        </div>
      </section>

      <section id="about" className="about animate-on-load">
  <div className="container_2">
    <h2>About Me</h2>
    <div className="about-wrapper">
      <div className="about-image">
        <div className='logo-motion'></div>
        <img src={ProfileImage2} alt="Profile" />
      </div>
      <div className="about-description">
        <p>
          Growing up, I never imagined I’d study Software Engineering I always thought I’d pursue a career in medicine. But life has a funny way of surprising us. When I first joined the software department, I felt overwhelmed and uncertain. I believed I couldn’t do anything because everything seemed so difficult.
        </p>
        <p>
          Then one day, I remembered something from my childhood. During games of hide-and-seek, while everyone else hid behind walls or under tables, I used to climb up into trees completely unexpected and totally creative. That memory reminded me that I’ve always had a unique way of seeing the world. I realized that maybe, just maybe, Software Engineering was a perfect fit for me after all.
        </p>
        <p>
          With that spark, I started learning to code from scratch  HTML first, then CSS, and eventually JavaScript. I built projects as I learned, which helped me grow quickly. Now, I’m confident in HTML, CSS, and JavaScript, and I’m currently diving into React. The more I explore the tech world, the more I find it fascinating, empowering, and full of possibilities.
        </p>
      </div>
    </div>
  </div>
</section>


      <div className="fun-facts">
        <h3>Fun Facts About Me</h3>
        <button id="showFactButton">Show a Fun Fact</button>
        <p id="funFactText" className="fun-fact-text">{funFact}</p>
      </div>

      
         {/* Skills Section */}
         <section id="skills" className="about animate-on-load">
        <div className="container-3">
          <h3>Skills: Mastering the Tools of Web Development</h3>
          <div className="skill-widgets">
            <div className="skill-widget" draggable>
              <div className="skill-info">
                <h3>HTML</h3>
                <p>Structured and semantic web pages.</p>
              </div>
              <div className="skill-progress">
                <div className="progress-bar" style={{ width: '90%' }}></div>
              </div>
              <div className="skill-proficiency">90%</div>
            </div>

            <div className="skill-widget" draggable>
              <div className="skill-info">
                <h3>CSS</h3>
                <p>Styling and responsive design.</p>
              </div>
              <div className="skill-progress">
                <div className="progress-bar" style={{ width: '80%' }}></div>
              </div>
              <div className="skill-proficiency">80%</div>
            </div>

            <div className="skill-widget" draggable>
              <div className="skill-info">
                <h3>JavaScript</h3>
                <p>Interactive and dynamic web applications.</p>
              </div>
              <div className="skill-progress">
                <div className="progress-bar" style={{ width: '60%' }}></div>
              </div>
              <div className="skill-proficiency">60%</div>
            </div>

            <div className="skill-widget" draggable>
              <div className="skill-info">
                <h3>Reactjs</h3>
                <p>Component-based, Declarative, Efficient, Interactive.</p>
              </div>
              <div className="skill-progress">
                <div className="progress-bar" style={{ width: '55%' }}></div>
              </div>
              <div className="skill-proficiency">55%</div>
            </div>
          </div>
        </div>
      </section>
  {/* Footer */}
  <footer>
        <p>&copy; 2025 Meklit Anteneh. All rights reserved.</p>
      </footer>
    </>
  );
}

export default Portfolio;
