    const usuario = localStorage.getItem('usuario');
    const token = localStorage.getItem('token');

if (token) {
  // Realiza el fetch GET al endpoint con el usuario y token
  fetch(`https://apex.oracle.com/pls/apex/pangolin/store/token/${usuario}/${token}`)
    .then(response => response.json())
    .then(data => {
      if (data.items.token === token) {
        // El token es válido, muestra el nombre de usuario en la barra de navegación
        const nombreUsuario = data.items.usuario;
        document.getElementById('nombre-usuario').textContent = nombreUsuario;
        document.getElementById('nombre-usuario').classList.add('dropdown-toggle');
        document.getElementById('nombre-usuario').setAttribute('data-toggle', 'dropdown');
        document.getElementById('nombre-usuario').setAttribute('aria-haspopup', 'true');
        document.getElementById('nombre-usuario').setAttribute('aria-expanded', 'false');
        document.getElementById('nombre-usuario').setAttribute('id', 'dropdownMenuLink');
        document.getElementById('dropdown-menu').classList.add('dropdown-menu');
        document.getElementById('dropdown-menu').setAttribute('aria-labelledby', 'dropdownMenuLink');

        // Agrega el listener al botón "Cerrar sesión"
        document.getElementById('cerrar-sesion').addEventListener('click', () => {
          // Elimina el usuario y token del local storage
          localStorage.removeItem('usuario');
          localStorage.removeItem('token');
          // Redirecciona a la página de inicio de sesión
          window.location.href = 'login.html';
        });
      } else {
        // El token no es válido, muestra el botón de login
        document.getElementById('boton-login').style.display = 'block';
      }
    })
    .catch(error => {
      console.log(error);
      // Error al realizar la solicitud, muestra el botón de login por defecto
      document.getElementById('boton-login').style.display = 'block';
    });
} else {
  // No hay token en el local storage, muestra el botón de login
  document.getElementById('boton-login').style.display = 'block';
  redirigirALogin();
}


function redirigirALogin() {
  window.location.href = 'login.html';
}
