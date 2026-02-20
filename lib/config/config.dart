class Config {
  static const String API_URL = String.fromEnvironment(
    'API_URL',
    defaultValue: '',
  );
}
