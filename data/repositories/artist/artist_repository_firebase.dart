import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../model/artist/artist.dart';
import '../../../model/comment/comment.dart';
import '../../../model/songs/song.dart';
import '../../dtos/artist_dto.dart';
import '../../dtos/comment_dto.dart';
import '../../dtos/song_dto.dart';
import 'artist_repository.dart';

class ArtistRepositoryFirebase implements ArtistRepository {
  List<Artist>? _cachedArtists;
  List<Song>? _cachedSongs;
  final Map<String, List<Comment>> _cachedCommentsByArtistId = {};

  final Uri artistsUri = Uri.https(
    'week-8-practice-78755-default-rtdb.asia-southeast1.firebasedatabase.app',
    '/artists.json',
  );
  final Uri songsUri = Uri.https(
    'week-8-practice-78755-default-rtdb.asia-southeast1.firebasedatabase.app',
    '/songs.json',
  );

  Uri artistCommentsUri(String artistId) {
    return Uri.https(
      'week-8-practice-78755-default-rtdb.asia-southeast1.firebasedatabase.app',
      '/comments/$artistId.json',
    );
  }

  @override
  Future<List<Artist>> fetchArtists({bool forceFetch = false}) async {
    if (forceFetch) {
      _cachedArtists = null;
    }

    if (_cachedArtists != null) {
      return _cachedArtists!;
    }

    final http.Response response = await http.get(artistsUri);

    if (response.statusCode == 200) {
      // 1 - Send the retrieved list of songs
      Map<String, dynamic> songJson = json.decode(response.body);

      List<Artist> result = [];
      for (final entry in songJson.entries) {
        result.add(ArtistDto.fromJson(entry.key, entry.value));
      }
      _cachedArtists = result;
      return result;
    } else {
      // 2- Throw expcetion if any issue
      throw Exception('Failed to load posts');
    }
  }

  @override
  Future<Artist?> fetchArtistById(String id) async {}

  @override
  Future<List<Song>> fetchArtistSongs(
    String artistId, {
    bool forceFetch = false,
  }) async {
    if (forceFetch) {
      _cachedSongs = null;
    }

    if (_cachedSongs == null) {
      final http.Response response = await http.get(songsUri);

      if (response.statusCode == 200) {
        if (response.body == 'null') {
          _cachedSongs = [];
        } else {
          Map<String, dynamic> songJson = json.decode(response.body);

          List<Song> result = [];
          for (final entry in songJson.entries) {
            result.add(SongDto.fromJson(entry.key, entry.value));
          }
          _cachedSongs = result;
        }
      } else {
        throw Exception('Failed to load songs');
      }
    }

    return _cachedSongs!
        .where((Song song) => song.artistId == artistId)
        .toList();
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

    final http.Response response = await http.get(artistCommentsUri(artistId));

    if (response.statusCode == 200) {
      if (response.body == 'null') {
        _cachedCommentsByArtistId[artistId] = [];
        return [];
      }

      Map<String, dynamic> commentJson = json.decode(response.body);

      List<Comment> result = [];
      for (final entry in commentJson.entries) {
        result.add(CommentDto.fromJson(entry.key, entry.value));
      }

      result.sort((Comment a, Comment b) => a.createdAt.compareTo(b.createdAt));
      _cachedCommentsByArtistId[artistId] = result;
      return result;
    } else {
      throw Exception('Failed to load comments');
    }
  }

  @override
  Future<Comment> postArtistComment(String artistId, String message) async {
    final Comment comment = Comment(
      id: '',
      message: message,
      createdAt: DateTime.now(),
    );

    final http.Response response = await http.post(
      artistCommentsUri(artistId),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(CommentDto.toJson(comment)),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> result = json.decode(response.body);
      final String commentId = result['name'];
      final Comment createdComment = Comment(
        id: commentId,
        message: comment.message,
        createdAt: comment.createdAt,
      );

      final List<Comment> comments = List.of(
        _cachedCommentsByArtistId[artistId] ?? [],
      );
      comments.add(createdComment);
      _cachedCommentsByArtistId[artistId] = comments;

      return createdComment;
    } else {
      throw Exception('Failed to post comment');
    }
  }
}
