    let csvData = [];
    let successData = [];
    let errorData = [];

    function processFile() {
      const fileInput = document.getElementById('csvFile');
      const file = fileInput.files[0];
      const reader = new FileReader();

      reader.onload = function (e) {
        const contents = e.target.result;
        parseCSV(contents);
        displayTable();
      };

      reader.readAsText(file);
    }

    function parseCSV(csv) {
      const rows = csv.split('\n');
      const headers = rows[0].split(',');

      csvData = [];

      for (let i = 1; i < rows.length; i++) {
        // Verificar si la última línea está vacía
        if (i === rows.length - 1 && rows[i].trim() === '') {
          break;
        }

        const rowData = rows[i].split(',');
        if (rowData.length === headers.length) {
          const obj = {};
          for (let j = 0; j < headers.length; j++) {
            const key = headers[j].trim();
            let value = rowData[j].trim();

            // Limpiar caracteres no deseados en el valor
            value = value.replace(/\r/g, '').replace(/:/g, '');

            obj[key] = isNaN(value) ? value : parseInt(value, 10);
          }
          csvData.push(obj);
        }
      }
    }

    function displayTable() {
      const tableHeaders = document.getElementById('tableHeaders');
      const tableBody = document.getElementById('tableBody');
      const headers = Object.keys(csvData[0]);

      tableHeaders.innerHTML = '';
      tableBody.innerHTML = '';

      headers.forEach(header => {
        const th = document.createElement('th');
        th.textContent = header;
        tableHeaders.appendChild(th);
      });

      csvData.forEach(row => {
        const tr = document.createElement('tr');
        headers.forEach(header => {
          const td = document.createElement('td');
          td.textContent = row[header];
          tr.appendChild(td);
        });
        tableBody.appendChild(tr);
      });

      document.getElementById('tableContainer').style.display = 'block';
    }

    function saveToJson() {
      const jsonData = JSON.stringify(csvData, null, 2);
      const a = document.createElement('a');
      const file = new Blob([jsonData], { type: 'application/json' });
      a.href = URL.createObjectURL(file);
      a.download = 'data.json';
      a.click();
    }

    function addData(type) {

      const url="";

      if (type === 'compras'){
        url = 'https://apex.oracle.com/pls/apex/pangolin/store/purchase/'; 
      }
      else if(type === 'productos'){
        url = 'https://apex.oracle.com/pls/apex/pangolin/store/inventory/';
      }

      
      const totalData = csvData.length;
      let processedData = 0;

      successData = [];
      errorData = [];

      function processNextData() {
        if (processedData < totalData) {
          const data = csvData[processedData];
          const jsonData = JSON.stringify(data);

          $.ajax({
            url: url,
            type: 'POST',
            data: jsonData,
            contentType: 'application/json',
            success: function (response) {
              console.log('Datos agregados exitosamente:', response);
              successData.push(data);
              processedData++;
              processNextData();
            },
            error: function (xhr, status, error) {
              console.error('Error al agregar los datos:', error);
              errorData.push(data);
              processedData++;
              processNextData();
            }
          });
        } else {
          displayResultTables();
        }
      }

      function displayResultTables() {
        const successTableHeaders = document.getElementById('successTableHeaders');
        const successTableBody = document.getElementById('successTableBody');
        const errorTableHeaders = document.getElementById('errorTableHeaders');
        const errorTableBody = document.getElementById('errorTableBody');
        const headers = Object.keys(csvData[0]);

        successTableHeaders.innerHTML = '';
        successTableBody.innerHTML = '';
        errorTableHeaders.innerHTML = '';
        errorTableBody.innerHTML = '';

        headers.forEach(header => {
          const th1 = document.createElement('th');
          th1.textContent = header;
          successTableHeaders.appendChild(th1);

          const th2 = document.createElement('th');
          th2.textContent = header;
          errorTableHeaders.appendChild(th2);
        });

        successData.forEach(row => {
          const tr = document.createElement('tr');
          headers.forEach(header => {
            const td = document.createElement('td');
            td.textContent = row[header];
            tr.appendChild(td);
          });
          successTableBody.appendChild(tr);
        });

        errorData.forEach(row => {
          const tr = document.createElement('tr');
          headers.forEach(header => {
            const td = document.createElement('td');
            td.textContent = row[header];
            tr.appendChild(td);
          });
          errorTableBody.appendChild(tr);
        });

        document.getElementById('statusMessage').style.display = 'block';
      }

      processNextData();
    }

    function transform() {
      const url = 'https://apex.oracle.com/pls/apex/pangolin/store/transformation/';

      $.ajax({
        url: url,
        type: 'GET',
        success: function (response) {
          if (response === 200) {
            alert('Transformación correcta');
          }
        },
        error: function (xhr, status, error) {
          alert('Error en la transformación:', error);
        }
      });
    }