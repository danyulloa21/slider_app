class CarModel {
  final String id;
  final String name;
  final String assetPath; // assets/cars/...
  final double baseWidthRatio; // respecto al ancho de pantalla

  const CarModel({
    required this.id,
    required this.name,
    required this.assetPath,
    this.baseWidthRatio = 0.18, // ej: 18% del ancho
  });

  @override
  String toString() {
    super.toString();
    return 'CarModel(id: $id, name: $name), assetPath: $assetPath), baseWidthRatio: $baseWidthRatio';
  }
}
