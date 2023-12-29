import 'package:distribution/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:transition/transition.dart';
import 'package:video_player/video_player.dart';

class MediaView extends StatefulWidget {
  final bool isMovie;
  final String sourceUrl;
  const MediaView({
    Key? key,
    required this.sourceUrl,
    required this.isMovie
  }) : super(key: key);

  @override
  State<MediaView> createState() => _MediaViewState();
}

class _MediaViewState extends State<MediaView> {
  late VideoPlayerController _controller;
  late Future <void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    if(widget.isMovie) {
      // VideoPlayerController를 저장하기 위한 변수를 만듭니다. VideoPlayerController는
      // asset, 파일, 인터넷 등의 영상들을 제어하기 위해 다양한 생성자를 제공합니다.
      _controller = VideoPlayerController.network(widget.sourceUrl);
      //'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4'

      // 컨트롤러를 초기화하고 추후 사용하기 위해 Future를 변수에 할당합니다.
      _initializeVideoPlayerFuture = _controller.initialize();

      // 비디오를 반복 재생하기 위해 컨트롤러를 사용합니다.
      _controller.setLooping(true);
      _controller.play();
    }
    super.initState();
  }

  @override
  void dispose() {
    if(widget.isMovie) {
      // 자원을 반환하기 위해 VideoPlayerController를 dispose 시키세요.
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if(widget.isMovie) {
      return Stack(
        children: [
          Center(
              child: FutureBuilder(
                future: _initializeVideoPlayerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    // 만약 VideoPlayerController 초기화가 끝나면, 제공된 데이터를 사용하여
                    // VideoPlayer의 종횡비를 제한하세요.
                    return AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      // 영상을 보여주기 위해 VideoPlayer 위젯을 사용합니다.
                      child: GestureDetector(
                        onTap: () {
                          _showFullScren();
                        },
                        child: VideoPlayer(_controller),
                      ),
                    );
                  } else {
                    // 만약 VideoPlayerController가 여전히 초기화 중이라면,
                    // 로딩 스피너를 보여줍니다.
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              )
          )
        ],
      );
    }

    return Center(
        child:Container(
            child: simpleBlurImage(widget.sourceUrl, 1.0))
    );
  }

  void _showFullScren() {
    Navigator.push(
      context,
      Transition(
          child: ShowVideo(sourceUrl: widget.sourceUrl,),
          transitionEffect: TransitionEffect.RIGHT_TO_LEFT),
    );
  }
}


class ShowVideo extends StatefulWidget {
  final String sourceUrl;
  const ShowVideo({Key? key, required this.sourceUrl}) : super(key: key);

  @override
  State<ShowVideo> createState() => _ShowVideoState();
}

class _ShowVideoState extends State<ShowVideo> {
  late VideoPlayerController _controller;
  late Future <void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    // VideoPlayerController를 저장하기 위한 변수를 만듭니다. VideoPlayerController는
    // asset, 파일, 인터넷 등의 영상들을 제어하기 위해 다양한 생성자를 제공합니다.
    _controller = VideoPlayerController.network(widget.sourceUrl);
    //'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4'

    // 컨트롤러를 초기화하고 추후 사용하기 위해 Future를 변수에 할당합니다.
    _initializeVideoPlayerFuture = _controller.initialize();

    // 비디오를 반복 재생하기 위해 컨트롤러를 사용합니다.
    _controller.setLooping(true);
    _controller.play();

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
          slivers: [
            _renderSliverAppbar(),
            _renderVideo(),
          ]
        ),
    );
  }

  SliverAppBar _renderSliverAppbar() {
    return SliverAppBar(
        floating: true,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        //pinned: true,
        //title: const Text("상품정보"),
        leading: IconButton(
            icon: Image.asset(
              "assets/icon/top_back.png",
              height: 32,
              fit: BoxFit.fitHeight,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
            }
        ),
        //expandedHeight: 70
    );
  }

  SliverList _renderVideo() {
    return SliverList(
        delegate: SliverChildListDelegate([
          Container(
            //padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
            color: Colors.black,
            child: Center(
              child: FutureBuilder(
              future: _initializeVideoPlayerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  // 만약 VideoPlayerController 초기화가 끝나면, 제공된 데이터를 사용하여
                  // VideoPlayer의 종횡비를 제한하세요.
                  return AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller)
                  );
                } else {
                  // 만약 VideoPlayerController가 여전히 초기화 중이라면,
                  // 로딩 스피너를 보여줍니다.
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
            )
          )
        ])
    );
  }
}
