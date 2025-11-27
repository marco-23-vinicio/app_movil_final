// lib/screens/inventory_screen.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/models.dart';

class InventoryScreen extends StatefulWidget {
  @override
  _InventoryScreenState createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    // Inicializamos el controlador para las 2 pestañas
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestión de Inventario'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: Icon(Icons.store), text: 'Existencias'),
            Tab(icon: Icon(Icons.history_edu), text: 'Movimientos'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // --- PESTAÑA 1: PRODUCTOS (Existencias) ---
          _buildProductosTab(),

          // --- PESTAÑA 2: MOVIMIENTOS (Entradas/Salidas) ---
          _buildMovimientosTab(),
        ],
      ),
    );
  }

  // Widget auxiliar para la lista de Productos
  Widget _buildProductosTab() {
    return FutureBuilder<List<Producto>>(
      future: _apiService.getProductos(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error al cargar productos'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No hay productos en inventario'));
        }

        final productos = snapshot.data!;

        return ListView.builder(
          padding: EdgeInsets.all(8),
          itemCount: productos.length,
          itemBuilder: (context, index) {
            final prod = productos[index];
            return Card(
              elevation: 2,
              margin: EdgeInsets.symmetric(vertical: 5),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.shade100,
                  child: Text(
                    '${prod.cantidad}', // Stock actual
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade900),
                  ),
                ),
                title: Text(
                  prod.nombre,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Código: ${prod.codigo}'),
                    Text('Venta: Q${prod.precioVenta} | Compra: Q${prod.precioCompra}'),
                  ],
                ),
                isThreeLine: true,
              ),
            );
          },
        );
      },
    );
  }

  // Widget auxiliar para la lista de Movimientos
  Widget _buildMovimientosTab() {
    return FutureBuilder<List<MovimientoInventario>>(
      future: _apiService.getMovimientos(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          // Muestra el error en consola para depurar si falla
          print(snapshot.error);
          return Center(child: Text('Error al cargar movimientos'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No hay movimientos registrados'));
        }

        final movimientos = snapshot.data!;

        return ListView.builder(
          padding: EdgeInsets.all(8),
          itemCount: movimientos.length,
          itemBuilder: (context, index) {
            final mov = movimientos[index];
            
            // Determinar si es Entrada o Salida para los colores
            // Comparamos en minúsculas para evitar errores
            bool esEntrada = mov.tipo.toLowerCase() == 'entrada';
            
            // Formato simple de fecha (Cortamos el string ISO)
            // "2025-11-23T05:00:40..." -> "2025-11-23"
            String fechaCorta = mov.fecha.length > 10 
                ? mov.fecha.substring(0, 10) 
                : mov.fecha;

            return Card(
              margin: EdgeInsets.symmetric(vertical: 5),
              child: ListTile(
                leading: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: esEntrada ? Colors.green.shade100 : Colors.red.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    esEntrada ? Icons.download : Icons.upload, // Flecha abajo (entra), Flecha arriba (sale)
                    color: esEntrada ? Colors.green.shade800 : Colors.red.shade800,
                  ),
                ),
                title: Text(
                  mov.productoNombre,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('Ref: ${mov.referencia}\nFecha: $fechaCorta'),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${mov.cantidad}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: esEntrada ? Colors.green.shade700 : Colors.red.shade700,
                      ),
                    ),
                    Text(
                      esEntrada ? 'ENTRADA' : 'SALIDA',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}