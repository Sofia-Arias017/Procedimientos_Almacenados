--1.`ps_add_pizza_con_ingredientes` Crea un procedimiento que inserte una nueva pizza en la tabla `pizza` junto con sus ingredientes en `pizza_ingrediente`.
--Parámetros de entrada: `p_nombre_pizza`, `p_precio`, lista de `p_ids_ingredientes`.
--Debe recorrer la lista de ingredientes (cursor o ciclo) y hacer los inserts correspondients.

DELIMITER $$

DROP PROCEDURE IF EXISTS ps_add_pizza_con_ingredientes $$

CREATE PROCEDURE ps_add_pizza_con_ingredientes (
    IN p_nombre_pizza VARCHAR(100),
    IN p_precio DECIMAL(10,2),
    IN p_ids_ingredientes TEXT
)
BEGIN 
    DECLARE nuevo_id_pizza INT;
    DECLARE id_ingrediente INT;
    DECLARE posicion_coma INT;

    INSERT INTO pizza (nombre, precio)
    VALUES (p_nombre_pizza, p_precio);

    SET nuevo_id_pizza = LAST_INSERT_ID();

    WHILE LENGTH(p_ids_ingredientes) > 0 DO
        SET posicion_coma = LOCATE(',', p_ids_ingredientes);

        IF posicion_coma = 0 THEN
            SET id_ingrediente = p_ids_ingredientes;
            SET p_ids_ingredientes = '';
        ELSE
            SET id_ingrediente = SUBSTRING(p_ids_ingredientes, 1, posicion_coma - 1);
            SET p_ids_ingredientes = SUBSTRING(p_ids_ingredientes, posicion_coma + 1);
        END IF;

        INSERT INTO pizza_ingrediente (pizza_id, ingrediente_id)
        VALUES (nuevo_id_pizza, id_ingrediente);
    END WHILE;

END $$

DELIMITER ;

CALL ps_add_pizza_con_ingredientes('Pizza Ranchera', 38000, '1,2,3');

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
