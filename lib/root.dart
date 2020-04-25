part of k;

void main() async {
  ///[Hive] would not work in [main()] without this line
  WidgetsFlutterBinding.ensureInitialized();

  ///initiates [Hive] for the main thread
  await BasicDataStorageManager.init();

  // runApp(AudioServiceRoot(
  //   child: Root(),
  // ));
  runApp(MaterialApp(
    home: Scaffold(
      body: SearchPg(),
    ),
  ));
}
