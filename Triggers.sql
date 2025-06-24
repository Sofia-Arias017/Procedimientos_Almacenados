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

--3. `tg_after_update_pizza_precio`
--`AFTER UPDATE` en pizza
--Inserta en una tabla `auditoria_precios` la pizza_id, precio antiguo y nuevo, y timestamp.

DELIMITER $$

CREATE TRIGGER tg_after_update_pizza_precio
AFTER UPDATE ON pizza
FOR EACH ROW
BEGIN
    IF NEW.precio <> OLD.precio THEN
        INSERT INTO auditoria_precios (pizza_id, precio_anterior, precio_nuevo, fecha_cambio)
        VALUES (OLD.id, OLD.precio, NEW.precio, NOW());
    END IF;
END $$

DELIMITER ;

UPDATE producto_presentacion SET precio = 6000 WHERE producto_id = 1 AND presentacion_id = 1;

--4. `tg_before_delete_pizza`
--`BEFORE DELETE` en `pizza`
--Impide borrar si la pizza aparece en algún `detalle_pedido_pizza` (lanza `SIGNAL`).

DELIMITER $$

CREATE TRIGGER tg_before_delete_pizza
BEFORE DELETE ON pizza
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1
        FROM detalle_pedido_pizza
        WHERE pizza_id = OLD.id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No se puede eliminar la pizza porque está en pedidos';
    END IF;
END $$

DELIMITER ;

DELETE FROM pizza WHERE id = 1;



