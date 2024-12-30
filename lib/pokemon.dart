class Pokemon {
  final String name;
  final int weight;
  final int height;
  final String spriteUrl;

  Pokemon({
    required this.name,
    required this.weight,
    required this.height,
    required this.spriteUrl,
  });

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    return Pokemon(
      name: json['name'],
      weight: json['weight'],
      height: json['height'],
      spriteUrl: json['sprites']['other']['official-artwork']['front_default'] ?? '', // URL de la imagen
    );
  }
}
