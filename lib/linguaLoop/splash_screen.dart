import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:ui';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  VideoPlayerController? _videoController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _isVideoInitialized = false;
  bool _isDisposed = false;
  Timer? _timeoutTimer;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeVideo();
    _setNavigationTimeout();
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
        if (!_isVideoInitialized && !_isDisposed) {
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

      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
        });
      }

      // Start fade in animation
      _fadeController.forward();

      // Set video properties
      await _videoController!.setLooping(false);
      await _videoController!.setVolume(0.0);

      // Mulai video
      await _videoController!.play();

      // Listen untuk video selesai
      _videoController!.addListener(_checkVideoCompletion);
    } catch (error) {
      print('Error initializing video: $error');
      _timeoutTimer?.cancel();
      if (!_isDisposed) {
        _showFallbackSplash();
      }
    }
  }

  void _checkVideoCompletion() {
    if (_videoController != null &&
        _videoController!.value.position >= _videoController!.value.duration &&
        !_hasNavigated) {
      _navigateToLogin();
    }
  }

  void _showFallbackSplash() {
    if (_isDisposed) return;

    if (mounted) {
      setState(() {
        _isVideoInitialized = false;
      });
    }
    _fadeController.forward();

    // Jika menggunakan fallback, tunggu 3 detik lalu navigate
    Timer(const Duration(seconds: 3), () {
      if (!_hasNavigated) {
        _navigateToLogin();
      }
    });
  }

  void _setNavigationTimeout() {
    // Jika video tidak dimulai dalam 6 detik, langsung navigate
    Timer(const Duration(seconds: 6), () {
      if (!_hasNavigated) {
        _navigateToLogin();
      }
    });
  }

  Future<void> _navigateToLogin() async {
    if (_hasNavigated || _isDisposed) return;
    _hasNavigated = true;

    try {
      if (!mounted) return;

      // Fade out animation sebelum navigate
      await _fadeController.reverse();

      if (!mounted) return;

      // SELALU ke Login Screen
      Navigator.of(context).pushReplacementNamed('/login');
    } catch (e) {
      print('Error navigating: $e');
      // Fallback ke login jika ada error
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _timeoutTimer?.cancel();

    if (_videoController != null) {
      _videoController!.removeListener(_checkVideoCompletion);
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
                  Color(0xFF667eea),
                  Color(0xFF764ba2),
                  Color(0xFFF093FB),
                ],
              ),
            ),
          ),

          // Video player di bagian tengah
          if (_isVideoInitialized && _videoController != null)
            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  width: screenSize.width * 0.5,
                  height: screenSize.width * 0.5,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: FittedBox(
                      fit: BoxFit.cover,
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

          // Overlay gelap untuk readability
          if (_isVideoInitialized)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.transparent,
                    Colors.black.withOpacity(0.4),
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
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
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
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: const Icon(
                            Icons.analytics_outlined,
                            size: 60,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // App title
                    const Text(
                      'STATISTIK',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 4,
                        shadows: [
                          Shadow(
                            offset: Offset(0, 3),
                            blurRadius: 10,
                            color: Colors.black54,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Subtitle
                    const Text(
                      'Data Indonesia Terpercaya',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 1,
                        shadows: [
                          Shadow(
                            offset: Offset(0, 2),
                            blurRadius: 4,
                            color: Colors.black45,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 50),

                    // Loading indicator
                    const SizedBox(
                      width: 50,
                      height: 50,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Memuat aplikasi...',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white60,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Text branding di bawah video
          if (_isVideoInitialized)
            Positioned(
              bottom: 120,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    const Text(
                      'STATISTIK',
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 4,
                        shadows: [
                          Shadow(
                            offset: Offset(0, 2),
                            blurRadius: 8,
                            color: Colors.black54,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Data Indonesia Terpercaya',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 1,
                        shadows: [
                          Shadow(
                            offset: Offset(0, 2),
                            blurRadius: 4,
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
              bottom: 80,
              left: 40,
              right: 40,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: VideoProgressIndicator(
                      _videoController!,
                      allowScrubbing: false,
                      colors: const VideoProgressColors(
                        playedColor: Colors.white,
                        bufferedColor: Colors.white38,
                        backgroundColor: Colors.white24,
                      ),
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