class ProductEntity {
  const ProductEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.category,
    required this.finalPriceLak,
    required this.sourceUrl,
  });

  final int id;
  final String name;
  final String description;
  final String imageUrl;
  final String category;
  final double finalPriceLak;
  final String sourceUrl;

  factory ProductEntity.fromJson(Map<String, dynamic> j) {
    final cat = (j['category'] as String?)?.trim();
    return ProductEntity(
      id: (j['id'] as num).toInt(),
      name: j['name'] as String? ?? '',
      description: j['description'] as String? ?? '',
      imageUrl: j['image_url'] as String? ?? '',
      category: (cat != null && cat.isNotEmpty) ? cat : 'ທົ່ວໄປ',
      finalPriceLak: (j['final_price_lak'] as num?)?.toDouble() ?? 0,
      sourceUrl: j['source_url'] as String? ?? '',
    );
  }
}
