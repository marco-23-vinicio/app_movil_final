import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../models/models.dart';

class PurchasesScreen extends StatefulWidget {
  @override
  _PurchasesScreenState createState() => _PurchasesScreenState();
}

class _PurchasesScreenState extends State<PurchasesScreen> {
  final _apiService = ApiService();
  String _filter = 'Todos';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Módulo de Compras')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: _filter,
              isExpanded: true,
              items: ['Todos', 'pendiente', 'recibida', 'cancelada'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (val) => setState(() => _filter = val!),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<OrdenCompra>>(
              future: _apiService.getCompras(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());
                if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));

                var ordenes = snapshot.data!;
                if (_filter != 'Todos') {
                  ordenes = ordenes.where((o) => o.estado.toLowerCase() == _filter.toLowerCase()).toList();
                }

                return ListView.builder(
                  itemCount: ordenes.length,
                  itemBuilder: (ctx, i) {
                    final o = ordenes[i];
                    return Card(
                      margin: EdgeInsets.all(8),
                      child: ListTile(
                        leading: Icon(Icons.local_shipping),
                        title: Text('${o.numeroOrden} - ${o.proveedorNombre}'),
                        subtitle: Text(DateFormat.yMMMd().format(DateTime.parse(o.fecha))),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('Q${o.total.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(o.estado, style: TextStyle(color: o.estado == 'recibida' ? Colors.blue : Colors.grey)),
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
    );
  }
}