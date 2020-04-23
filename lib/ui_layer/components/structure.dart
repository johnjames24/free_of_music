part of k.ui_layer;

class Structure extends StatelessWidget {
  final Widget child;

  Structure({
    @required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(items: [
        BottomNavigationBarItem(icon: Icon(Icons.ac_unit), title: Text("test")),
        BottomNavigationBarItem(icon: Icon(Icons.ac_unit), title: Text("test")),
        BottomNavigationBarItem(icon: Icon(Icons.ac_unit), title: Text("test")),
      ]),
      body: Stack(
        children: <Widget>[
          SafeArea(
            child: child,
          ),
          Column(
            children: <Widget>[Spacer(), MiniMusicPlayer()],
          )
        ],
      ),
    );
  }
}
