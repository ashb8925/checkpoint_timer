import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Checkpoint Timer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MainScreen(),
    );
  }
}

class CheckpointData {
  final String timestamp;
  final List<String> times;

  CheckpointData({
    required this.timestamp,
    required this.times,
  });

  Map<String, dynamic> toJson() => {
    'timestamp': timestamp,
    'times': times,
  };

  factory CheckpointData.fromJson(Map<String, dynamic> json) {
    return CheckpointData(
      timestamp: json['timestamp'] as String,
      times: List<String>.from(json['times']),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<CheckpointData> _previousData = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = _previousData.map((data) => jsonEncode(data.toJson())).toList();
    await prefs.setStringList('saved_data', jsonData);
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getStringList('saved_data');
    if (savedData != null) {
      setState(() {
        _previousData = savedData
            .map((data) => CheckpointData.fromJson(jsonDecode(data)))
            .toList();
      });
    }
  }

  void _addNewData(List<String> buttonTimes) {
    if (buttonTimes.isEmpty) {
      return;
    }

    final newData = CheckpointData(
      timestamp: DateTime.now().toIso8601String(),
      times: buttonTimes,
    );

    setState(() {
      _previousData.add(newData);
    });
    _saveData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Checkpoint Timer'),
        centerTitle: true,
        elevation: 2,
      ),
      body: Container(
        color: Colors.grey[50],
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Card(
                margin: EdgeInsets.symmetric(vertical: 8),
                elevation: 2,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NewDataScreen(onSubmit: _addNewData),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.add_circle_outline,
                            color: Colors.blue[700],
                            size: 28,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Create New Checkpoints',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Record new checkpoint timings',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.black45,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Card(
                margin: EdgeInsets.symmetric(vertical: 8),
                elevation: 2,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PreviousDataScreen(
                          previousData: _previousData,
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.history,
                            color: Colors.green[700],
                            size: 28,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'View Previous Checkpoints',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '${_previousData.length} ${_previousData.length == 1 ? 'session' : 'sessions'} recorded',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.black45,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NewDataScreen extends StatefulWidget {
  final Function(List<String>) onSubmit;

  NewDataScreen({required this.onSubmit});

  @override
  _NewDataScreenState createState() => _NewDataScreenState();
}

class _NewDataScreenState extends State<NewDataScreen> {
  List<String> _buttonTimes = [];
  ScrollController _scrollController = ScrollController();

  String formatTime(String time) {
    try {
      final dateTime = DateTime.parse(time);
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
    } catch (e) {
      return time;
    }
  }

  void _recordTime() {
    setState(() {
      _buttonTimes.add(DateTime.now().toString());
    });
    Future.delayed(Duration(milliseconds: 100), () {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  void _deleteTime(int index) {
    setState(() {
      _buttonTimes.removeAt(index);
    });
  }

  void _submitData() {
    widget.onSubmit(_buttonTimes);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Data Submitted Successfully!"),
    ));
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Data Screen'),
        elevation: 2,
      ),
      body: Container(
        color: Colors.grey[50],
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: _buttonTimes.length,
                      itemBuilder: (context, index) {
                        return Card(
                          elevation: 1,
                          margin: EdgeInsets.symmetric(vertical: 4),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.timer,
                                    color: Colors.blue[700],
                                    size: 24,
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Row(
                                    children: [
                                      Text(
                                        'Time ${index + 1}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.black38,
                                        ),
                                      ),
                                      SizedBox(width: 16),
                                      Text(
                                        formatTime(_buttonTimes[index]),
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black87,
                                          fontFamily: 'Monospace',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.delete_outline,
                                    color: Colors.red[400],
                                    size: 22,
                                  ),
                                  onPressed: () => _deleteTime(index),
                                  tooltip: 'Delete entry',
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 16),
                  FloatingActionButton.extended(
                    onPressed: _submitData,
                    icon: Icon(Icons.save),
                    label: Text('Submit'),
                    tooltip: 'Submit Data',
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: FloatingActionButton(
                  onPressed: _recordTime,
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.timer),
                  tooltip: 'Record Time',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PreviousDataScreen extends StatefulWidget {
  final List<CheckpointData> previousData;

  PreviousDataScreen({required this.previousData});

  @override
  _PreviousDataScreenState createState() => _PreviousDataScreenState();
}

class _PreviousDataScreenState extends State<PreviousDataScreen> {
  String formatDateTime(String timestamp) {
    final dateTime = DateTime.parse(timestamp);
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Previous Data'),
        elevation: 2,
      ),
      body: Container(
        color: Colors.grey[50],
        child: widget.previousData.isEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.history,
                size: 64,
                color: Colors.black26,
              ),
              SizedBox(height: 16),
              Text(
                'No previous data available.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Create new checkpoints to see them here.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black38,
                ),
              ),
            ],
          ),
        )
            : ListView.builder(
          padding: EdgeInsets.all(16.0),
          itemCount: widget.previousData.length,
          itemBuilder: (context, index) {
            final entry = widget.previousData[widget.previousData.length - 1 - index];
            return Card(
              margin: EdgeInsets.symmetric(vertical: 4),
              elevation: 1,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailsScreen(
                        timestamp: entry.timestamp,
                        buttonTimes: entry.times,
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.history,
                          color: Colors.blue[700],
                          size: 24,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              formatDateTime(entry.timestamp),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '${entry.times.length} checkpoints',
                              style: TextStyle(
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.black45,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class DetailsScreen extends StatelessWidget {
  final String timestamp;
  final List<String> buttonTimes;

  DetailsScreen({
    required this.timestamp,
    required this.buttonTimes,
  });

  String formatDateTime(String timestamp) {
    final dateTime = DateTime.parse(timestamp);
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String formatTime(String time) {
    try {
      final dateTime = DateTime.parse(time);
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
    } catch (e) {
      return time;
    }
  }

  String calculateDuration(String time1, String time2) {
    try {
      final dateTime1 = DateTime.parse(time1);
      final dateTime2 = DateTime.parse(time2);
      final difference = dateTime2.difference(dateTime1);

      final hours = difference.inHours;
      final minutes = difference.inMinutes.remainder(60);
      final seconds = difference.inSeconds.remainder(60);

      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'N/A';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Checkpoint Details'),
        elevation: 2,
      ),
      body: Container(
        color: Colors.grey[50],
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              color: Colors.blue.withOpacity(0.1),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: Colors.blue[700],
                    size: 24,
                  ),
                  SizedBox(width: 16),
                  Text(
                    'Session: ${formatDateTime(timestamp)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(16.0),
                itemCount: buttonTimes.length,
                itemBuilder: (context, index) {
                  final duration = index > 0
                      ? calculateDuration(buttonTimes[index - 1], buttonTimes[index])
                      : null;

                  return Card(
                    elevation: 1,
                    margin: EdgeInsets.symmetric(vertical: 4),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.timer,
                                  color: Colors.blue[700],
                                  size: 24,
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Checkpoint ${index + 1}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.black38,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      formatTime(buttonTimes[index]),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black87,
                                        fontFamily: 'Monospace',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (duration != null) ...[
                            SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.only(left: 56.0),
                              child: Text(
                                'Duration from previous: $duration',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                  fontFamily: 'Monospace',
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}