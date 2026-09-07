int compareVersions(String a, String b) {
  final cleanA = a.replaceAll(RegExp(r'[^0-9.]'), '');
  final cleanB = b.replaceAll(RegExp(r'[^0-9.]'), '');

  final partsA = cleanA.split('.').map((e) => int.tryParse(e) ?? 0).toList();
  final partsB = cleanB.split('.').map((e) => int.tryParse(e) ?? 0).toList();

  final maxLength = partsA.length > partsB.length
      ? partsA.length
      : partsB.length;

  for (var i = 0; i < maxLength; i++) {
    final aPart = i < partsA.length ? partsA[i] : 0;
    final bPart = i < partsB.length ? partsB[i] : 0;
    if (aPart != bPart) {
      return aPart.compareTo(bPart);
    }
  }
  
  return 0;
}

String extractVersionFromName(String fileName) {
  final regExp = RegExp(r'(\d+\.\d+(\.\d+)?)');
  final match = regExp.firstMatch(fileName);
  return match != null ? match.group(0)! : '';
}
