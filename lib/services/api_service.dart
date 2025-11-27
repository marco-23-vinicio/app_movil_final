import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class ApiService {
  static const String baseUrl = 'https://gestiondervini-production.up.railway.app/api';

  //login
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final url = Uri.parse('$baseUrl/login/');
      print("---- INTENTO DE LOGIN ----");
      print("URL: $url");
      print("Usuario: $username");

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'username': username, 'password': password}),
      );

      print("Respuesta Código: ${response.statusCode}");
      print("Respuesta Cuerpo: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
        final token = body['token'];
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('username', body['username']);
        
        return {'success': true, 'data': body};
      } else {
        try {
            final body = jsonDecode(utf8.decode(response.bodyBytes));
            return {'success': false, 'error': body['error'] ?? 'Credenciales inválidas'};
        } catch (_) {
            return {'success': false, 'error': 'Error ${response.statusCode}: Credenciales incorrectas'};
        }
      }
    } catch (e) {
      print("ERROR CRÍTICO: $e");
      return {'success': false, 'error': 'No se pudo conectar. Verifica tu internet.'};
    }
  }

  //metodo generico para GET con token
  Future<List<dynamic>> _get(String endpoint) async {
    try {
      // Obtener token de SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await http.get(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        print('Error en $endpoint: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Excepción en $endpoint: $e');
      return [];
    }
  }

  //metodos de lectura
  Future<List<Cliente>> getClientes() async {
    final data = await _get('clientes/');
    return data.map((json) => Cliente.fromJson(json)).toList();
  }

  Future<List<Pedido>> getVentas() async {
    final data = await _get('ventas/');
    return data.map((json) => Pedido.fromJson(json)).toList();
  }

  Future<List<OrdenCompra>> getCompras() async {
    final data = await _get('compras/');
    return data.map((json) => OrdenCompra.fromJson(json)).toList();
  }

  Future<List<Producto>> getProductos() async {
    final data = await _get('productos/');
    return data.map((json) => Producto.fromJson(json)).toList();
  }

  Future<List<MovimientoInventario>> getMovimientos() async {
    final data = await _get('movimientos/');
    return data.map((json) => MovimientoInventario.fromJson(json)).toList();
  }

  Future<List<Proveedor>> getProveedores() async {
    final data = await _get('proveedores/');
    return data.map((json) => Proveedor.fromJson(json)).toList();
  }

  Future<List<Categoria>> getCategorias() async {
    final data = await _get('categorias/');
    return data.map((json) => Categoria.fromJson(json)).toList();
  }
}