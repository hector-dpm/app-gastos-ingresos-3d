import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/material_model.dart';

class MaterialProvider with ChangeNotifier {
  List<MaterialModel> _materials = [];

  List<MaterialModel> get materials => _materials;

  Future<void> loadMaterials() async {
    _materials = await DatabaseHelper.instance.readAllMaterials();
    notifyListeners();
  }

  Future<void> addMaterial(MaterialModel material) async {
    await DatabaseHelper.instance.createMaterial(material);
    await loadMaterials();
  }

  Future<void> updateMaterial(MaterialModel material) async {
    await DatabaseHelper.instance.updateMaterial(material);
    await loadMaterials();
  }

  Future<void> deleteMaterial(int id) async {
    await DatabaseHelper.instance.deleteMaterial(id);
    await loadMaterials();
  }
}
