// song_repository_mock.dart

import '../../../model/songs/song.dart';
import 'song_repository.dart';

class SongRepositoryMock implements SongRepository {
  final List<Song> _songs = [];
  List<Song>? _cachedSongs;

  @override
  Future<List<Song>> fetchSongs({bool forceFetch = false}) async {
    if (forceFetch) {
      _cachedSongs = null;
    }

    if (_cachedSongs != null) {
      return _cachedSongs!;
    }

    return Future.delayed(Duration(seconds: 4), () {
      _cachedSongs = List.of(_songs);
      return _cachedSongs!;
    });
  }

  @override
  Future<Song?> fetchSongById(String id) async {
    return Future.delayed(Duration(seconds: 4), () {
      return _songs.firstWhere(
        (song) => song.id == id,
        orElse: () => throw Exception("No song with id $id in the database"),
      );
    });
  }

  @override
  Future<Song> likeSong(Song song) async {
    return Future.delayed(Duration(seconds: 4), () {
      final int songIndex = _songs.indexWhere((item) => item.id == song.id);

      if (songIndex == -1) {
        throw Exception("No song with id ${song.id} in the database");
      }

      final Song updatedSong = _songs[songIndex].copyWith(
        likes: _songs[songIndex].likes + 1,
      );

      _songs[songIndex] = updatedSong;
      if (_cachedSongs != null) {
        _cachedSongs![songIndex] = updatedSong;
      }
      return updatedSong;
    });
  }
}
