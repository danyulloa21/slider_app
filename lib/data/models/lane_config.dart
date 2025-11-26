class LaneConfig {
  final int lanesCount; // 2..5
  final double laneWidth; // calculado en runtime
  final double carWidth; // laneWidth / 1.1 (respeta 1.1 del carril)

  LaneConfig({
    required this.lanesCount,
    required this.laneWidth,
    required this.carWidth,
  });
}
