/// Domain model representing shopper sensory observation checklist responses.
class SensoryInput {
  final String smell;
  final String texture;
  final String storage;
  final bool skipped;

  const SensoryInput({
    required this.smell,
    required this.texture,
    required this.storage,
    this.skipped = false,
  });

  factory SensoryInput.skipped() => const SensoryInput(
        smell: 'skipped',
        texture: 'skipped',
        storage: 'skipped',
        skipped: true,
      );

  factory SensoryInput.fromJson(Map<String, dynamic> json) {
    return SensoryInput(
      smell: json['smell'] as String? ?? 'fresh_sea',
      texture: json['texture'] as String? ?? 'bounces_back',
      storage: json['storage'] as String? ?? 'packed_in_ice',
      skipped: json['skipped'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'smell': smell,
    'texture': texture,
    'storage': storage,
    'skipped': skipped,
  };
}
