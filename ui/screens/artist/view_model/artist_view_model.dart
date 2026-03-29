import 'package:flutter/material.dart';

import '../../../../data/repositories/artist/artist_repository.dart';
import '../../../../model/artist/artist.dart';
import '../../../../model/comment/comment.dart';
import '../../../../model/songs/song.dart';
import '../../../states/player_state.dart';
import '../../../utils/async_value.dart';

class ArtistViewModel extends ChangeNotifier {
  final ArtistRepository artistRepository;
  final PlayerState playerState;
  final Artist artist;

  final TextEditingController commentController = TextEditingController();

  AsyncValue<void> dataValue = AsyncValue<void>.loading();
  List<Song> songs = [];
  List<Comment> comments = [];
  Object? commentError;

  ArtistViewModel({
    required this.artistRepository,
    required this.playerState,
    required this.artist,
  }) {
    playerState.addListener(notifyListeners);
    _init();
  }

  @override
  void dispose() {
    playerState.removeListener(notifyListeners);
    commentController.dispose();
    super.dispose();
  }

  void _init() async {
    fetchData();
  }

  Future<void> fetchData({bool forceFetch = false}) async {
    dataValue = AsyncValue<void>.loading();
    commentError = null;
    notifyListeners();

    try {
      songs = await artistRepository.fetchArtistSongs(
        artist.id,
        forceFetch: forceFetch,
      );
      comments = await artistRepository.fetchArtistComments(
        artist.id,
        forceFetch: forceFetch,
      );
      dataValue = AsyncValue<void>.success(null);
    } catch (e) {
      dataValue = AsyncValue<void>.error(e);
    }

    notifyListeners();
  }

  Future<void> addComment() async {
    final String message = commentController.text.trim();

    if (message.isEmpty) {
      commentError = 'Comment cannot be empty';
      notifyListeners();
      return;
    }

    try {
      final Comment comment = await artistRepository.postArtistComment(
        artist.id,
        message,
      );

      comments = [...comments, comment];
      commentController.clear();
      commentError = null;
    } catch (e) {
      commentError = e;
    }

    notifyListeners();
  }

  bool isSongPlaying(Song song) => playerState.currentSong?.id == song.id;

  void start(Song song) => playerState.start(song);
}
