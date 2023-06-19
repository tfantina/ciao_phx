(() => {
  const menu = document.querySelector(".navbar-collapse")
  const menuButton = document.querySelector(".navbar-mobile--icon")
  const menuButtons = document.getElementsByClassName('mobile-nav--btn')

  const toggleMenu = () => {
    menu.classList.toggle('active')
    menuButton.classList.toggle('active')
  }

  const showPanel = (evt) => {
    const panel_name = evt.target.dataset.panel
    const panel = document.getElementById(panel_name)
    if (!panel) {
      return false;
    }

    panel.classList.contains("open") ? panel.classList.remove("open") : panel.classList.add("open")

    
  }

  menuButton.addEventListener('click', toggleMenu)


  for (btn of menuButtons) {
    btn.addEventListener('click', showPanel) 
  }
})();
