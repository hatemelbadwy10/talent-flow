


abstract class Constants {
  static const int zegoAppID =
  1435623513;
  static const String zegoAppSign =
      'e276bd2e0eea30e1e27efaead6967e385f2006870f7c32ebce38e05b8300cdec';
  static const String zegoServerSecret =
      '94e584ad35bf897c2e6622a37d838b64';
}



enum LayoutMode {
  defaultLayout,
  full,
  horizontal,
  vertical,
  hostTopCenter,
  hostCenter,
  fourPeoples,
}

extension LayoutModeExtension on LayoutMode {
  String get text {
    final mapValues = {
      LayoutMode.defaultLayout: 'default',
      LayoutMode.full: 'full',
      LayoutMode.horizontal: 'horizontal',
      LayoutMode.vertical: 'vertical',
      LayoutMode.hostTopCenter: 'host top center',
      LayoutMode.hostCenter: 'host center',
      LayoutMode.fourPeoples: 'four peoples',
    };

    return mapValues[this]!;
  }
}
