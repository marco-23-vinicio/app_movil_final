import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/models.dart';
import 'sales_screen.dart';
import 'purchases_screen.dart';
import 'inventory_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  final String username;
  final String email;

  HomeScreen({required this.username, required this.email});

  final _apiService = ApiService();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Dashboard Principal'),
        //se mantiene esto para evitar que cambie el icono del hamburguer
        automaticallyImplyLeading: false, 
        //botón en el AppBar para abrir el Drawer o sidebar
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              color: Theme.of(context).primaryColor, 
              child: SafeArea( //para manejar el espacio del notch y la barra de estado
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 16.0, left: 12.0, right: 16.0), // Ajustamos el padding
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //boton para cerrar el drawer
                      IconButton(
                        icon: Icon(Icons.menu, color: Colors.white), 
                        onPressed: () => Navigator.pop(context), 
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(minWidth: 40, minHeight: 40),
                        alignment: Alignment.centerLeft,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      //informacion del usuario
                      const CircleAvatar(child: Icon(Icons.person)),
                      const SizedBox(height: 8),
                      Text(username, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(email, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                    ],
                  ),
                ),
              ),
            ),
            // =======================================================

            ListTile(
                leading: const Icon(Icons.point_of_sale),
                title: const Text('Ventas'),
                onTap: () {
                  _scaffoldKey.currentState?.closeDrawer();
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              SalesScreen()));
                }),
            ListTile(
                leading: const Icon(Icons.shopping_cart),
                title: const Text('Compras'),
                onTap: () {
                  _scaffoldKey.currentState?.closeDrawer();
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              PurchasesScreen()));
                }),
            ListTile(
                leading: const Icon(Icons.inventory),
                title: const Text('Inventario'),
                onTap: () {
                  _scaffoldKey.currentState?.closeDrawer();
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              InventoryScreen()));
                }),
            const Divider(),
            ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Cerrar Sesión'),
                onTap: () => Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (_) => LoginScreen()))),
          ],
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: Future.wait([_apiService.getVentas(), _apiService.getClientes()]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError)
            return Center(child: Text('Error: ${snapshot.error}'));

          final ventasTodas = (snapshot.data![0] as List<Pedido>);
          final clientes = (snapshot.data![1] as List<Cliente>);

          //usar solo pedidos completados para totales, conteos y gráficas
          final ventasCompletadas = ventasTodas
              .where((p) => p.estado.toLowerCase() == 'completado')
              .toList();

          final totalVentas = ventasCompletadas.fold<double>(0.0, (s, p) => s + (p.total));
          final pedidosCount = ventasCompletadas.length;
          final clientesCount = clientes.length;
          final latestOrders = ventasCompletadas.reversed.take(5).toList();

          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                //cards resumen
                Row(
                  children: [
                    Expanded(
                      child: Card(
                        color: Colors.blue[50],
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Total en Ventas', style: TextStyle(color: Colors.blueGrey)),
                              const SizedBox(height: 8),
                              Text('Q${totalVentas.toStringAsFixed(2)}',
                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Card(
                        color: Colors.green[50],
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Ventas', style: TextStyle(color: Colors.blueGrey)),
                              const SizedBox(height: 8),
                              Text('$pedidosCount',
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green[700])),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Card(
                        color: Colors.orange[50],
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Clientes', style: TextStyle(color: Colors.blueGrey)),
                              const SizedBox(height: 8),
                              Text('$clientesCount',
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange[800])),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                //ultimos pedidos
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          const ListTile(title: Text('Últimas ventas', style: TextStyle(fontWeight: FontWeight.bold))),
                          const Divider(),
                          Expanded(
                            child: latestOrders.isNotEmpty
                                ? ListView.separated(
                                    itemCount: latestOrders.length,
                                    separatorBuilder: (_, __) => const Divider(),
                                    itemBuilder: (ctx, i) {
                                      final p = latestOrders[i];
                                      return ListTile(
                                        title: Text('${p.numeroPedido} - ${p.clienteNombre}'),
                                        subtitle: Text(p.fecha),
                                        trailing: Text('Q${p.total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                      );
                                    },
                                  )
                                : const Center(child: Text('No hay pedidos recientes')),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}