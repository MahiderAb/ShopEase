import React, { useState, useEffect } from 'react';
//import React from 'react';

import './Contact.css';
import { Link } from "react-router-dom";
function Portfolio() {
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

     {/* Contact Section */}
<section id="contact" className="contact animate-on-load">
  <div className="container-4">
    <div className="contact-content">


      {/* Social Media and Contact Info */}
      <div className="social-contact-container">
         <div className="contact-info">
         <h2>Contact Me </h2>
         <p className="mb-2">
        📞 Phone: 
        <a href="tel:+251968327855" className="text-blue-600 hover:underline ml-1">
          +251 968327855
        </a>
      </p>
      
      <p className="mb-2">
        📧 Email: 
        <a href="mailto:meklitanteneh58@gmail.com" className="text-blue-600 hover:underline ml-1">
     meklitanteneh58@gmail.com
        </a>
      </p>
        </div>

        <div className="social-icons">
          <a href="https://github.com/maki21-me" target="_blank" title="GitHub" rel="noopener noreferrer">
            <i className="fab fa-github"></i>
          </a>
          <a href="mailto:meklitanteneh58@gmail.com" title="Email Me">
            <i className="fas fa-envelope"></i>
          </a>
          <a href="https://www.linkedin.com/public-profile/settings?lipi=urn%3Ali%3Apage%3Ad_flagship3_profile_self_edit_contact-info%3BhSw4%2B%2BpVQe6tEu2j2BkG2w%3D%3D" target="_blank" title="LinkedIn" rel="noopener noreferrer">
            <i className="fab fa-linkedin"></i>
          </a>
          <a href=" https://www.instagram.com/meklitemariham/" target="_blank" title="Instagram" rel="noopener noreferrer">
            <i className="fab fa-instagram"></i>
          </a>
        </div>
        
       
      </div>

      <div className="contact-form-container">
        <form
          className="contact-form"
          action="https://formspree.io/f/meklitanteneh58"
          method="POST"
          onSubmit={(e) => {
            e.preventDefault();
            alert('Message Sent!');
          }}
        >
          <input
            type="text"
            name="name"
            placeholder="Name"
            required
          />
          <input
            type="email"
            name="email"
            placeholder="Email"
            required
          />
          <textarea
            name="message"
            placeholder="Message"
            rows="5"
            required
          />
          <button type="submit" className="btn">Send Message</button>
        </form>
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