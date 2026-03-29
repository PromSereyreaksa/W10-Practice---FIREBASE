import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../model/songs/song.dart';
import '../../dtos/song_dto.dart';
import 'song_repository.dart';

class SongRepositoryFirebase extends SongRepository {
  List<Song>? _cachedSongs;

  final Uri songsUri = Uri.https(
    'week-8-practice-78755-default-rtdb.asia-southeast1.firebasedatabase.app',
    '/songs.json',
  );

  Uri songUri(String songId) {
    return Uri.https(
      'week-8-practice-78755-default-rtdb.asia-southeast1.firebasedatabase.app',
      '/songs/$songId.json',
    );
  }

  @override
  Future<List<Song>> fetchSongs({bool forceFetch = false}) async {
    if (forceFetch) {
      _cachedSongs = null;
    }

    if (_cachedSongs != null) {
      return _cachedSongs!;
    }

    final http.Response response = await http.get(songsUri);

    if (response.statusCode == 200) {
      // 1 - Send the retrieved list of songs
      Map<String, dynamic> songJson = json.decode(response.body);

      List<Song> result = [];
      for (final entry in songJson.entries) {
        result.add(SongDto.fromJson(entry.key, entry.value));
      }
      _cachedSongs = result;
      return result;
    } else {
      // 2- Throw expcetion if any issue
      throw Exception('Failed to load posts');
    }
  }

  @override
  Future<Song?> fetchSongById(String id) async {}

  @override
  Future<Song> likeSong(Song song) async {
    final int updatedLikes = song.likes + 1;

    final http.Response response = await http.patch(
      songUri(song.id),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({SongDto.likesKey: updatedLikes}),
    );

    if (response.statusCode == 200) {
      final Song updatedSong = song.copyWith(likes: updatedLikes);

      if (_cachedSongs != null) {
        _cachedSongs = _cachedSongs!.map((Song cachedSong) {
          if (cachedSong.id != updatedSong.id) {
            return cachedSong;
          }

          return updatedSong;
        }).toList();
      }

      return updatedSong;
    } else {
      throw Exception('Failed to like song');
    }
  }
}
