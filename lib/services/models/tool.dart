class Tool {
  String id; // ID da ferramenta
  String name; // Nome da ferramenta
  int quantity; // Quantidade da ferramenta
  String priority; // Prioridade da ferramenta
  bool owned; // Indica se a ferramenta é possuída ou não

  Tool({
    required this.id,
    required this.name,
    required this.quantity,
    required this.priority,
    required this.owned,
  });

  // Método para converter um objeto Tool em um mapa
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'quantity': quantity,
      'priority': priority,
      'owned': owned,
    };
  }

  // Método para criar um objeto Tool a partir de um mapa
  factory Tool.fromMap(Map<String, dynamic> map, String id) {
    return Tool(
      id: id,
      name: map['name'] as String,
      quantity: map['quantity'] as int,
      priority: map['priority'] as String,
      owned: map['owned'] as bool,
    );
  }
}