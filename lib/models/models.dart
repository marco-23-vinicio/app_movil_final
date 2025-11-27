// lib/models/models.dart

class Cliente {
  final int id;
  final String nombre;
  final String direccion;
  final String telefono;
  final String correo;

  Cliente({
    required this.id,
    required this.nombre,
    required this.direccion,
    required this.telefono,
    required this.correo,
  });

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      id: json['id'],
      nombre: json['nombre'],
      direccion: json['direccion'] ?? '',
      telefono: json['telefono'] ?? '',
      correo: json['correo'] ?? '',
    );
  }
}

class Pedido {
  final int id;
  final String numeroPedido;
  final String fecha;
  final String estado;
  final double total;
  final String clienteNombre;

  Pedido({
    required this.id,
    required this.numeroPedido,
    required this.fecha,
    required this.estado,
    required this.total,
    required this.clienteNombre,
  });

  factory Pedido.fromJson(Map<String, dynamic> json) {
    return Pedido(
      id: json['id'],
      numeroPedido: json['numero_pedido'],
      fecha: json['fecha'],
      estado: json['estado'],
      // Convertimos el String "10000.00" a double
      total: double.tryParse(json['total'].toString()) ?? 0.0,
      clienteNombre: json['cliente_nombre'] ?? 'Cliente',
    );
  }
}

class OrdenCompra {
  final int id;
  final String numeroOrden;
  final String fecha;
  final String estado;
  final double total;
  final String proveedorNombre;

  OrdenCompra({
    required this.id,
    required this.numeroOrden,
    required this.fecha,
    required this.estado,
    required this.total,
    required this.proveedorNombre,
  });

  factory OrdenCompra.fromJson(Map<String, dynamic> json) {
    return OrdenCompra(
      id: json['id'],
      numeroOrden: json['numero_orden'],
      fecha: json['fecha'],
      estado: json['estado'],
      total: double.tryParse(json['total'].toString()) ?? 0.0,
      proveedorNombre: json['proveedor_nombre'] ?? 'Proveedor',
    );
  }
}

class Producto {
  final int id;
  final String codigo;
  final String nombre;
  final String descripcion;
  final double precioVenta;
  final double precioCompra;
  final int cantidad;
  final String proveedorNombre;
  final String categoriaNombre;

  Producto({
    required this.id,
    required this.codigo,
    required this.nombre,
    required this.descripcion,
    required this.precioVenta,
    required this.precioCompra,
    required this.cantidad,
    required this.proveedorNombre,
    required this.categoriaNombre,
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: json['id'],
      codigo: json['codigo'],
      nombre: json['nombre'],
      descripcion: json['descripcion'] ?? '',
      precioVenta: double.tryParse(json['precio_venta'].toString()) ?? 0.0,
      precioCompra: double.tryParse(json['precio_compra'].toString()) ?? 0.0,
      cantidad: json['cantidad'],
      proveedorNombre: json['proveedor_nombre'] ?? '',
      categoriaNombre: json['categoria_nombre'] ?? '',
    );
  }
}

class MovimientoInventario {
  final int id;
  final String fecha;
  final String tipo; // "entrada" o "salida"
  final int cantidad;
  final String productoNombre;
  final String referencia; // Guardaremos aquí el PED-xxxxx o ORD-xxxxx

  MovimientoInventario({
    required this.id,
    required this.fecha,
    required this.tipo,
    required this.cantidad,
    required this.productoNombre,
    required this.referencia,
  });

  factory MovimientoInventario.fromJson(Map<String, dynamic> json) {
    String ref = 'N/A';
    if (json['compra_numero'] != null) {
      ref = json['compra_numero'];
    } else if (json['venta_numero'] != null) {
      ref = json['venta_numero'];
    }

    return MovimientoInventario(
      id: json['id'],
      fecha: json['fecha'], // Viene como "2025-11-23T05:00:40..."
      tipo: json['tipo'],
      cantidad: json['cantidad'],
      productoNombre: json['producto_nombre'],
      referencia: ref,
    );
  }
}

class Proveedor {
  final int id;
  final String empresa;
  final String contacto;
  final String telefono;
  final String direccion;

  Proveedor({
    required this.id,
    required this.empresa,
    required this.contacto,
    required this.telefono,
    required this.direccion,
  });

  factory Proveedor.fromJson(Map<String, dynamic> json) {
    return Proveedor(
      id: json['id'],
      empresa: json['empresa'],
      contacto: json['contacto'],
      telefono: json['telefono'],
      direccion: json['direccion'],
    );
  }
}

class Categoria {
  final int id;
  final String nombre;

  Categoria({
    required this.id,
    required this.nombre,
  });

  factory Categoria.fromJson(Map<String, dynamic> json) {
    return Categoria(
      id: json['id'],
      nombre: json['nombre'],
    );
  }
}