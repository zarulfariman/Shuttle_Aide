import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/*
class SchedulePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Flexible(
          child: Image.asset(
            'assets/shuttleAideLogo.png',
            fit: BoxFit.contain,
            height: 160,),
        ),
        centerTitle: true,
      ),
      body: const SingleChildScrollView(
        child:
        Center(
          child: Text("Bus Schedules"),
        )
      ),
    );
  }
}
*/
/*
class SchedulePage extends StatefulWidget {
  const SchedulePage({Key? key}) : super(key: key);

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  final CollectionReference schedulesCollection =
      FirebaseFirestore.instance.collection('schedules');

  Map<String, Map<String, List<Map<String, dynamic>>>> schedules = {};
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchSchedules();
  }

  Future<void> _fetchSchedules() async {
    try {
      Map<String, Map<String, List<Map<String, dynamic>>>> fetchedSchedules = {};

      // Fetch routes (e.g., "Ruqayyah" and "Salahuddin")
      final QuerySnapshot routeSnapshot = await schedulesCollection.get();

      for (var routeDoc in routeSnapshot.docs) {
        final routeName = routeDoc.id; // e.g., "Ruqayyah" or "Salahuddin"
        fetchedSchedules[routeName] = {};

        // Fetch day-level documents (e.g., "MondayToThursday", "Friday")
        final QuerySnapshot daySnapshot = await schedulesCollection.doc(routeName).collection('MondayToThursday').get();

        // Iterate through each day
        for (var dayDoc in daySnapshot.docs) {
          final dayName = dayDoc.id; // e.g., "morning", "afternoon", etc.
          fetchedSchedules[routeName]![dayName] = [];

          // Fetch departure times
          final QuerySnapshot departureSnapshot =
              await schedulesCollection.doc(routeName).collection('MondayToThursday').doc(dayName).collection('departureTimes').get();

          for (var departureDoc in departureSnapshot.docs) {
            fetchedSchedules[routeName]![dayName]!.add({
              "time": departureDoc.id,
              "buses": departureDoc["buses"],
            });
          }
        }
      }

      setState(() {
        schedules = fetchedSchedules;
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        errorMessage = 'Error fetching schedules: $error';
        isLoading = false;
      });
    }
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                )
              : _buildScheduleTable(),
    );
  }

  Widget _buildScheduleTable() {
    if (schedules.isEmpty) {
      return const Center(
        child: Text(
          'No schedules available',
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    return ListView.builder(
      itemCount: schedules.keys.length,
      itemBuilder: (context, routeIndex) {
        final routeName = schedules.keys.elementAt(routeIndex);
        final days = schedules[routeName]!;

        return ExpansionTile(
          title: Text(
            routeName,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          children: days.keys.map((dayName) {
            final departures = days[dayName]!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    dayName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
                DataTable(
                  columns: const [
                    DataColumn(label: Text('Time')),
                    DataColumn(label: Text('Buses')),
                  ],
                  rows: departures.map((departure) {
                    return DataRow(cells: [
                      DataCell(Text(departure['time'])),
                      DataCell(Text(departure['buses'].toString())),
                    ]);
                  }).toList(),
                ),
              ],
            );
          }).toList(),
        );
      },
    );
  }
}*/

class SchedulePage extends StatefulWidget {
  const SchedulePage({Key? key}) : super(key: key);

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  final CollectionReference schedulesCollection =
      FirebaseFirestore.instance.collection('schedules');

  Map<String, Map<String, Map<String, List<Map<String, dynamic>>>>> schedules =
      {};
  bool isLoading = true;
  String? errorMessage;

  final Map<String, String> routeDescriptions = {
    "Ruqayyah":
        "Departs from Mahallah Ruqayyah to all Kulliyah and ends back to Mahallah Ruqayyah.",
    "Salahuddin":
        "Departs from Mahallah Salahuddin to all Kulliyah and ends back to Mahallah Salahuddin.",
  };

  final Color customGreen = const Color.fromARGB(255, 20, 124, 27);

  @override
  void initState() {
    super.initState();
    _fetchSchedules();
  }

  Future<void> _fetchSchedules() async {
    try {
      Map<String, Map<String, Map<String, List<Map<String, dynamic>>>>>
          fetchedSchedules = {};

      final QuerySnapshot routeSnapshot = await schedulesCollection.get();

      for (var routeDoc in routeSnapshot.docs) {
        final routeName = routeDoc.id;
        fetchedSchedules[routeName] = {};

        for (String dayName in ['MondayToThursday', 'Friday']) {
          fetchedSchedules[routeName]![dayName] = {};

          final QuerySnapshot sessionSnapshot = await schedulesCollection
              .doc(routeName)
              .collection(dayName)
              .get();

          for (var sessionDoc in sessionSnapshot.docs) {
            final sessionName = sessionDoc.id;
            fetchedSchedules[routeName]![dayName]![sessionName] = [];

            final QuerySnapshot timeSnapshot = await schedulesCollection
                .doc(routeName)
                .collection(dayName)
                .doc(sessionName)
                .collection('departureTimes')
                .get();

            for (var timeDoc in timeSnapshot.docs) {
              fetchedSchedules[routeName]![dayName]![sessionName]!.add({
                'time': timeDoc.id,
                'buses': timeDoc['buses'],
              });
            }
          }
        }
      }

      setState(() {
        schedules = fetchedSchedules;
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        errorMessage = 'Error fetching schedules: $error';
        isLoading = false;
      });
    }
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                )
              : schedules.isEmpty
                  ? const Center(child: Text('No schedules available'))
                  : ListView(
                      children: [
                        const SizedBox(height: 10),
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
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
                              "Schedules",
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
                            "Take note that the time stated are departure times of the bus(es) from their starting point.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ...schedules.keys.map((route) {
                          return Card(
                            margin: const EdgeInsets.all(10),
                            shadowColor: Colors.greenAccent,
                            elevation: 7,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Text(
                                    route,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: customGreen,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Text(
                                    routeDescriptions[route] ?? '',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                ),
                                const Divider(),
                                ...schedules[route]!.keys.map((day) {
                                  return Card(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    child: ExpansionTile(
                                      title: Text(
                                        day,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: customGreen,
                                        ),
                                      ),
                                      children: _buildSessionWidgets(
                                          schedules[route]![day]!),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
    );
  }

  /// Builds widgets for the sessions, sorted in the correct order.
  List<Widget> _buildSessionWidgets(
      Map<String, List<Map<String, dynamic>>> sessions) {
    final sessionOrder = ['morning', 'afternoon', 'evening'];

    final sortedSessions = sessions.keys.toList()
      ..sort((a, b) => sessionOrder.indexOf(a).compareTo(sessionOrder.indexOf(b)));

    return sortedSessions.map((session) {
      final departureTimes = sessions[session]!;

      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              session.toUpperCase(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Table(
              border: TableBorder.all(
                color: Colors.grey,
                width: 1,
              ),
              children: [
                TableRow(
                  decoration: BoxDecoration(
                    color: customGreen.withOpacity(0.1),
                  ),
                  children: const [
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        'Time',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        'Buses',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                ...departureTimes.map(
                  (timeData) {
                    return TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            timeData['time'],
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            timeData['buses'].toString(),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      );
    }).toList();
  }
}