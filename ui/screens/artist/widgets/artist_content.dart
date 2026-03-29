import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../model/artist/artist.dart';
import '../../../theme/theme.dart';
import '../../../utils/async_value.dart';
import '../../../widgets/song/song_tile.dart';
import '../view_model/artist_view_model.dart';
import 'comment_tile.dart';

class ArtistContent extends StatelessWidget {
  const ArtistContent({super.key, required this.artist});

  final Artist artist;

  @override
  Widget build(BuildContext context) {
    ArtistViewModel mv = context.watch<ArtistViewModel>();

    Widget body;
    switch (mv.dataValue.state) {
      case AsyncValueState.loading:
        body = Center(child: CircularProgressIndicator());
        break;
      case AsyncValueState.error:
        body = Center(
          child: Text(
            'error = ${mv.dataValue.error!}',
            style: TextStyle(color: Colors.red),
          ),
        );
        break;
      case AsyncValueState.success:
        body = RefreshIndicator(
          onRefresh: () => mv.fetchData(forceFetch: true),
          child: ListView(
            physics: AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20.0),
            children: [
              SizedBox(height: 16),
              Text(artist.name, style: AppTextStyles.heading),
              SizedBox(height: 12),
              Text("Genre: ${artist.genre}", style: AppTextStyles.title),
              SizedBox(height: 30),
              Text("Songs", style: AppTextStyles.title),
              SizedBox(height: 10),
              if (mv.songs.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text("No songs found for this artist."),
                ),
              ...mv.songs.map(
                (song) => SongTile(
                  song: song,
                  isPlaying: mv.isSongPlaying(song),
                  onTap: () {
                    mv.start(song);
                  },
                ),
              ),
              SizedBox(height: 20),
              Text("Comments", style: AppTextStyles.title),
              SizedBox(height: 10),
              if (mv.comments.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text("No comments yet for this artist."),
                ),
              ...mv.comments.map(
                (comment) => CommentTile(comment: comment),
              ),
              SizedBox(height: 100),
            ],
          ),
        );
        break;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(artist.name),
        backgroundColor: Colors.white,
      ),
      body: body,
      bottomNavigationBar: SafeArea(
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (mv.commentError != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Text(
                    '${mv.commentError}',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: mv.commentController,
                      decoration: InputDecoration(
                        hintText: 'Write a comment',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      mv.addComment();
                    },
                    child: Text('Post'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
