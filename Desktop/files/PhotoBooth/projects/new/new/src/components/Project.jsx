import React, { useState, useEffect } from 'react';
import './Project.css';
import { Link } from "react-router-dom";
import ProfileImage3 from '../assets/25.png';
import ProfileImage4 from '../assets/21.png';
import ProfileImage5 from '../assets/23.png';
function Portfolio() {
  // Scroll-triggered animations for Projects section and its items
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

{/* Projects Section */}
<section id="projects" className="projects animate-on-load">
  <div className="container-5">
    <h1 className="animate-on-load">Projects</h1>
    <div className="project-statement animate-on-load">
    <p>
  Dive into some of my favorite projects each one is a reflection of my creativity, growth, and dedication as a future software engineer. From sleek designs to smart functionality, these works showcase my passion for building meaningful digital experiences.
</p>

    </div>
    <div className="project-list">
      <div className="project-item animate-on-load">
        <h3>Portfolio Website</h3>
        <p>A modern, responsive portfolio website built using HTML, CSS, and JavaScript.</p>
        <div className="code-sample">
          <div className="code-header">
            <span className="circle red"></span>
            <span className="circle yellow"></span>
            <span className="circle green"></span>
            <span className="file-name">index.html</span>
          </div>
          <pre><code className="language-html">
{`<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>My Portfolio</title>
  <link rel="stylesheet" href="port.css">
</head>
<body>
  <h1>Software Engineering Student</h1>
  <p>Passionate about coding and building innovative solutions.</p>
</body>
</html>`}
          </code></pre>
        </div>
      </div>

      <div className="project-item animate-on-load">
        <h3>To-Do List App</h3>
        <p>A simple to-do list application with local storage functionality.</p>
        <div className="code-sample">
          <div className="code-header">
            <span className="circle red"></span>
            <span className="circle yellow"></span>
            <span className="circle green"></span>
            <span className="file-name">script.js</span>
          </div>
          <pre><code className="language-javascript">
{`function addTask() {
  const taskInput = document.getElementById('taskInput');
  const taskList = document.getElementById('taskList');
  if (taskInput.value !== '') {
    const li = document.createElement('li');
    li.textContent = taskInput.value;
    taskList.appendChild(li);
    taskInput.value = '';
  }
}`}
          </code></pre>
        </div>
      </div>

    </div>
  </div>
</section>

{/* GitHub Image Project Section */}
<section className="github-image-section animate-on-load">
  <div className="container-5">
    <h2>Featured GitHub Projects</h2>
    
    <div className="github-image-projects">
      <a href="https://github.com/maki21-me/project-2.git" target="_blank" rel="noopener noreferrer">
        <img src={ProfileImage3} alt="GitHub Project 1" className="project-image-link" />
      </a>

      <a href="https://github.com/maki21-me/project-2.git" target="_blank" rel="noopener noreferrer">
        <img src={ProfileImage4} alt="GitHub Project 2" className="project-image-link" />
      </a>

      <a href="https://github.com/your-username/your-repo-name3" target="_blank" rel="noopener noreferrer">
        <img src={ProfileImage5} alt="GitHub Project 3" className="project-image-link" />
      </a>
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
