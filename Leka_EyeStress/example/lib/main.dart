import 'dart:io';
import 'dart:math';
import 'package:app_usage/app_usage.dart';
import 'package:app_usage_example/authentication.dart';
import 'package:camera/camera.dart';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); 
  final cameras = await availableCameras();
  runApp(MyApp(cameras: cameras));
}

class MyApp extends StatelessWidget {
  final List<CameraDescription> cameras;
  

  MyApp({required this.cameras});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: AuthPage(),
      // home: HomeScreen(cameras: cameras),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  HomeScreen({required this.cameras});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
   List<AppUsageInfo> _infos = [];
  CameraController? _controller;
  XFile? _capturedImage;
  String? _stressMessage;
  bool _cameraOn = false;

  final List<String> _stressLevels = [
    "You have high stress",
    "You have medium stress",
    "You have low stress"
  ];

  @override
  void initState() {
    super.initState();
    if (widget.cameras.isNotEmpty) {
      _controller = CameraController(widget.cameras[0], ResolutionPreset.medium);
    }
  }

  void getUsageStats() async {
    try {
      DateTime endDate = DateTime.now();
      DateTime startDate = endDate.subtract(Duration(hours: 1));
      List<AppUsageInfo> infoList =
          await AppUsage().getAppUsage(startDate, endDate);
      setState(() => _infos = infoList);

      for (var info in infoList) {
        print(info.toString());
      }
    } on AppUsageException catch (exception) {
      print(exception);
    }
  }


  Future<void> _toggleCamera() async {
    if (_cameraOn) {
      await _controller?.dispose();
    } else {
      if (_controller != null) {
        await _controller?.initialize();
      }
    }
    setState(() {
      _cameraOn = !_cameraOn;
    });
  }

  Future<void> _captureAndAnalyze() async {
    if (_controller != null && _controller!.value.isInitialized) {
      final image = await _controller!.takePicture();
      final random = Random();
      final stressLevel = _stressLevels[random.nextInt(_stressLevels.length)];
      
      setState(() {
        _capturedImage = image;
        _stressMessage = stressLevel;
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.white, // Set a light background for a clean modern look
    appBar: AppBar(
      title: Text('Eye Stress Analysis', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 22)),
      backgroundColor: Colors.indigoAccent, // A trendy shade of blue
      centerTitle: true,
      elevation: 0, // Flat app bar for modern aesthetics
    ),
    body: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0), // Add consistent padding for better spacing
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center, // Ensure elements are centered
          children: [
            // Camera preview section
            _cameraOn && _controller != null && _controller!.value.isInitialized
                ? AspectRatio(
                    aspectRatio: _controller!.value.aspectRatio,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20), // Rounded camera preview
                      child: CameraPreview(_controller!),
                    ),
                  )
                : Container(
                    decoration: BoxDecoration(
                      color: Colors.indigoAccent.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20), // Rounded container
                    ),
                    height: 250,
                    width: double.infinity,
                    child: Center(
                        child: Text('Camera Preview',
                            style: TextStyle(color: Colors.black, fontSize: 18))),
                  ),
            SizedBox(height: 30),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _toggleCamera,
                  icon: Icon(_cameraOn ? Icons.videocam_off : Icons.videocam),
                  label: Text(_cameraOn ? 'Turn Off' : 'Turn On'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber, // Modern blue color for buttons
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30), // Rounded button edges
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _captureAndAnalyze,
                  icon: Icon(Icons.analytics),
                  label: Text('Analyze Now'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Stress message
            if (_stressMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(
                  _stressMessage!,
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                  textAlign: TextAlign.center, // Center the message
                ),
              ),
            SizedBox(height: 20),

            // Captured image
            if (_capturedImage != null)
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15), // Rounded image corners
                  child: Image.file(
                    File(_capturedImage!.path),
                    height: 200,
                    fit: BoxFit.cover, // Ensure the image covers available space
                  ),
                ),
              ),
            SizedBox(height: 30),

            // App usage section
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20), // Rounded container for usage stats
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('App Usage Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  SizedBox(
                    height: 200, // Adjust the height as needed
                    child: ListView.builder(
                      itemCount: _infos.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: Icon(Icons.apps, color: Colors.indigoAccent),
                          title: Text(_infos[index].appName, style: TextStyle(fontSize: 16)),
                          trailing: Text(_infos[index].usage.toString(),
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),

            // Floating action button for downloading
            FloatingActionButton.extended(
              onPressed: getUsageStats,
              icon: Icon(Icons.file_download),
              label: Text('Download Stats'),
              backgroundColor: Colors.indigoAccent,
            ),
          ],
        ),
      ),
    ),
  );
}
}
