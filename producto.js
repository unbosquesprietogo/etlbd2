  $(document).ready(function() {
    // Realizar la petición AJAX al endpoint de productos
    $.ajax({
      url: 'endpoint_de_productos',
      type: 'GET',
      dataType: 'json',
      success: function(data) {
        if (data && data.length > 0) {
          // Construir las filas de la tabla con los datos de los productos
          var tableRows = '';
          for (var i = 0; i < data.length; i++) {
            var product = data[i];
            var row = '<tr>' +
              '<td>' + product.id_producto + '</td>' +
              '<td>' + product.codigo_barras + '</td>' +
              '<td>' + product.nombre_producto + '</td>' +
              '<td>' + product.descripcion + '</td>' +
              '<td>' + product.precio_unitario + '</td>' +
              '<td>' + product.cantidad_stock + '</td>' +
              '</tr>';
            tableRows += row;
          }
          $('#productTableBody').html(tableRows);
        } else {
          console.log('No se encontraron productos');
        }
      },
      error: function(jqXHR, textStatus, errorThrown) {
        console.log('Error al obtener los productos:', errorThrown);
      }
    });

    // Configurar el evento click del botón de búsqueda
    $('#searchButton').click(function() {
      var searchTerm = $('#searchInput').val().toLowerCase();
      var searchColumn = $('#searchColumn').val();

      // Filtrar los productos por el término de búsqueda en la columna seleccionada
      $('#productTableBody tr').filter(function() {
        var columnText = $(this).find('td:eq(' + searchColumn + ')').text().toLowerCase();
        $(this).toggle(columnText.indexOf(searchTerm) > -1);
      });
    });
  });
