$(document).ready(function() {
  // Obtener los datos mediante una petición fetch al endpoint
  fetch('https://apex.oracle.com/pls/apex/pangolin/store/inventory/')
    .then(response => response.json())
    .then(data => {
      // Obtener los productos del response JSON
      var products = data.items;

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
    })
    .catch(error => {
      console.log('Error al obtener los productos:', error);
    });

  // Configurar el evento click del botón de búsqueda
  $('#searchButton').click(function() {
    var searchTerm = $('#searchInput').val().toLowerCase();
    var selectedColumn = $('#columnSelect').val();
    console.log(searchTerm);
    console.log(selectedColumn);

    // Filtrar los productos por el término de búsqueda en la columna seleccionada
    $('#productTableBody tr').filter(function() {
      var columnText = $(this).find('td').eq(selectedColumn).text().toLowerCase();
      $(this).toggle(columnText.indexOf(searchTerm) > -1);
    });
  });
});