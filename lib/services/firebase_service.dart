import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/tool.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addTool(Tool tool) async {
    try {
      await _firestore.collection('tools').add(tool.toMap());
      print('Tool added: ${tool.name}');
    } catch (e) {
      print('Failed to add tool: $e');
    }
  }

  Future<void> updateTool(Tool tool) async {
    try {
      await _firestore.collection('tools').doc(tool.id).update(tool.toMap());
      print('Tool updated: ${tool.name}');
    } catch (e) {
      print('Failed to update tool: $e');
    }
  }

  Future<void> deleteTool(String id) async {
    try {
      await _firestore.collection('tools').doc(id).delete();
      print('Tool deleted with id: $id');
    } catch (e) {
      print('Failed to delete tool: $e');
    }
  }

  // Método para obter ferramentas do Firestore
  Stream<List<Tool>> getTools(bool owned) {
    return _firestore
        .collection('tools')
        .where('owned', isEqualTo: owned)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs
            .map((doc) => Tool.fromMap(doc.data(), doc.id))
            .toList());
  }
}