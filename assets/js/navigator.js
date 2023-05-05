(() => {
  const menu = document.querySelector(".navbar-collapse");
  const menuButton = document.querySelector(".navbar-mobile--icon");

  const toggleMenu = () => {
    menu.classList.toggle('active');
    menuButton.classList.toggle('active')
  }

  menuButton.addEventListener('click', toggleMenu)
})();
