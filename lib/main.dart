import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:n2mobileflutter/firebase_options.dart';
import 'package:n2mobileflutter/services/models/tool.dart';
import 'services/firebase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Garante que os widgets sejam inicializados antes de usar o Firebase

  // Inicializa o Firebase somente se ainda não estiver inicializado
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      name: 'n2mobileflutter',
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  runApp(const MyApp()); // Executa o aplicativo
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gerenciador de Ferramentas', // Título do aplicativo
      theme: ThemeData(
        primaryColor: const Color(0xFF705C53), // Cor principal do tema
        scaffoldBackgroundColor: const Color(0xFFF5F5F7), // Cor de fundo das telas
        appBarTheme: const AppBarTheme(
          color: Color(0xFF705C53), // Cor da barra de navegação superior
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF705C53), // Cor do botão elevado
            foregroundColor: Colors.white, // Cor do texto do botão elevado
          ),
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            color: Color(0xFF705C53),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Colors.white, // Fundo branco nos campos de entrada
        ),
      ),
      home: const HomeScreen(), // Tela inicial do aplicativo
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseService _firebaseService = FirebaseService(); // Serviço do Firebase
  final TextEditingController _toolNameController = TextEditingController(); // Controlador para o campo de nome
  final TextEditingController _toolQuantityController = TextEditingController(); // Controlador para o campo de quantidade
  String _selectedPriority = 'Média'; // Prioridade inicial selecionada

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciador de Ferramentas'), // Título da AppBar
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0), // Espaçamento ao redor dos campos
            child: Column(
              children: [
                TextField(
                  controller: _toolNameController,
                  decoration: const InputDecoration(labelText: 'Nome da Ferramenta'), // Rótulo do campo
                ),
                TextField(
                  controller: _toolQuantityController,
                  keyboardType: TextInputType.number, // Tipo de teclado numérico
                  decoration: const InputDecoration(labelText: 'Quantidade'), // Rótulo do campo
                ),
                DropdownButton<String>(
                  value: _selectedPriority,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedPriority = newValue!; // Atualiza a prioridade selecionada
                    });
                  },
                  items: <String>['Pouca', 'Média', 'Alta'] // Opções de prioridade
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                ElevatedButton(
                  child: const Text('Adicionar Ferramenta Possuída'), // Botão para adicionar ferramenta possuída
                  onPressed: () {
                    // Verifica se os campos não estão vazios
                    if (_toolNameController.text.isEmpty ||
                        _toolQuantityController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Por favor, insira um nome e uma quantidade para a ferramenta.'),
                        ),
                      );
                      return;
                    }
                    final tool = Tool(
                      id: '',
                      name: _toolNameController.text,
                      quantity: int.parse(_toolQuantityController.text),
                      priority: _selectedPriority,
                      owned: true,
                    );
                    _firebaseService.addTool(tool); // Adiciona a ferramenta ao Firebase
                    _toolNameController.clear(); // Limpa o campo de nome
                    _toolQuantityController.clear(); // Limpa o campo de quantidade
                  },
                ),
                ElevatedButton(
                  child: const Text('Adicionar à Compra'), // Botão para adicionar ferramenta à lista de compras
                  onPressed: () {
                    if (_toolNameController.text.isEmpty ||
                        _toolQuantityController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Por favor, insira um nome e uma quantidade para a ferramenta.'),
                        ),
                      );
                      return;
                    }
                    final tool = Tool(
                      id: '',
                      name: _toolNameController.text,
                      quantity: int.parse(_toolQuantityController.text),
                      priority: _selectedPriority,
                      owned: false,
                    );
                    _firebaseService.addTool(tool); // Adiciona a ferramenta à lista de compras no Firebase
                    _toolNameController.clear(); // Limpa o campo de nome
                    _toolQuantityController.clear(); // Limpa o campo de quantidade
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Text('Ferramentas Possuídas',
                    style: Theme.of(context).textTheme.titleLarge), // Título da seção de ferramentas possuídas
                Expanded(
                  child: StreamBuilder<List<Tool>>(
                    stream: _firebaseService.getTools(true), // Obtém ferramentas possuídas do Firebase
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator()); // Indicador de carregamento
                      }
                      final tools = snapshot.data!;
                      return ListView.builder(
                        itemCount: tools.length,
                        itemBuilder: (context, index) {
                          final tool = tools[index];
                          return Card(
                            margin: EdgeInsets.symmetric(
                                vertical: 4, horizontal: 8),
                            color: const Color(0xFFB7B7B7), // Cor de fundo dos cartões de ferramentas
                            child: ListTile(
                              title: Text(tool.name),
                              subtitle: Text('Quantidade: ${tool.quantity}'), // Exibe a quantidade da ferramenta
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () {
                                      _showEditToolDialog(
                                          context, tool, _firebaseService); // Abre o diálogo de edição
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () {
                                      _firebaseService.deleteTool(tool.id); // Exclui a ferramenta
                                    },
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
          ),
          Expanded(
            child: Column(
              children: [
                Text('Ferramentas para Comprar',
                    style: Theme.of(context).textTheme.titleLarge), // Título da seção de ferramentas para comprar
                Expanded(
                  child: StreamBuilder<List<Tool>>(
                    stream: _firebaseService.getTools(false), // Obtém ferramentas para comprar do Firebase
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator()); // Indicador de carregamento
                      }
                      final tools = snapshot.data!;
                      return ListView.builder(
                        itemCount: tools.length,
                        itemBuilder: (context, index) {
                          final tool = tools[index];
                          return Card(
                            margin: EdgeInsets.symmetric(
                                vertical: 4, horizontal: 8),
                            color: const Color(0xFFB7B7B7), // Cor de fundo dos cartões de ferramentas
                            child: ListTile(
                              title: Text(tool.name),
                              subtitle: Text(
                                  'Quantidade: ${tool.quantity}, Prioridade: ${tool.priority}'), // Exibe quantidade e prioridade
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () {
                                      _showEditToolDialog(
                                          context, tool, _firebaseService); // Abre o diálogo de edição
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () {
                                      _firebaseService.deleteTool(tool.id); // Exclui a ferramenta
                                    },
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
          ),
        ],
      ),
    );
  }

  void _showEditToolDialog(
      BuildContext context, Tool tool, FirebaseService firebaseService) {
    final TextEditingController _toolNameController =
        TextEditingController(text: tool.name); // Campo de nome preenchido com o valor atual
    final TextEditingController _toolQuantityController =
        TextEditingController(text: tool.quantity.toString()); // Campo de quantidade preenchido com o valor atual
    String _selectedPriority = tool.priority;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Editar Ferramenta'), // Título do diálogo
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _toolNameController,
                decoration: const InputDecoration(labelText: 'Nome da Ferramenta'), // Campo de entrada de nome
              ),
              TextField(
                controller: _toolQuantityController,
                keyboardType: TextInputType.number, // Campo de entrada numérica
                decoration: const InputDecoration(labelText: 'Quantidade'), // Campo de entrada de quantidade
              ),
              DropdownButton<String>(
                value: _selectedPriority,
                onChanged: (String? newValue) {
                  _selectedPriority = newValue!; // Atualiza a prioridade
                },
                items: <String>['Pouca', 'Média', 'Alta']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop(); // Fecha o diálogo
              },
            ),
            TextButton(
              child: const Text('Salvar'),
              onPressed: () {
                if (_toolNameController.text.isEmpty ||
                    _toolQuantityController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Por favor, insira um nome e uma quantidade para a ferramenta.'),
                    ),
                  );
                  return;
                }
                final updatedTool = Tool(
                  id: tool.id,
                  name: _toolNameController.text,
                  quantity: int.parse(_toolQuantityController.text),
                  priority: _selectedPriority,
                  owned: tool.owned,
                );
                firebaseService.updateTool(updatedTool); // Atualiza a ferramenta no Firebase
                Navigator.of(context).pop(); // Fecha o diálogo
              },
            ),
          ],
        );
      },
    );
  }
}
