-- Crear secuencia para ID_Cliente
CREATE SEQUENCE seq_cliente_id
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

-- Crear secuencia para ID_Producto
CREATE SEQUENCE seq_producto_id
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

-- Crear secuencia para ID_Factura
CREATE SEQUENCE seq_factura_id
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

-- Crear secuencia para ID_Compra
CREATE SEQUENCE seq_compra_id
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

-- Crear secuencia para Usuario
CREATE SEQUENCE seq_usuario_id
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

-- Crear tabla Clientes
CREATE TABLE Clientes (
    ID_Cliente NUMBER DEFAULT seq_cliente_id.NEXTVAL PRIMARY KEY,
    Identificacion VARCHAR2(50) UNIQUE,
    Nombre VARCHAR2(100),
    Apellido VARCHAR2(100),
    Correo VARCHAR2(100),
    Telefono VARCHAR2(20)
);

-- Crear tabla Productos
CREATE TABLE Productos (
    ID_Producto NUMBER DEFAULT seq_producto_id.NEXTVAL PRIMARY KEY,
    Codigo_Barras VARCHAR2(50) UNIQUE,
    Nombre_Producto VARCHAR2(100),
    Descripcion VARCHAR2(200),
    Precio_Unitario NUMBER,
    Cantidad_Stock NUMBER
);

-- Crear tabla Facturas
CREATE TABLE Facturas (
    ID_Factura NUMBER DEFAULT seq_factura_id.NEXTVAL PRIMARY KEY,
    ID_Cliente NUMBER,
    Fecha DATE,
    Subtotal NUMBER,
    IVA NUMBER,
    Descuento NUMBER,
    Total NUMBER,
    CONSTRAINT fk_factura_cliente FOREIGN KEY (ID_Cliente) REFERENCES Clientes (ID_Cliente)
);

-- Crear tabla Detalle_Factura
CREATE TABLE Detalle_Factura (
    ID_Factura NUMBER,
    ID_Producto NUMBER,
    Cantidad NUMBER,
    Precio_Unitario NUMBER,
    Descuento NUMBER,
    Subtotal NUMBER,
    CONSTRAINT pk_detalle_factura PRIMARY KEY (ID_Factura, ID_Producto),
    CONSTRAINT fk_detalle_factura_factura FOREIGN KEY (ID_Factura) REFERENCES Facturas (ID_Factura),
    CONSTRAINT fk_detalle_factura_producto FOREIGN KEY (ID_Producto) REFERENCES Productos (ID_Producto)
);

-- Crear tabla Compras
CREATE TABLE Compras (
    ID_Compra NUMBER,
    Identificacion VARCHAR2(50),
    Nombre VARCHAR2(100),
    Apellido VARCHAR2(100),
    Correo VARCHAR2(100),
    Telefono VARCHAR2(20),
    Codigo_Barras VARCHAR2(50),
    ID_Producto NUMBER,
    Cantidad NUMBER,
    Descuento NUMBER,
    CONSTRAINT uk_compras UNIQUE (Identificacion, Codigo_Barras, ID_Producto, Cantidad)
);

Drop table Temporal_ID_Compra;

CREATE TABLE Temporal_ID_Compra (
    ID_CSV NUMBER,
    ID_Compra NUMBER
)

-- Crear trigger para secuencia en tabla Clientes
CREATE OR REPLACE TRIGGER trg_cliente_id
BEFORE INSERT ON Clientes
FOR EACH ROW
BEGIN
    :NEW.ID_Cliente := seq_cliente_id.NEXTVAL;
END;

-- Crear trigger para secuencia en tabla Productos
CREATE OR REPLACE TRIGGER trg_producto_id
BEFORE INSERT ON Productos
FOR EACH ROW
BEGIN
    :NEW.ID_Producto := seq_producto_id.NEXTVAL;
END;

-- Crear trigger para secuencia en tabla Facturas
CREATE OR REPLACE TRIGGER trg_factura_id
BEFORE INSERT ON Facturas
FOR EACH ROW
BEGIN
    :NEW.ID_Factura := seq_factura_id.NEXTVAL;
END;



BEGIN
  INSERT INTO Compras (ID_Compra, Identificacion, Nombre, Apellido, Correo, Telefono, Codigo_Barras, ID_Producto, Cantidad, Descuento)
  VALUES (:id_compra, :identificacion, :nombre, :apellido, :correo, :telefono, :codigo_Barras, :id_Producto, :cantidad, :descuento);

  status_code := 201; 

EXCEPTION
  WHEN OTHERS THEN
    status_code := 400;
    errmsg := SQLERRM;
END;

truncate table compras;

CREATE OR REPLACE PROCEDURE ActualizarCliente(
  p_Identificacion IN VARCHAR2,
  p_Nombre IN VARCHAR2,
  p_Apellido IN VARCHAR2,
  p_Correo IN VARCHAR2,
  p_Telefono IN VARCHAR2,
  p_result OUT NUMBER,
  p_message OUT VARCHAR2
)
AS
BEGIN
  -- Inicializar variables
  p_result := 200;
  p_message := 'Cliente actualizado exitosamente';

  -- Actualizar cliente existente
  UPDATE Clientes
  SET Nombre = p_Nombre,
      Apellido = p_Apellido,
      Correo = p_Correo,
      Telefono = p_Telefono
  WHERE Identificacion = p_Identificacion;
  
  IF SQL%ROWCOUNT = 0 THEN
    -- No se encontró un cliente con la identificación especificada, insertar uno nuevo
    BEGIN
      INSERT INTO Clientes (Identificacion, Nombre, Apellido, Correo, Telefono)
      VALUES (p_Identificacion, p_Nombre, p_Apellido, p_Correo, p_Telefono);
    EXCEPTION
      WHEN OTHERS THEN
        p_result := 400;
        p_message := 'Error al insertar el nuevo cliente: ' || SQLERRM;
    END;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    p_result := 400;
    p_message := 'Error al actualizar el cliente: ' || SQLERRM;
END;




CREATE OR REPLACE PROCEDURE LlenarTablas(
  p_status_code OUT NUMBER,
  p_error_message OUT VARCHAR2
)
AS
BEGIN
  p_status_code := 200;
  p_error_message := 'Proceso completado exitosamente';

  -- Actualizar datos del cliente si existe
  FOR c IN (SELECT DISTINCT Identificacion, nombre, apellido, correo, telefono
            FROM Compras)
  LOOP
    ActualizarCliente(c.Identificacion, c.nombre, c.apellido, c.correo, c.telefono, p_status_code, p_error_message);
    IF p_status_code <> 200 THEN
      -- Si hay un error al actualizar el cliente, asigna el código de error y el mensaje
      p_status_code := 400;
      p_error_message := 'Error al actualizar el cliente ' || c.Identificacion || ': ' || p_error_message;
      RETURN;
    END IF;
  END LOOP;

  -- Calcular subtotal, IVA, total y descuento para cada factura
  FOR f IN (SELECT DISTINCT ID_Compra, Identificacion
            FROM Compras)
  LOOP
    -- Calcular subtotal
    DECLARE
      v_subtotal NUMBER;
    BEGIN
      SELECT SUM(P.Precio_Unitario * C.Cantidad * (1 - C.Descuento / 100))
      INTO v_subtotal
      FROM Compras C
      JOIN Productos P ON C.ID_Producto = P.ID_Producto
      WHERE C.ID_Compra = f.ID_Compra AND C.Identificacion = f.Identificacion;
    
      -- Insertar factura
      DECLARE
        v_factura_id NUMBER;
      BEGIN
        INSERT INTO Facturas (ID_Cliente, Fecha, Subtotal, IVA, Descuento, Total)
        VALUES ((SELECT ID_Cliente FROM Clientes WHERE Identificacion = f.Identificacion), SYSDATE, v_subtotal, v_subtotal * 0.19, 0, v_subtotal * 1.19)
        RETURNING ID_Factura INTO v_factura_id;
    
        -- Insertar detalle de factura
        INSERT INTO Detalle_Factura (ID_Factura, ID_Producto, Cantidad, Precio_Unitario, Descuento, Subtotal)
        SELECT v_factura_id, C.ID_Producto, C.Cantidad, P.Precio_Unitario, C.Descuento, C.Cantidad * P.Precio_Unitario * (1 - C.Descuento / 100)
        FROM Compras C
        JOIN Productos P ON C.ID_Producto = P.ID_Producto
        WHERE C.ID_Compra = f.ID_Compra AND C.Identificacion = f.Identificacion;
      EXCEPTION
        WHEN OTHERS THEN
          p_status_code := 400;
          p_error_message := 'Error al insertar el detalle de factura: ' || SQLERRM;
          RETURN;
      END;
    EXCEPTION
      WHEN OTHERS THEN
        p_status_code := 400;
        p_error_message := 'Error al calcular el subtotal: ' || SQLERRM;
        RETURN;
    END;
  END LOOP;
    DELETE FROM COMPRAS;
EXCEPTION
  WHEN OTHERS THEN
    p_status_code := 400;
    p_error_message := 'Error en el procedimiento: ' || SQLERRM;
    RETURN;
END;

SELECT * FROM COMPRAS;
truncate table facturas;

delete from compras where id_compra = 1;

DECLARE
    errmsg VARCHAR2(200);
    status_code NUMBER;
BEGIN
    LlenarTablas(status_code,errmsg);
    DBMS_OUTPUT.PUT_LINE('Código de estado: ' || status_code);
    DBMS_OUTPUT.PUT_LINE('Mensaje de error: ' || errmsg);
END;

SELECT * FROM facturas;

SELECT * FROM DETALLE_FACTURA;

INSERT INTO Productos (Codigo_Barras, Nombre_Producto, Descripcion, Precio_Unitario, Cantidad_Stock) VALUES ('1234567890123', 'Leche', 'Leche descremada 1L', 2.5, 50);
INSERT INTO Productos (Codigo_Barras, Nombre_Producto, Descripcion, Precio_Unitario, Cantidad_Stock) VALUES ('2345678901234', 'Arroz', 'Arroz blanco 1kg', 1.99, 100);
INSERT INTO Productos (Codigo_Barras, Nombre_Producto, Descripcion, Precio_Unitario, Cantidad_Stock) VALUES ('3456789012345', 'Frijoles', 'Frijoles negros 500g', 0.99, 80);
INSERT INTO Productos (Codigo_Barras, Nombre_Producto, Descripcion, Precio_Unitario, Cantidad_Stock) VALUES ('4567890123456', 'Pan', 'Pan blanco 400g', 1.5, 120);
INSERT INTO Productos (Codigo_Barras, Nombre_Producto, Descripcion, Precio_Unitario, Cantidad_Stock) VALUES ('5678901234567', 'Azúcar', 'Azúcar blanca 1kg', 1.75, 60);
INSERT INTO Productos (Codigo_Barras, Nombre_Producto, Descripcion, Precio_Unitario, Cantidad_Stock) VALUES ('6789012345678', 'Sal', 'Sal de mesa 500g', 0.75, 90);
INSERT INTO Productos (Codigo_Barras, Nombre_Producto, Descripcion, Precio_Unitario, Cantidad_Stock) VALUES ('7890123456789', 'Aceite', 'Aceite de oliva 500ml', 4.99, 30);
INSERT INTO Productos (Codigo_Barras, Nombre_Producto, Descripcion, Precio_Unitario, Cantidad_Stock) VALUES ('8901234567890', 'Pasta', 'Pasta de trigo 500g', 1.25, 70);
INSERT INTO Productos (Codigo_Barras, Nombre_Producto, Descripcion, Precio_Unitario, Cantidad_Stock) VALUES ('9012345678901', 'Café', 'Café molido 250g', 3.5, 40);
INSERT INTO Productos (Codigo_Barras, Nombre_Producto, Descripcion, Precio_Unitario, Cantidad_Stock) VALUES ('0123456789012', 'Jabón', 'Jabón de tocador 100g', 1.99, 100);
INSERT INTO Productos (Codigo_Barras, Nombre_Producto, Descripcion, Precio_Unitario, Cantidad_Stock) VALUES ('1234509876543', 'Detergente', 'Detergente líquido 1L', 3.99, 50);
INSERT INTO Productos (Codigo_Barras, Nombre_Producto, Descripcion, Precio_Unitario, Cantidad_Stock) VALUES ('2345610987654', 'Shampoo', 'Shampoo suave 250ml', 2.99, 60);
INSERT INTO Productos (Codigo_Barras, Nombre_Producto, Descripcion, Precio_Unitario, Cantidad_Stock) VALUES ('3456721098765', 'Crema dental', 'Crema dental 100g', 1.25, 80);
INSERT INTO Productos (Codigo_Barras, Nombre_Producto, Descripcion, Precio_Unitario, Cantidad_Stock) VALUES ('4567832109876', 'Papel higiénico', 'Papel higiénico 4 rollos', 2.75, 40);
INSERT INTO Productos (Codigo_Barras, Nombre_Producto, Descripcion, Precio_Unitario, Cantidad_Stock) VALUES ('5678943210987', 'Jugo', 'Jugo de naranja 1L', 2.25, 70);
INSERT INTO Productos (Codigo_Barras, Nombre_Producto, Descripcion, Precio_Unitario, Cantidad_Stock) VALUES ('6789054321098', 'Galletas', 'Galletas de chocolate 200g', 1.99, 90);
INSERT INTO Productos (Codigo_Barras, Nombre_Producto, Descripcion, Precio_Unitario, Cantidad_Stock) VALUES ('7890165432109', 'Yogurt', 'Yogurt natural 250ml', 1.5, 120);
INSERT INTO Productos (Codigo_Barras, Nombre_Producto, Descripcion, Precio_Unitario, Cantidad_Stock) VALUES ('8901276543210', 'Cereal', 'Cereal de avena 500g', 3.99, 60);
INSERT INTO Productos (Codigo_Barras, Nombre_Producto, Descripcion, Precio_Unitario, Cantidad_Stock) VALUES ('9012387654321', 'Harina', 'Harina de trigo 1kg', 1.99, 80);
INSERT INTO Productos (Codigo_Barras, Nombre_Producto, Descripcion, Precio_Unitario, Cantidad_Stock) VALUES ('0123498765432', 'Tomate', 'Tomate fresco', 0.99, 100);

drop view Vista_Factura;

CREATE VIEW Vista_Factura AS
SELECT f.ID_Factura,
       c.ID_Cliente,
       c.Nombre AS Nombre_Cliente,
       c.Apellido AS Apellido_Cliente,
       c.Correo AS Correo_Cliente,
       c.Telefono AS Telefono_Cliente,
       c.Identificacion AS Identificacion_Cliente,
       f.Fecha,
       f.Subtotal,
       f.IVA,
       f.Descuento,
       f.Total,
       p.ID_Producto,
       p.Nombre_Producto,
       p.Descripcion,
       p.Precio_Unitario,
       df.Cantidad,
       df.Descuento AS Descuento_Producto,
       df.Subtotal AS Subtotal_Producto
FROM Facturas f
JOIN Clientes c ON f.ID_Cliente = c.ID_Cliente
JOIN Detalle_Factura df ON f.ID_Factura = df.ID_Factura
JOIN Productos p ON df.ID_Producto = p.ID_Producto;


drop table usuarios;

CREATE TABLE usuarios (
  id NUMBER,
  nombre VARCHAR2(50),
  contrasena VARCHAR2(100),
  CONSTRAINT usuarios_pk PRIMARY KEY (id)
);

CREATE UNIQUE INDEX index_usuario ON usuarios (nombre);

-- Crear trigger para secuencia en tabla Usuarios
CREATE OR REPLACE TRIGGER trg_usuario_id
BEFORE INSERT ON usuarios
FOR EACH ROW
BEGIN
    :NEW.id := seq_usuario_id.NEXTVAL;
END;

drop table tokens;

CREATE TABLE Tokens (
  usuario_id NUMBER,
  token VARCHAR2(38) NOT NULL PRIMARY KEY,
  fecha_generacion DATE NOT NULL
);

CREATE OR REPLACE PROCEDURE validar_usuario_contrasena(
    p_usuario IN usuarios.nombre%TYPE,
    p_contrasena IN usuarios.contrasena%TYPE,
    p_status_code OUT NUMBER,
    p_error_message OUT VARCHAR2,
    p_token OUT VARCHAR2
)
AS
  l_token VARCHAR2(38);
  p_usuario_id NUMBER;
BEGIN
  -- Verificar si el usuario y contraseña son válidos
  SELECT COUNT(*) INTO l_token
  FROM usuarios
  WHERE nombre = p_usuario
    AND contrasena = p_contrasena;

  -- Si las credenciales son válidas, generar un token y almacenarlo en la tabla "Tokens"
  IF l_token = 1 THEN
    l_token := SYS_GUID();

    SELECT id INTO p_usuario_id
    FROM usuarios
    WHERE nombre = p_usuario
    AND contrasena = p_contrasena;

    INSERT INTO Tokens (usuario_id, token, fecha_generacion)
    VALUES (p_usuario_id, l_token, SYSDATE);

    COMMIT;
    p_status_code := 200; -- Éxito
    p_error_message := 'Credenciales válidas. Token generado.';
    p_token := l_token; -- Devolver el UUID generado
  ELSE
    p_status_code := 400; -- Bad Request
    p_error_message := 'Credenciales inválidas. Usuario y/o contraseña incorrectos.';
    p_token := NULL; -- No se genera token en caso de fallo
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    p_status_code := 400; -- Bad Request
    p_error_message := 'Error al validar las credenciales. ' || SQLERRM;
    p_token := NULL; -- No se genera token en caso de fallo
END;

INSERT INTO usuarios (nombre,contrasena) VALUES ('admin','123456');


select * from vista_factura order by id_factura;