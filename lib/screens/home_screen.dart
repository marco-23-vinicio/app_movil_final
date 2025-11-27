import 'package:flutter/material.dart';
import 'sales_screen.dart';
import 'purchases_screen.dart';
import 'inventory_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dashboard Principal')),
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text("Usuario"),
              accountEmail: Text("admin@sistema.com"),
              currentAccountPicture: CircleAvatar(child: Icon(Icons.person)),
            ),
            ListTile(leading: Icon(Icons.point_of_sale), title: Text('Ventas'), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SalesScreen()))),
            ListTile(leading: Icon(Icons.shopping_cart), title: Text('Compras'), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PurchasesScreen()))),
            ListTile(leading: Icon(Icons.inventory), title: Text('Inventario'), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => InventoryScreen()))),
            Divider(),
            ListTile(leading: Icon(Icons.logout), title: Text('Cerrar Sesión'), onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()))),
          ],
        ),
      ),
      body: Center(child: Text("Bienvenido al Sistema Móvil", style: TextStyle(fontSize: 20, color: Colors.grey))),
    );
  }
}