DROP DATABASE Pizzeria;
CREATE DATABASE Pizzeria;
USE Pizzeria;

CREATE TABLE IF NOT EXISTS cliente (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    telefono VARCHAR(15) NOT NULL,
    direccion VARCHAR(150) NOT NULL
);

CREATE TABLE IF NOT EXISTS metodo_pago (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL
);

CREATE TABLE IF NOT EXISTS pedido (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    fecha_recogida DATETIME NOT NULL,
    total DECIMAL(10, 2) NOT NULL,
    cliente_id INT UNSIGNED NOT NULL,
    metodo_pago_id INT UNSIGNED NOT NULL,
    FOREIGN KEY (cliente_id) REFERENCES cliente (id),
    FOREIGN KEY (metodo_pago_id) REFERENCES metodo_pago (id)
);

CREATE TABLE IF NOT EXISTS factura (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    total DECIMAL(10, 2) NOT NULL,
    fecha DATETIME NOT NULL,
    pedido_id INT UNSIGNED NOT NULL,
    cliente_id INT UNSIGNED NOT NULL,
    FOREIGN KEY (pedido_id) REFERENCES pedido (id),
    FOREIGN KEY (cliente_id) REFERENCES cliente (id)
);

CREATE TABLE IF NOT EXISTS tipo_producto (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL
);

CREATE TABLE IF NOT EXISTS producto (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    tipo_producto_id INT UNSIGNED NOT NULL,
    FOREIGN KEY (tipo_producto_id) REFERENCES tipo_producto (id)
);

CREATE TABLE IF NOT EXISTS presentacion (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL
);

CREATE TABLE IF NOT EXISTS producto_presentacion (
    producto_id INT UNSIGNED NOT NULL,
    presentacion_id INT UNSIGNED NOT NULL,
    precio DECIMAL(10, 2) NOT NULL,
    PRIMARY KEY (producto_id, presentacion_id),
    FOREIGN KEY (producto_id) REFERENCES producto (id),
    FOREIGN KEY (presentacion_id) REFERENCES presentacion (id)
);

CREATE TABLE IF NOT EXISTS combo (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    precio DECIMAL(10, 2) NOT NULL
);

CREATE TABLE IF NOT EXISTS combo_producto (
    combo_id INT UNSIGNED NOT NULL,
    producto_id INT UNSIGNED NOT NULL,
    PRIMARY KEY (combo_id, producto_id),
    FOREIGN KEY (combo_id) REFERENCES combo (id),
    FOREIGN KEY (producto_id) REFERENCES producto (id)
);

CREATE TABLE IF NOT EXISTS detalle_pedido (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    pedido_id INT UNSIGNED NOT NULL,
    cantidad INT NOT NULL,
    FOREIGN KEY (pedido_id) REFERENCES pedido (id)
);

CREATE TABLE IF NOT EXISTS detalle_pedido_producto (
    detalle_id INT UNSIGNED NOT NULL,
    producto_id INT UNSIGNED NOT NULL,
    PRIMARY KEY (detalle_id, producto_id),
    FOREIGN KEY (detalle_id) REFERENCES detalle_pedido (id),
    FOREIGN KEY (producto_id) REFERENCES producto (id)
);

CREATE TABLE IF NOT EXISTS detalle_pedido_combo (
    detalle_id INT UNSIGNED NOT NULL,
    combo_id INT UNSIGNED NOT NULL,
    PRIMARY KEY (detalle_id, combo_id),
    FOREIGN KEY (detalle_id) REFERENCES detalle_pedido (id),
    FOREIGN KEY (combo_id) REFERENCES combo (id)
);

CREATE TABLE IF NOT EXISTS ingrediente (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    stock INT NOT NULL,
    precio DECIMAL(10, 2) NOT NULL
);

CREATE TABLE IF NOT EXISTS ingredientes_extra (
    detalle_id INT UNSIGNED NOT NULL,
    ingrediente_id INT UNSIGNED NOT NULL,
    cantidad INT NOT NULL,
    PRIMARY KEY (detalle_id, ingrediente_id),
    FOREIGN KEY (detalle_id) REFERENCES detalle_pedido (id),
    FOREIGN KEY (ingrediente_id) REFERENCES ingrediente (id)
);