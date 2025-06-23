--1. `tg_before_insert_detalle_pedido`
--`BEFORE INSERT` en `detalle_pedido`
--Valida que la cantidad sea ≥ 1; si no, `SIGNAL` de error.

DELIMITER $$

CREATE TRIGGER tg_before_insert_detalle_pedido
BEFORE INSERT ON detalle_pedido
FOR EACH ROW
BEGIN
    IF NEW.cantidad < 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La cantidad debe ser mayor o igual a 1';
    END IF;
END $$

DELIMITER ;

INSERT INTO detalle_pedido (pedido_id, cantidad)VALUES (1, 3);

--2. `tg_after_insert_detalle_pedido_pizza`
--`AFTER INSERT` en `detalle_pedido_pizza`
--Disminuye el `stock` correspondiente en `ingrediente` según la receta de la pizza.

DELIMITER $$

CREATE TRIGGER tg_after_insert_detalle_pedido_pizza
AFTER INSERT ON detalle_pedido_pizza
FOR EACH ROW
BEGIN
    UPDATE ingrediente i
    JOIN receta r ON r.ingrediente_id = i.id
    SET i.stock = i.stock - r.cantidad
    WHERE r.pizza_id = NEW.pizza_id;
END $$

DELIMITER ;


