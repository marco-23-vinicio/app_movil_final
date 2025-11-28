import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../models/models.dart';

class SalesScreen extends StatefulWidget {
  @override
  _SalesScreenState createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _apiService = ApiService();
  String _filter = 'Todos';
  late Future<List<Pedido>> _ventasFuture;
  late Future<List<Cliente>> _clientesFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      _ventasFuture = _apiService.getVentas();
      _clientesFuture = _apiService.getClientes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Módulo de Ventas'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Pedidos'),
            Tab(text: 'Clientes'),
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
          //pestania de pedidos
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButton<String>(
                  value: _filter,
                  isExpanded: true,
                  items: ['Todos', 'pendiente', 'completado', 'cancelado']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (val) => setState(() => _filter = val!),
                ),
              ),
              Expanded(
                child: FutureBuilder<List<Pedido>>(
                  future: _ventasFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting)
                      return Center(child: CircularProgressIndicator());
                    if (snapshot.hasError)
                      return Center(child: Text('Error: ${snapshot.error}'));

                    var pedidos = snapshot.data!;
                    if (_filter != 'Todos') {
                      pedidos = pedidos
                          .where(
                            (p) =>
                                p.estado.toLowerCase() == _filter.toLowerCase(),
                          )
                          .toList();
                    }

                    return ListView.builder(
                      itemCount: pedidos.length,
                      itemBuilder: (ctx, i) {
                        final p = pedidos[i];
                        return Card(
                          margin: EdgeInsets.all(8),
                          child: ListTile(
                            title: Text(
                              '${p.numeroPedido} - ${p.clienteNombre}',
                            ),
                            subtitle: Text(
                              DateFormat.yMMMd().format(
                                DateTime.parse(p.fecha),
                              ),
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Q${p.total.toStringAsFixed(2)}',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  p.estado,
                                  style: TextStyle(
                                    color:
                                        p.estado.toLowerCase() == 'completado'
                                        ? Colors.green
                                        : p.estado.toLowerCase() == 'cancelado'
                                        ? Colors.red
                                        : Colors.orange,
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
          ),
          //pestania de clientes
          FutureBuilder<List<Cliente>>(
            future: _clientesFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData)
                return Center(child: CircularProgressIndicator());
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (ctx, i) {
                  final c = snapshot.data![i];
                  return ListTile(
                    leading: CircleAvatar(child: Text(c.nombre[0])),
                    title: Text(c.nombre),
                    subtitle: Text(c.correo),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
