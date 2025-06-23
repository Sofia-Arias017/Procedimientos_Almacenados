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
