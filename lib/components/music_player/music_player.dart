part of k;

class MusicPlayer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Text("player"),
      ),
    );
  }
}
