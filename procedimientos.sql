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

