import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:epimetheus/widgets/art_image_widget.dart';
import 'package:epimetheus/widgets/progress_widget.dart';
import 'package:flutter/material.dart';

class MediaControlWidget extends StatefulWidget {
  final bool _showHUD;

  const MediaControlWidget([this._showHUD = true]);

  @override
  _MediaControlWidgetState createState() => _MediaControlWidgetState();
}

class _MediaControlWidgetState extends State<MediaControlWidget> {
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        boxShadow: [BoxShadow(blurRadius: 2)],
        borderRadius: const BorderRadius.only(
          topLeft: const Radius.circular(2),
          topRight: const Radius.circular(2),
        ),
      ),
      child: FutureBuilder<bool>(
        initialData: false,
        future: AudioService.running,
        builder: (context, snapshot) {
          if (!snapshot.data) return SizedBox();
          return widget._showHUD
              ? Column(
                  children: [_HUD(), _Buttons()],
                )
              : _Buttons();
        },
      ),
    );
  }
}

class _HUD extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).primaryTextTheme.title.color;
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushReplacementNamed('/now_playing');
      },
      child: StreamBuilder<MediaItem>(
        initialData: AudioService.currentMediaItem,
        stream: AudioService.currentMediaItemStream,
        builder: (context, snapshot) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Row(
              children: [
                ArtImageWidget(snapshot.data.artUri, 72),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        snapshot.data.title,
                        textScaleFactor: 1.1,
                        overflow: TextOverflow.fade,
                        softWrap: false,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        snapshot.data.artist,
                        textScaleFactor: 1.1,
                        overflow: TextOverflow.fade,
                        softWrap: false,
                        style: TextStyle(
                          color: textColor,
                        ),
                      ),
                      SizedBox(height: 2),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              snapshot.data.album,
                              textScaleFactor: 1.1,
                              overflow: TextOverflow.fade,
                              softWrap: false,
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: textColor,
                              ),
                            ),
                          ),
                          SizedBox(width: 2),
                          ProgressWidget(),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Buttons extends StatefulWidget {
  @override
  __ButtonsState createState() => __ButtonsState();
}

class __ButtonsState extends State<_Buttons> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  AnimationController _controller;

  StreamSubscription<PlaybackState> _playbackStateSubscription;

  void startListening() {
    _playbackStateSubscription?.cancel();
    _playbackStateSubscription = AudioService.playbackStateStream.listen((state) {
      if (state.basicState == BasicPlaybackState.paused) {
        _controller.reverse(from: 1);
      } else if (state.basicState == BasicPlaybackState.playing) {
        _controller.forward(from: 0);
      }
    });
  }

  void stopListening() {
    _playbackStateSubscription?.cancel();
    _playbackStateSubscription = null;
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      value: AudioService.playbackState?.basicState == BasicPlaybackState.playing ? 1 : 0,
    );
    startListening();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      startListening();
    } else if (state == AppLifecycleState.paused) {
      stopListening();
    }
  }

  @override
  void dispose() {
    stopListening();
    _controller.dispose();
    super.dispose();
  }

  void playPause() {
    if (AudioService.playbackState.basicState == BasicPlaybackState.paused) {
      AudioService.play();
    } else if (AudioService.playbackState.basicState == BasicPlaybackState.playing) {
      AudioService.pause();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: IconTheme(
        data: IconThemeData(
          color: Theme.of(context).primaryTextTheme.title.color,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const IconButton(
              iconSize: 36,
              icon: Icon(
                Icons.stop,
              ),
              onPressed: AudioService.stop,
            ),
            const IconButton(
              iconSize: 36,
              icon: Icon(
                Icons.fast_rewind,
              ),
              onPressed: AudioService.rewind,
            ),
            IconButton(
              iconSize: 36,
              icon: AnimatedIcon(
                icon: AnimatedIcons.play_pause,
                progress: _controller,
              ),
              onPressed: playPause,
            ),
            const IconButton(
              iconSize: 36,
              icon: Icon(
                Icons.fast_forward,
              ),
              onPressed: AudioService.fastForward,
            ),
            const IconButton(
              iconSize: 36,
              icon: Icon(
                Icons.skip_next,
              ),
              onPressed: AudioService.skipToNext,
            ),
          ],
        ),
      ),
    );
  }
}
