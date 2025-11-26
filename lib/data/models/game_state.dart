class GameState {
  final double fuel; // 0..100
  final int tires; // vidas
  final int score;
  final int laneIndex; // 0..lanesCount-1
  final bool isGameOver;

  const GameState({
    required this.fuel,
    required this.tires,
    required this.score,
    required this.laneIndex,
    required this.isGameOver,
  });

  GameState copyWith({
    double? fuel,
    int? tires,
    int? score,
    int? laneIndex,
    bool? isGameOver,
  }) => GameState(
    fuel: fuel ?? this.fuel,
    tires: tires ?? this.tires,
    score: score ?? this.score,
    laneIndex: laneIndex ?? this.laneIndex,
    isGameOver: isGameOver ?? this.isGameOver,
  );
}
