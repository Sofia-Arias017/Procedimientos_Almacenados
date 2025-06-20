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

--2. `fc_descuento_por_cantidad`
--Parámetros: `p_cantidad INT`, `p_precio_unitario DECIMAL`
--Si `p_cantidad ≥ 5` aplica 10% de descuento, sino 0%. Retorna el monto de descuento.

DELIMITER $$

DROP FUNCTION IF EXISTS fc_descuento_por_cantidad $$

CREATE FUNCTION fc_descuento_por_cantidad(
    p_cantidad INT,
    p_precio_unitario DECIMAL(10,2)
)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE descuento DECIMAL(10,2);

    IF p_cantidad >= 5 THEN
        SET descuento = p_precio_unitario * p_cantidad * 0.10;
    ELSE
        SET descuento = 0;
    END IF;

    RETURN descuento;
END $$

DELIMITER ;

SELECT fc_descuento_por_cantidad(6, 12000) AS descuento_aplicado;


