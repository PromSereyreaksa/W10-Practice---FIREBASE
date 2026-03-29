import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/repositories/artist/artist_repository.dart';
import '../../../model/artist/artist.dart';
import '../../states/player_state.dart';
import 'view_model/artist_view_model.dart';
import 'widgets/artist_content.dart';

class ArtistScreen extends StatelessWidget {
  const ArtistScreen({super.key, required this.artist});

  final Artist artist;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ArtistViewModel(
        artistRepository: context.read<ArtistRepository>(),
        playerState: context.read<PlayerState>(),
        artist: artist,
      ),
      child: ArtistContent(artist: artist),
    );
  }
}
