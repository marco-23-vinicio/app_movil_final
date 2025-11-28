import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../models/models.dart';

class PurchasesScreen extends StatefulWidget {
  @override
  _PurchasesScreenState createState() => _PurchasesScreenState();
}

class _PurchasesScreenState extends State<PurchasesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _apiService = ApiService();
  String _filter = 'Todos';
  late Future<List<OrdenCompra>> _comprasFuture;
  late Future<List<Proveedor>> _proveedoresFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); //inicializar para 2 pestanias
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      _comprasFuture = _apiService.getCompras();
      _proveedoresFuture = _apiService.getProveedores();
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
        title: Text('Módulo de Compras'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: Icon(Icons.shopping_cart), text: 'Órdenes'),
            Tab(icon: Icon(Icons.business), text: 'Proveedores'),
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
          _buildOrdenesTab(),
          _buildProveedoresTab(),
        ],
      ),
    );
  }

  Widget _buildOrdenesTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: DropdownButton<String>(
            value: _filter,
            isExpanded: true,
            items: [
              'Todos',
              'pendiente',
              'recibida',
              'cancelada',
            ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (val) => setState(() => _filter = val!),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<OrdenCompra>>(
            future: _comprasFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting)
                return Center(child: CircularProgressIndicator());
              if (snapshot.hasError)
                return Center(child: Text('Error: ${snapshot.error}'));

              var ordenes = snapshot.data!;
              if (_filter != 'Todos') {
                ordenes = ordenes
                    .where(
                      (o) => o.estado.toLowerCase() == _filter.toLowerCase(),
                    )
                    .toList();
              }

              return ListView.builder(
                itemCount: ordenes.length,
                itemBuilder: (ctx, i) {
                  final o = ordenes[i];
                  final estadoLower = o.estado.toLowerCase();
                  final colorEstado = estadoLower == 'recibida'
                      ? Colors.green
                      : estadoLower == 'cancelada'
                      ? Colors.red
                      : Colors.orange;

                  return Card(
                    margin: EdgeInsets.all(8),
                    child: ListTile(
                      leading: Icon(Icons.local_shipping, color: colorEstado),
                      title: Text('${o.numeroOrden} - ${o.proveedorNombre}'),
                      subtitle: Text(
                        DateFormat.yMMMd().format(DateTime.parse(o.fecha)),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Q${o.total.toStringAsFixed(2)}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4),
                          Text(
                            o.estado,
                            style: TextStyle(
                              color: colorEstado,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProveedoresTab() {
    return FutureBuilder<List<Proveedor>>(
      future: _proveedoresFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error al cargar proveedores'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No hay proveedores registrados'));
        }

        final proveedores = snapshot.data!;

        return ListView.builder(
          padding: EdgeInsets.all(8),
          itemCount: proveedores.length,
          itemBuilder: (context, index) {
            final prov = proveedores[index];
            return Card(
              elevation: 2,
              margin: EdgeInsets.symmetric(vertical: 5),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.shade100,
                  child: Text(
                    prov.empresa[0].toUpperCase(),
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade900),
                  ),
                ),
                title: Text(
                  prov.empresa,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Contacto: ${prov.contacto}'),
                    Text('Tel: ${prov.telefono}'),
                    Text('Dir: ${prov.direccion}', maxLines: 1, overflow: TextOverflow.ellipsis),
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
}
