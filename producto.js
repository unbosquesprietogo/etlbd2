$(document).ready(function() {
      // Obtener los datos mediante una petición AJAX al endpoint
      $.ajax({
        url: 'https://apex.oracle.com/pls/apex/pangolin/store/inventory/',
        type: 'GET',
        success: function(response) {
          // Obtener los productos del response JSON
          var products = response.items;

          // Construir las filas de la tabla con los productos
          var tableRows = '';
          for (var i = 0; i < products.length; i++) {
            var product = products[i];
            tableRows += '<tr>';
            tableRows += '<td>' + product.id_producto + '</td>';
            tableRows += '<td>' + product.codigo_barras + '</td>';
            tableRows += '<td>' + product.nombre_producto + '</td>';
            tableRows += '<td>' + product.descripcion + '</td>';
            tableRows += '<td>' + product.precio_unitario + '</td>';
            tableRows += '<td>' + product.cantidad_stock + '</td>';
            tableRows += '</tr>';
          }

          // Insertar las filas en la tabla
          $('#productTableBody').html(tableRows);
        },
        error: function(xhr, status, error) {
          console.log('Error al obtener los productos:', error);
        }
      });

      // Configurar el evento click del botón de búsqueda
      $('#searchButton').click(function() {
        var searchTerm = $('#searchInput').val().toLowerCase();

        // Filtrar los productos por el término de búsqueda en las columnas
        $('#productTableBody tr').filter(function() {
          $(this).toggle($(this).text().toLowerCase().indexOf(searchTerm) > -1);
        });
      });
    });