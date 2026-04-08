SQL> select pedidoid from detallespedidos;

  PEDIDOID
----------
       101
       101
       101
       101

SQL> select total from pedidos;

     TOTAL
----------
       600
       300
       800
SQL> select detalleid from detallespedidos where detalleid=3;

 DETALLEID
----------
         3SQL> select detalleid from detallespedidos where detalleid=3;

 DETALLEID
----------
         3
SQL> select * from detallespedidos  where detalleid=4;

 DETALLEID   PEDIDOID PRODUCTOID   CANTIDAD
---------- ---------- ---------- ----------
         4        101          1          3
SQL> select * from productos where nombre = 'Laptop';

PRODUCTOID NOMBRE                                                 PRECIO
---------- -------------------------------------------------- ----------
         1 Laptop                                                   1200
SQL> select * from productos where nombre = 'Mouse';

PRODUCTOID NOMBRE                                                 PRECIO
---------- -------------------------------------------------- ----------
         2 Mouse                                                      25
SQL> CREATE VIEW Vista_Clientes_Pedidos AS SELECT c.ClienteID, c.Nombre, p.PedidoID, p.FechaPedido, p.Total FROM Clientes c JOIN Pedidos p ON c.ClienteID = p.ClienteID;

View created.

SQL> select * from Vista_Clientes_Pedidos;

 CLIENTEID NOMBRE                                               PEDIDOID
---------- -------------------------------------------------- ----------
FECHAPEDI      TOTAL
--------- ----------
         1 Juan Perez                                                101
01-MAR-25        600

         1 Juan Perez                                                102
02-MAR-25        300

         2 Mar??a Gomez                                              103
03-MAR-25        800

SQL> CREATE VIEW Vista_Productos_Cantidades AS SELECT pr.ProductoID, pr.Nombre, SUM(d.Cantidad) AS TotalCantidad FROM Productos pr JOIN DetallesPedidos d ON pr.ProductoID = d.ProductoID GROUP BY pr.ProductoID, pr.Nombre;

SQL> select * from Vista_Productos_Cantidades;

PRODUCTOID NOMBRE                                             TOTALCANTIDAD
---------- -------------------------------------------------- -------------
         1 Laptop                                                         5
         2 Mouse    