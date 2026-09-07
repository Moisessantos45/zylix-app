class Config {
  static const String API_URL = String.fromEnvironment(
    'API_URL_V3',
    defaultValue: '',
  );
}
