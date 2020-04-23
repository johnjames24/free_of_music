part of k.data_layer;

class BasicDataStorageManager {
  ///intiatiates [Hive]
  static init() async {
    final appDocumentDir =
        await path_provider.getApplicationDocumentsDirectory();
    Hive.init(appDocumentDir.path);
  }
}
