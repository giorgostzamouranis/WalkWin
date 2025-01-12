import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'friends_profile_page.dart';

class ScanFriendPage extends StatefulWidget {
  const ScanFriendPage({Key? key}) : super(key: key);

  @override
  State<ScanFriendPage> createState() => _ScanFriendPageState();
}

class _ScanFriendPageState extends State<ScanFriendPage> {
  final GlobalKey _qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? _controller;
  bool _isScanning = true; // Used to prevent multiple scans

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() => _controller = controller);

    // Listen to the stream of scan data
    controller.scannedDataStream.listen((scanData) async {
      if (_isScanning) {
        setState(() => _isScanning = false);

        final scannedUsername = scanData.code;
        if (scannedUsername != null && scannedUsername.isNotEmpty) {
          // pause the camera so it doesn't keep scanning
          _controller?.pauseCamera();

          // 1) Search Firestore for a user with this username
          final userSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .where('username', isEqualTo: scannedUsername)
              .limit(1)
              .get();

          // 2) If found, navigate to that user's profile page
          if (userSnapshot.docs.isNotEmpty) {
            // Get the doc
            final doc = userSnapshot.docs.first;
            final userData = doc.data() as Map<String, dynamic>;

            // Ensure we have a UID
            // If your doc ID is the UID, just set it:
            userData['uid'] = doc.id;

            // Ensure avatar is a String
            if (userData['avatar'] != null &&
                !userData['avatar'].startsWith('http')) {
              // It's a local asset path
              userData['avatar'] = userData['avatar']; // Keep it as a String
            }

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => FriendsProfilePage(user: userData),
              ),
            );
          } else {
            // 3) If user not found, show a message & resume camera or pop
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('User not found.')),
            );
            // Resume scanning if you want another attempt
            _controller?.resumeCamera();
            setState(() => _isScanning = true);
          }
        } else {
          // If the scanned QR code is empty or null
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid QR code.')),
          );
          _controller?.resumeCamera();
          setState(() => _isScanning = true);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
      ),
      body: Stack(
        children: [
          // The QR View
          QRView(
            key: _qrKey,
            onQRViewCreated: _onQRViewCreated,
          ),
          // A semi-transparent overlay
          Positioned.fill(
            child: Container(
              color: Colors.black26,
            ),
          ),
        ],
      ),
    );
  }
}
