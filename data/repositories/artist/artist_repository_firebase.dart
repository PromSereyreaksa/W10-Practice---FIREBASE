import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../model/artist/artist.dart';
import '../../dtos/artist_dto.dart';
import 'artist_repository.dart';

class ArtistRepositoryFirebase implements ArtistRepository {
  List<Artist>? _cachedArtists;

  final Uri artistsUri = Uri.https(
    'week-8-practice-78755-default-rtdb.asia-southeast1.firebasedatabase.app',
    '/artists.json',
  );

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
}
