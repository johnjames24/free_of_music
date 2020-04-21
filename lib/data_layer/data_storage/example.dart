part of k;

class DataStorageTesting {
  static testSave() async {
    var box = await Hive.openBox<String>('testBox');
    await box.put("test1", "1st result");
    await box.put("test2", "2st result");
    await box.put("test3", "3st result");
    box.close();
  }

  static testRead() async {
    var box = await Hive.openBox<String>('testBox');

    var test1 = box.get("test1");
    var test2 = box.get("test2");
    var test3 = box.get("test3");

    print('$test1 $test2 $test3');

    await box.close();
  }

  static closeBox() async => Hive.box("testBox").close();
}
