import 'package:flutter/material.dart';
import 'package:flutter_shimmer/flutter_shimmer.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class Sound1Page extends StatefulWidget {
  const Sound1Page({Key? key}) : super(key: key);

  @override
  State<Sound1Page> createState() => _Sound1PageState();
}

class _Sound1PageState extends State<Sound1Page> {
  List<dynamic> _soundData = [];
  bool _isLoading = true;
  String _errorMessage = '';

  Future<void> fetchSoundData() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:5000/api/status/soundchappi'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _soundData = data;
          _isLoading = false;
          _errorMessage = '';
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load data: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Connection error: ${e.toString()}';
      });
    }
  }

  // Handle sound detection based on the sound code
  Widget _buildSoundIcon(int soundType) {
    const defaultIcon = Icons.volume_up;
    const iconSize = 36.0;

    final icons = {
      75: Icons.child_care,  // Assume sound 75 is 'cry'
      50: Icons.pets,        // Assuming sound 50 is 'bark'
      25: Icons.notification_important, // Assuming sound 25 is 'alert'
    };

    return Icon(
      icons[soundType] ?? defaultIcon,
      size: iconSize,
      color: Colors.blueGrey[800],
    );
  }

  // Format the date to a readable format
  String _formatDate(String date) {
    final DateTime parsedDate = DateTime.parse(date);
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(parsedDate);
  }

  // Build list item
  Widget _buildListItem(dynamic item) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: _buildSoundIcon(item['sound']),
        title: Text(
          '${item['sound']} Detected',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.blueGrey,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Date: ${_formatDate(item['date'])}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Colors.blueGrey[300],
        ),
        onTap: () {
          // Add navigation to detail page if necessary
        },
      ),
    );
  }

  // Handle the error state
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 20),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              onPressed: fetchSoundData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Handle the empty state
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/backround.png', // Add your own asset
            width: 150,
            color: Colors.blueGrey[200],
          ),
          const SizedBox(height: 20),
          const Text(
            'No Sounds Detected',
            style: TextStyle(
              fontSize: 18,
              color: Colors.blueGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'When new sounds are detected,\nthey will appear here',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchSoundData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sound notification ",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF22B5C8),
        elevation: 10,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: fetchSoundData,
        child: _isLoading
            ? ListView.builder(
                itemCount: 6,
                itemBuilder: (context, index) => const ListTileShimmer(),
              )
            : _errorMessage.isNotEmpty
                ? _buildErrorState()
                : _soundData.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        itemCount: _soundData.length,
                        itemBuilder: (context, index) => _buildListItem(_soundData[index]),
                      ),
      ),
    );
  }
}
