$(document).ready(function() {
    // Obtener referencias a los elementos del formulario
    var usernameInput = $('#username');
    var passwordInput = $('#password');
    var loginButton = $('.btn-login');
  
    // Manejar el evento de clic en el botón de inicio de sesión
    loginButton.click(function() {
      // Obtener los valores de usuario y contraseña
      var username = usernameInput.val();
      var password = passwordInput.val();
  
      // Crear el objeto JSON con los datos de inicio de sesión
      var data = {
        "usuario": username,
        "contrasena": password
      };
  
      // Realizar la solicitud POST al servidor
      fetch('https://apex.oracle.com/pls/apex/pangolin/store/login/', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(data)
      })
      .then(function(response) {
        if (response.status === 200) {
          return response.json();
        } else {
          throw new Error('Credenciales incorrectas');
        }
      })
      .then(function(data) {
        // Guardar el token y el usuario en el localStorage
        localStorage.setItem('token', data.token);
        localStorage.setItem('usuario', username);
        // Redirigir al usuario al index.html
        window.location.href = 'index.html';
      })
      .catch(function(error) {
        // Mostrar mensaje de error
        alert(error.message);
      });
    });
  });