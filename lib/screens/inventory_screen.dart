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
  late Future<List<Producto>> _productosFuture;
  late Future<List<MovimientoInventario>> _movimientosFuture;
  late Future<List<Categoria>> _categoriasFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); //inicializar para 3 pestanias
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      _productosFuture = _apiService.getProductos();
      _movimientosFuture = _apiService.getMovimientos();
      _categoriasFuture = _apiService.getCategorias();
    });
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
            Tab(icon: Icon(Icons.category), text: 'Categorías'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          //pestanias
          _buildProductosTab(),
          _buildMovimientosTab(),
          _buildCategoriasTab(),
        ],
      ),
    );
  }

  Widget _buildProductosTab() {
    return FutureBuilder<List<Producto>>(
      future: _productosFuture,
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

  Widget _buildMovimientosTab() {
    return FutureBuilder<List<MovimientoInventario>>(
      future: _movimientosFuture,
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

            //determinar si es Entrada o Salida
            bool esEntrada = mov.tipo.toLowerCase() == 'entrada';

            //formato simple de fecha
            //"2025-11-23T05:00:40..." -> "2025-11-23"
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
                    esEntrada ? Icons.download : Icons.upload,
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

  Widget _buildCategoriasTab() {
    return FutureBuilder<List<Categoria>>(
      future: _categoriasFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error al cargar categorías'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No hay categorías registradas'));
        }

        final categorias = snapshot.data!;
        final colorFondo = Colors.blue.shade100;
        final colorIcono = Colors.blue.shade800;

        return ListView.builder(
          padding: EdgeInsets.all(8),
          itemCount: categorias.length,
          itemBuilder: (context, index) {
            final cat = categorias[index];

            return Card(
              elevation: 2,
              margin: EdgeInsets.symmetric(vertical: 5),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: colorFondo,
                  child: Icon(Icons.category, color: colorIcono),
                ),
                title: Text(
                  cat.nombre,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            );
          },
        );
      },
    );
  }
}