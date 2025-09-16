import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:ui';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  VideoPlayerController? _videoController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _isVideoInitialized = false;
  bool _hasNavigated = false;
  bool _isDisposed = false;
  Timer? _timeoutTimer;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeVideo();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
  }

  void _initializeVideo() async {
    try {
      if (_isDisposed) return;

      // Set timeout untuk video loading (5 detik)
      _timeoutTimer = Timer(const Duration(seconds: 5), () {
        if (!_isVideoInitialized && !_hasNavigated) {
          print('Video loading timeout, using fallback');
          _showFallbackSplash();
        }
      });

      _videoController = VideoPlayerController.asset(
        'assets/animations/ringan.mp4',
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: false,
          allowBackgroundPlayback: false,
        ),
      );

      await _videoController!.initialize();

      if (_isDisposed) return;

      _timeoutTimer?.cancel();

      setState(() {
        _isVideoInitialized = true;
      });

      // Start fade in animation
      _fadeController.forward();

      // Set video to loop untuk durasi lebih lama
      await _videoController!.setLooping(true);
      await _videoController!.setVolume(0.0); // Mute video

      // Mulai video
      await _videoController!.play();

      // Add listener
      _videoController!.addListener(_videoListener);

      // Auto navigate after video ends or max 8 seconds
      Timer(const Duration(seconds: 5), () {
        if (!_hasNavigated) {
          _navigateToNextScreen();
        }
      });
    } catch (error) {
      print('Error initializing video: $error');
      _timeoutTimer?.cancel();
      if (!_isDisposed) {
        _showFallbackSplash();
      }
    }
  }

  void _videoListener() {
    if (_isDisposed || _videoController == null) return;

    if (_videoController!.value.position >= _videoController!.value.duration &&
        _videoController!.value.duration > Duration.zero &&
        !_hasNavigated) {
      _navigateToNextScreen();
    }
  }

  void _navigateToNextScreen() {
    if (_hasNavigated || _isDisposed) return;
    _hasNavigated = true;

    // Fade out animation sebelum navigasi
    _fadeController.reverse().then((_) {
      if (!_isDisposed && mounted) {
        // Uncomment dan ganti dengan screen tujuan Anda
        // Navigator.pushReplacement(
        //   context,
        //   PageRouteBuilder(
        //     pageBuilder: (context, animation, secondaryAnimation) => HomeScreen(),
        //     transitionDuration: const Duration(milliseconds: 500),
        //     transitionsBuilder: (context, animation, secondaryAnimation, child) {
        //       return FadeTransition(opacity: animation, child: child);
        //     },
        //   ),
        // );

        // Untuk demo, print pesan
        print('Navigating to next screen...');
      }
    });
  }

  void _showFallbackSplash() {
    if (_isDisposed) return;

    _fadeController.forward();
    Future.delayed(const Duration(seconds: 5), () {
      if (!_hasNavigated && !_isDisposed) {
        _navigateToNextScreen();
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _timeoutTimer?.cancel();

    if (_videoController != null) {
      _videoController!.removeListener(_videoListener);
      _videoController!.pause();
      _videoController!.dispose();
    }

    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background gradient sebagai fallback
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0D47A1),
                  Color(0xFF1976D2),
                  Color(0xFF42A5F5),
                ],
              ),
            ),
          ),

          // Video player di bagian atas
          if (_isVideoInitialized && _videoController != null)
            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  width: screenSize.width * 0.5, // 70% lebar layar
                  height: screenSize.width * 0.5, // tinggi e=lebar
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: FittedBox(
                      fit: BoxFit.cover, // isi penuh kotak persegi
                      child: SizedBox(
                        width: _videoController!.value.size.width,
                        height: _videoController!.value.size.height,
                        child: VideoPlayer(_videoController!),
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // Overlay gelap ringan untuk readability text
          if (_isVideoInitialized)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.2),
                    Colors.transparent,
                    Colors.black.withOpacity(0.3),
                  ],
                ),
              ),
            ),

          // Loading state atau fallback content
          if (!_isVideoInitialized)
            FadeTransition(
              opacity: _fadeAnimation,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo container
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.2),
                            Colors.white.withOpacity(0.1),
                          ],
                        ),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                          child: const Icon(
                            Icons.analytics_outlined,
                            size: 50,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // App title dengan shadow
                    const Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: Column(
                        children: [
                          Text(
                            'STATISTIK',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 3,
                              shadows: [
                                Shadow(
                                  offset: Offset(0, 2),
                                  blurRadius: 8,
                                  color: Colors.black54,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 12),

                          // Subtitle
                          Text(
                            'Data Indonesia Terpercaya',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white70,
                              fontWeight: FontWeight.w300,
                              shadows: [
                                Shadow(
                                  offset: Offset(0, 1),
                                  blurRadius: 1,
                                  color: Colors.black45,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 40),

                          // Loading indicator
                          SizedBox(
                            width: 40,
                            height: 40,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Text branding di bawah video
          if (_isVideoInitialized)
            Positioned(
              bottom: 150,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: const Column(
                  children: [
                    Text(
                      'STATISTIK',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 3,
                        shadows: [
                          Shadow(
                            offset: Offset(1, 1),
                            blurRadius: 4,
                            color: Colors.black54,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Data Indonesia Terpercaya',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                        fontWeight: FontWeight.w300,
                        shadows: [
                          Shadow(
                            offset: Offset(1, 1),
                            blurRadius: 3,
                            color: Colors.black54,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Progress indicator untuk video
          if (_isVideoInitialized && _videoController != null)
            Positioned(
              bottom: 100,
              left: 60,
              right: 60,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: VideoProgressIndicator(
                    _videoController!,
                    allowScrubbing: false,
                    colors: const VideoProgressColors(
                      playedColor: Colors.white,
                      bufferedColor: Colors.white30,
                      backgroundColor: Colors.white12,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
