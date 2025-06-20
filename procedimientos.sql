--1.`ps_add_pizza_con_ingredientes` Crea un procedimiento que inserte una nueva pizza en la tabla `pizza` junto con sus ingredientes en `pizza_ingrediente`.
--Parámetros de entrada: `p_nombre_pizza`, `p_precio`, lista de `p_ids_ingredientes`.
--Debe recorrer la lista de ingredientes (cursor o ciclo) y hacer los inserts correspondients.

DELIMITER $$

DROP PROCEDURE IF EXISTS ps_add_pizza_con_ingredientes $$

CREATE PROCEDURE ps_add_pizza_con_ingredientes (
    IN p_nombre_pizza VARCHAR(100),
    IN p_precio DECIMAL(10,2)
)
BEGIN 
    DECLARE nuevo_id_pizza INT;

    INSERT INTO pizza (nombre, precio)
    VALUES (p_nombre_pizza, p_precio);

    SET nuevo_id_pizza = LAST_INSERT_ID();

    SELECT CONCAT('Pizza "', p_nombre_pizza, '" con ingrediente ',' agregada con ID ', nuevo_id_pizza) AS mensaje;

END $$

DELIMITER ;

CALL ps_add_pizza_con_ingredientes('Pizza Ranchera', 38000);

--2.`ps_actualizar_precio_pizza` Procedimiento que reciba `p_pizza_id` y `p_nuevo_precio`y actualice el precio.
--Antes de actualizar, valide con un `IF` que el nuevo precio sea mayor que 0; de lo contrario, lance un `SIGNAL`.

DELIMITER $$

DROP PROCEDURE IF EXISTS ps_actualizar_precio_pizza $$

CREATE PROCEDURE ps_actualizar_precio_pizza (
    IN p_pizza_id INT,
    IN p_nuevo_precio DECIMAL(10,2)
)
BEGIN
    IF p_nuevo_precio <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El precio debe ser mayor que cero';
    ELSE
        UPDATE pizza
        SET precio = p_nuevo_precio
        WHERE id = p_pizza_id;
    END IF;
END $$

DELIMITER ;

CALL ps_actualizar_precio_pizza(1, 42000);

CALL ps_actualizar_precio_pizza(2, -1000);

--3.`ps_generar_pedido`(usar TRANSACTION) Procedimiento que reciba: 
--`p_cliente_id`, 
--una lista de pizzas y cantidades (`p_items`), 
--`p_metodo_pago_id`. Dentro de una transacción: 
--Inserta en pedido. 
--Para cada ítem, inserta en `detalle_pedido` y en `detalle_pedido_pizza`. 
--Si todo va bien, hace `COMMIT`; si falla, `ROLLBACK` y devuelve un mensaje de error.

DELIMITER $$

DROP PROCEDURE IF EXISTS ps_generar_pedido $$
CREATE PROCEDURE ps_generar_pedido(
    IN p_cliente_id INT,
    IN p_metodo_pago_id INT,
    IN p_pizza_id INT,
    IN p_cantidad INT
)
BEGIN
    DECLARE v_pedido_id INT;
    DECLARE v_detalle_id INT;
    DECLARE v_precio DECIMAL(10,2);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION 
    BEGIN
        ROLLBACK;
        SELECT 'Error. Se cancelo el pedido.' AS mensaje;
    END;

    START TRANSACTION;

    INSERT INTO pedido(fecha_recogida, total, cliente_id, metodo_pago_id)
    VALUES (NOW(), 0.00, p_cliente_id, p_metodo_pago_id);

    SET v_pedido_id = LAST_INSERT_ID();

    INSERT INTO detalle_pedido(pedido_id, cantidad)
    VALUES (v_pedido_id, p_cantidad);

    SET v_detalle_id = LAST_INSERT_ID();

    INSERT INTO detalle_pedido_pizza(detalle_id, pizza_id)
    VALUES (v_detalle_id, p_pizza_id);

    SELECT precio INTO v_precio
    FROM pizza
    WHERE id = p_pizza_id;

    UPDATE pedido
    SET total = v_precio * p_cantidad
    WHERE id = v_pedido_id;

    COMMIT;

    SELECT 'Pedido realizado exitosamente' AS mensaje, v_pedido_id AS pedido_id;

END $$

DELIMITER ;

CALL ps_generar_pedido(1, 2, 3, 4);

--4.`ps_cancelar_pedido` Recibe `p_pedido_id` y:
--Marca el pedido como “cancelado” (p. ej. actualiza un campo `estado`),
--Elimina todas sus líneas de detalle (`DELETE FROM detalle_pedido WHERE pedido_id = …`).
--Devuelve el número de líneas eliminadas.

DELIMITER $$

DROP PROCEDURE IF EXISTS ps_cancelar_pedido $$

CREATE PROCEDURE ps_cancelar_pedido (
    IN p_pedido_id INT
)
BEGIN
    DECLARE existe INT;
    DECLARE v_filas_eliminadas INT;

    SELECT COUNT(*) INTO existe
    FROM pedido
    WHERE id = p_pedido_id;

    IF existe > 0 THEN
        UPDATE pedido
        SET total = 0
        WHERE id = p_pedido_id;

        DELETE FROM detalle_pedido
        WHERE pedido_id = p_pedido_id;

        SET v_filas_eliminadas = ROW_COUNT();

        SELECT 'Pedido cancelado' AS mensaje,
            v_filas_eliminadas AS lineas_eliminadas;
    ELSE
        
        SELECT 'El pedido no existe' AS mensaje;
    END IF;
END $$

DELIMITER ;

CALL ps_cancelar_pedido(1);

--5.`ps_facturar_pedido` Crea la factura asociada a un pedido dado (`p_pedido_id`). Debe:
--Calcular el total sumando precios de pizzas × cantidad,
--Insertar en `factura`.
--Devolver el `factura_id` generado.

DELIMITER $$

DROP PROCEDURE IF EXISTS ps_facturar_pedido $$
CREATE PROCEDURE ps_facturar_pedido(IN p_pedido_id INT)
BEGIN
    DECLARE total DECIMAL(10,2) DEFAULT 0;
    DECLARE cliente_id_aux INT;
    DECLARE factura_id INT;

    SELECT cliente_id INTO cliente_id_aux
    FROM pedido
    WHERE id = p_pedido_id;

    IF cliente_id_aux IS NULL THEN
        SELECT 'El pedido no existe' AS mensaje;
    ELSE
        SELECT SUM(p.precio * dp.cantidad) INTO total
        FROM detalle_pedido dp
        JOIN detalle_pedido_pizza dpp ON dp.id = dpp.detalle_id
        JOIN pizza p ON dpp.pizza_id = p.id
        WHERE dp.pedido_id = p_pedido_id;

        IF total IS NULL THEN
            SET total = 0;
        END IF;

        INSERT INTO factura (total, fecha, pedido_id, cliente_id)
        VALUES (total, NOW(), p_pedido_id, cliente_id_aux);

        SET factura_id = LAST_INSERT_ID();

        SELECT factura_id AS id_generado;
    END IF;
END $$

DELIMITER ;

CALL ps_facturar_pedido(1);

