/// Author: Łukasz Piętka (FUT 2025)
enum TrainingPath {
  wspolpraca('Współpraca zewnętrzna', 'WSPOLPRACA'),
  liderska('Kompetencje liderskie', 'LIDERSKA'),
  dydaktyka('Dydaktyka i Socjal', 'DYDAKTYKA'),
  promocja('Promocja i Komunikacja', 'PROMOCJA'),
  wszystkie('Wszystkie Ścieżki', 'null');

  final String label;
  final String backendLabel;

  const TrainingPath(this.label, this.backendLabel);

  static List<TrainingPath> get all => TrainingPath.values;

  factory TrainingPath.pathFromString(String name) {
    return TrainingPath.values.firstWhere(
          (e) => e.backendLabel == name,
      orElse: () => TrainingPath.wspolpraca,
    );
  }
}
