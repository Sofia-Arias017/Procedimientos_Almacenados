--1. `fc_calcular_subtotal_pizza`
--Parámetro: `p_pizza_id`
--Retorna el precio base de la pizza más la suma de precios de sus ingredientes.

DELIMITER $$

DROP FUNCTION IF EXISTS fc_calcular_subtotal_pizza $$

CREATE FUNCTION fc_calcular_subtotal_pizza(p_pizza_id INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE precio_base DECIMAL(10,2);
    DECLARE total_ingredientes DECIMAL(10,2);

    SELECT precio INTO precio_base
    FROM pizza
    WHERE id = p_pizza_id;

    SELECT SUM(i.precio) INTO total_ingredientes
    FROM pizza_ingrediente pi
    JOIN ingrediente i ON pi.ingrediente_id = i.id
    WHERE pi.pizza_id = p_pizza_id;

    IF total_ingredientes IS NULL THEN
        SET total_ingredientes = 0;
    END IF;

    RETURN precio_base + total_ingredientes;
END $$

DELIMITER ;

SELECT fc_calcular_subtotal_pizza(1) AS subtotal;


