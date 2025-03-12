// Fun Facts About You
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

// DOM Elements
const showFactButton = document.getElementById('showFactButton');
const funFactText = document.getElementById('funFactText');
const menuIcon = document.getElementById('menuIcon');
const navBar = document.getElementById('navBar');

// Event listener for showing a random fun fact
showFactButton.addEventListener('click', () => {
    const randomFact = funFacts[Math.floor(Math.random() * funFacts.length)]; // Pick a random fact
    funFactText.textContent = randomFact; // Display the fact
});

// Event listener for toggling the navigation bar
menuIcon.addEventListener('click', () => {
    navBar.classList.toggle('active'); // Toggle the active class
});