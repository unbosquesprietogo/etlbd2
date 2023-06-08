document.addEventListener("DOMContentLoaded", function() {
    const token = localStorage.getItem("token");
    const usuario = localStorage.getItem("usuario");
  
    if (token && usuario) {
      // Construir la URL del endpoint con el usuario y el token
      const url = `https://apex.oracle.com/pls/apex/pangolin/store/token/${usuario}/${token}`;
  
      // Realizar la petición GET usando fetch
      fetch(url)
        .then(response => response.json())
        .then(data => {
          if (data.items && data.items.length > 0) {
            // El objeto "items" contiene elementos, no hacer nada
          } else {
            // El objeto "items" está vacío, redirigir a login.html
            window.location.href = "login.html";
          }
        })
        .catch(error => {
          console.error("Error al realizar la petición:", error);
        });
    }
  });