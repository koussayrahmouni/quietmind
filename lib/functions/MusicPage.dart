import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class MusicPage extends StatefulWidget {
  const MusicPage({Key? key}) : super(key: key);

  @override
  State<MusicPage> createState() => _MusicPageState();
}

class _MusicPageState extends State<MusicPage>
    with TickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;
  bool bluetoothReady = false;
  late AnimationController _rotationController;
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late Animation<double> _buttonScaleAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _initBluetooth();
  }

  void _initAnimations() {
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();

    _buttonScaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  Future<void> _initBluetooth() async {
    await _requestPermissions();
    
    if (!(await FlutterBluePlus.isSupported)) {
      _showError('Bluetooth not supported');
      return;
    }

    final state = await FlutterBluePlus.adapterState.first;
    if (state != BluetoothAdapterState.on) {
      _showError('Turn on Bluetooth');
      return;
    }

    setState(() => bluetoothReady = true);
  }

  Future<void> _requestPermissions() async {
    await Permission.bluetooth.request();
    await Permission.bluetoothScan.request();
    await Permission.bluetoothConnect.request();
    await Permission.locationWhenInUse.request();
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (_) => ScaleTransition(
        scale: CurvedAnimation(
          parent: _scaleController,
          curve: Curves.easeInOutBack,
        ),
        child: AlertDialog(
          title: const Text('Bluetooth Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            )
          ],
        ),
      ),
    );
  }

  void _togglePlay() async {
    if (!bluetoothReady) {
      _showError('Bluetooth not ready');
      return;
    }

    setState(() {
      isPlaying ? _rotationController.stop() : _rotationController.repeat();
      isPlaying = !isPlaying;
    });

    isPlaying
        ? await _audioPlayer.play(AssetSource('audio/chanson2.mp3'))
        : await _audioPlayer.pause();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _scaleController.dispose();
    _fadeController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Music Player'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      extendBodyBehindAppBar: true,
      body: FadeTransition(
        opacity: _fadeController,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.deepPurple, Colors.indigo],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ScaleTransition(
                  scale: _scaleController,
                  child: RotationTransition(
                    turns: _rotationController,
                    child: const Icon(
                      Icons.graphic_eq,
                      size: 150,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  transitionBuilder: (child, animation) => ScaleTransition(
                    scale: animation,
                    child: child,
                  ),
                  child: bluetoothReady
                      ? GestureDetector(
                          onTapDown: (_) => _scaleController.forward(),
                          onTapUp: (_) => _scaleController.reverse(),
                          onTap: _togglePlay,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: isPlaying ? Colors.red : Colors.green,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                )
                              ],
                            ),
                            child: AnimatedIcon(
                              icon: AnimatedIcons.play_pause,
                              progress: _scaleController,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : const PulseAlertWidget(),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Now Playing',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 20,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Chanson 1',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PulseAlertWidget extends StatefulWidget {
  const PulseAlertWidget({Key? key}) : super(key: key);

  @override
  State<PulseAlertWidget> createState() => _PulseAlertWidgetState();
}

class _PulseAlertWidgetState extends State<PulseAlertWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: const Column(
        children: [
          Icon(Icons.bluetooth_disabled, size: 40, color: Colors.red),
          SizedBox(height: 10),
          Text(
            'Enable Bluetooth',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}