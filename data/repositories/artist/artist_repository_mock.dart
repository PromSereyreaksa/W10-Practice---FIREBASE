import '../../../model/artist/artist.dart';
import '../../../model/comment/comment.dart';
import '../../../model/songs/song.dart';
import 'artist_repository.dart';

class ArtistRepositoryMock implements ArtistRepository {
  final List<Artist> _artists = [];
  final List<Song> _songs = [];
  final Map<String, List<Comment>> _commentsByArtistId = {};
  List<Artist>? _cachedArtists;
  List<Song>? _cachedSongs;
  final Map<String, List<Comment>> _cachedCommentsByArtistId = {};

  @override
  Future<List<Artist>> fetchArtists({bool forceFetch = false}) async {
    if (forceFetch) {
      _cachedArtists = null;
    }

    if (_cachedArtists != null) {
      return _cachedArtists!;
    }

    return Future.delayed(Duration(seconds: 4), () {
      _cachedArtists = List.of(_artists);
      return _cachedArtists!;
    });
  }

  @override
  Future<Artist?> fetchArtistById(String id) async {
    return Future.delayed(Duration(seconds: 4), () {
      return _artists.firstWhere(
        (artist) => artist.id == id,
        orElse: () => throw Exception("No artist with id $id in the database"),
      );
    });
  }

  @override
  Future<List<Song>> fetchArtistSongs(
    String artistId, {
    bool forceFetch = false,
  }) async {
    if (forceFetch) {
      _cachedSongs = null;
    }

    if (_cachedSongs != null) {
      return _cachedSongs!
          .where((Song song) => song.artistId == artistId)
          .toList();
    }

    return Future.delayed(Duration(seconds: 4), () {
      _cachedSongs = List.of(_songs);
      return _cachedSongs!
          .where((Song song) => song.artistId == artistId)
          .toList();
    });
  }

  @override
  Future<List<Comment>> fetchArtistComments(
    String artistId, {
    bool forceFetch = false,
  }) async {
    if (forceFetch) {
      _cachedCommentsByArtistId.remove(artistId);
    }

    if (_cachedCommentsByArtistId[artistId] != null) {
      return _cachedCommentsByArtistId[artistId]!;
    }

    return Future.delayed(Duration(seconds: 4), () {
      final List<Comment> comments = List.of(_commentsByArtistId[artistId] ?? []);
      _cachedCommentsByArtistId[artistId] = comments;
      return comments;
    });
  }

  @override
  Future<Comment> postArtistComment(String artistId, String message) async {
    return Future.delayed(Duration(seconds: 4), () {
      final Comment comment = Comment(
        id: 'comment_${DateTime.now().millisecondsSinceEpoch}',
        message: message,
        createdAt: DateTime.now(),
      );

      final List<Comment> comments = List.of(_commentsByArtistId[artistId] ?? []);
      comments.add(comment);
      _commentsByArtistId[artistId] = comments;
      _cachedCommentsByArtistId[artistId] = List.of(comments);
      return comment;
    });
  }
}
