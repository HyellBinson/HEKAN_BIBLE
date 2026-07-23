import 'package:flutter/material.dart';
import 'favorite_service.dart';
import 'package:share_plus/share_plus.dart';
import 'app_state_service.dart';
import 'responsive.dart';



class HymnDetailScreen extends StatefulWidget {
  final String title;
  final String lyrics;
  final int number;

  const HymnDetailScreen({
    super.key,
    required this.title,
    required this.lyrics,
    required this.number,
  });

  @override
  State<HymnDetailScreen> createState() => _HymnDetailScreenState();
}

class _HymnDetailScreenState extends State<HymnDetailScreen> {
  bool isFav = false;
  double fontSize = 18;

  @override
  void initState() {
    super.initState();

    AppStateService.saveHymn(
      number: widget.number,
      title: widget.title,
      lyrics: widget.lyrics,
    );


    checkFav();
    AppStateService.saveHymn(
      number: widget.number,
      title: widget.title,
      lyrics: widget.lyrics,
    );
  }

  void checkFav() async {
    final result = await FavoriteService.isFavorite(widget.number);
    setState(() {
      isFav = result;
    });
  }

  void toggleFav() async {
    final hymn = {
      "number": widget.number,
      "title": widget.title,
      "lyrics": widget.lyrics,
    };
    if (isFav) {
      await FavoriteService.removeFavorite(widget.number);
    } else {
      await FavoriteService.addFavorite(hymn);
    }
    setState(() {
      isFav = !isFav;
    });
  }

  void shareHymn() {
    final text = '''📖 Hymn ${widget.number}
${widget.title}

${widget.lyrics}

Shared from HEKAN Bible App''';
    Share.share(text);
  }

  void increaseFont() {
    setState(() {
      if (fontSize < 30) fontSize += 1;
    });
  }

  void decreaseFont() {
    setState(() {
      if (fontSize > 12) fontSize -= 1;
    });
  }

  void resetFont() {
    setState(() {
      fontSize = 18;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final scale = Responsive.scale(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Hymn ${widget.number}',
          style: TextStyle(
            fontSize: 20 * scale,
          ),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        foregroundColor: theme.textTheme.titleLarge?.color,
        elevation: 0,
        actions: [
          IconButton(
            icon:  Icon(Icons.remove,
              size: 24 * scale,),
            onPressed: decreaseFont,
          ),
          IconButton(
            icon: Icon(Icons.add, size: 24 * scale,),
            onPressed: increaseFont,
          ),
          IconButton(
            icon:Icon(
              Icons.refresh,
              size: 24 * scale,
            ),
            onPressed: resetFont,
          ),
          IconButton(
            onPressed: toggleFav,
            icon: Icon(
              isFav ? Icons.star : Icons.star_border,
              color: isFav ? Colors.amber : theme.hintColor,
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.share,
              size: 24 * scale,
            ),
            onPressed: shareHymn,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(20 * scale),
        child: Column(
          children: [
            Center(
              child: Text(
                widget.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24 * scale,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.titleLarge?.color,
                ),
              ),
            ),
            SizedBox(height: 20 * scale),
            Expanded(
              child: SingleChildScrollView(
                child: SizedBox(
                  width: double.infinity,
                  child: Text(
                    widget.lyrics,
                    textAlign: widget.lyrics.length < 800
                        ? TextAlign.center
                        : TextAlign.left,
                    style: TextStyle(
                      fontSize: fontSize * scale,
                      height: 1.8,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}