document.addEventListener("DOMContentLoaded", function() {
    // Verificar si existen token y usuario en el localStorage
    const token = localStorage.getItem("token");
    const usuario = localStorage.getItem("usuario");

    // Obtener referencias a los elementos de la barra de navegación
    const navbarItems = document.getElementById("navbarItems");
    const loginButton = document.getElementById("loginButton");
    const userDropdown = document.getElementById("userDropdown");
    const loggedInUser = document.getElementById("loggedInUser");
    const logoutButton = document.getElementById("logoutButton");

    if (token && usuario) {
      // Mostrar elementos para el usuario logueado
      navbarItems.removeChild(loginButton);
      loggedInUser.textContent = usuario;
      userDropdown.style.display = "block";

      // Agregar evento al botón de cerrar sesión
      logoutButton.addEventListener("click", function() {
        localStorage.removeItem("token");
        localStorage.removeItem("usuario");

        // Redireccionar a la página de inicio de sesión
        window.location.href = "login.html";
      });
    } else {
      // Mostrar el botón de inicio de sesión
      userDropdown.style.display = "none";
      navbarItems.appendChild(loginButton);
    }
  });