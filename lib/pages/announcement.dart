// CODE FOR ANNOUNCEMENT PAGE

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class UpdatesPage extends StatefulWidget {
  const UpdatesPage({super.key});

  @override
  State<UpdatesPage> createState() => _UpdatesPageState();
}

class _UpdatesPageState extends State<UpdatesPage> {
  final CollectionReference announcementsCollection =
      FirebaseFirestore.instance.collection('announcements');

  List<Map<String, dynamic>> announcements = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchAnnouncements();
  }

  Future<void> _fetchAnnouncements() async {
    try {
      final QuerySnapshot querySnapshot = await announcementsCollection.get();

      final List<Map<String, dynamic>> fetchedAnnouncements = querySnapshot.docs
          .map((doc) => {
                'date': doc.id,
                'day': doc['day'],
                'time': doc['time'],
                'text': doc['text'],
              })
          .toList();

      // Sort the list in descending order by date
      fetchedAnnouncements.sort((a, b) => b['date'].compareTo(a['date']));

      setState(() {
        announcements = fetchedAnnouncements;
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        errorMessage = 'Error fetching announcements: $error';
        isLoading = false;
      });
    }
  }

  String formatDate(String date) {
    // Parse the date string (assuming yyyy-MM-dd format)
    final DateTime parsedDate = DateTime.parse(date);
    // Format the date to "Day Month Year" format
    return DateFormat('d MMMM yyyy').format(parsedDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Flexible(
          child: Image.asset(
            'assets/shuttleAideLogo.png',
            fit: BoxFit.contain,
            height: 160,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Center(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 5,
                    spreadRadius: 2,
                  )
                ],
              ),
              child: const Text(
                "Announcements",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Text(
              "Stay informed with the latest updates and announcements below.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[800],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : errorMessage != null
                    ? Center(
                        child: Text(
                          errorMessage!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : announcements.isEmpty
                        ? const Center(
                            child: Text('No announcements available'),
                          )
                        : ListView.builder(
                            itemCount: announcements.length,
                            itemBuilder: (context, index) {
                              final announcement = announcements[index];
                              return _buildAnnouncementCard(announcement);
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementCard(Map<String, dynamic> announcement) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      shadowColor: Colors.greenAccent,
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date (header)
            Text(
              formatDate(announcement['date']),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            // Day and Time
            Text(
              "${announcement['day']} • ${announcement['time']}",
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 10),
            // Announcement text
            Text(
              announcement['text'],
              style: const TextStyle(fontSize: 14, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
