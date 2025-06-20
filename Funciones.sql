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

--3. `fc_precio_final_pedido`
--Parámetros: `p_pedido_id INT`
--Usa `calcular_subtotal_pizza` y `descuento_por_cantidad` para devolver el total a pagar.

DELIMITER $$

DROP FUNCTION IF EXISTS fc_precio_final_pedido $$

CREATE FUNCTION fc_precio_final_pedido(p_pedido_id INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE total_final DECIMAL(10,2);

    SELECT 
        SUM(
            (fc_calcular_subtotal_pizza(dpp.pizza_id) * dp.cantidad)
            - fc_descuento_por_cantidad(dp.cantidad, fc_calcular_subtotal_pizza(dpp.pizza_id))
        )
    INTO total_final
    FROM detalle_pedido dp
    JOIN detalle_pedido_pizza dpp ON dp.id = dpp.detalle_id
    WHERE dp.pedido_id = p_pedido_id;

    RETURN IFNULL(total_final, 0);
END $$

DELIMITER ;

SELECT fc_precio_final_pedido(1);

--4. `fc_obtener_stock_ingrediente`
--Parámetro: `p_ingrediente_id INT`
--Retorna el stock disponible del ingrediente.

DELIMITER $$

DROP FUNCTION IF EXISTS fc_obtener_stock_ingrediente $$

CREATE FUNCTION fc_obtener_stock_ingrediente(p_ingrediente_id INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE stock_disponible INT;

    SELECT stock
    INTO stock_disponible
    FROM ingrediente
    WHERE id = p_ingrediente_id;

    RETURN IFNULL(stock_disponible, 0);
END $$

DELIMITER ;

SELECT fc_obtener_stock_ingrediente(2) AS stock_actual;

--5. `fc_es_pizza_popular`
--Parámetro: `p_pizza_id INT`
--Retorna `1` si la pizza ha sido pedida más de 50 veces (contando en `detalle_pedido_pizza`), sino `0`.

DELIMITER $$

DROP FUNCTION IF EXISTS fc_es_pizza_popular $$

CREATE FUNCTION fc_es_pizza_popular(p_pizza_id INT)
RETURNS TINYINT
DETERMINISTIC
BEGIN
    DECLARE total_pedidos INT;

    SELECT COUNT(*) INTO total_pedidos
    FROM detalle_pedido_pizza
    WHERE pizza_id = p_pizza_id;

    RETURN IF(total_pedidos > 50, 1, 0);
END $$

DELIMITER ;

SELECT fc_es_pizza_popular(2);



