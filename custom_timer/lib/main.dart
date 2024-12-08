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

  void _updatePreviousData(List<CheckpointData> updatedData) {
    setState(() {
      _previousData = updatedData;
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
                          onDataChanged: _updatePreviousData, // Make sure this is passed
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
  List<String> _buttonTimes = List.filled(15, '');
  ScrollController _scrollController = ScrollController();

  String getButtonName(int index) {
    switch (index) {
      case 0: return 'Block Permitted';
      case 1: return 'T/409';
      case 2: return 'Dep';
      case 3: return 'Arr/site';
      case 4: return 'NP Load';
      case 5: return 'm/c ReachCut';
      case 6: return 'Rail last laid';
      case 7: return 'Rail fish plate';
      case 8: return 'Old Slp. removed';
      case 9: return 'm/c backward';
      case 10: return 'Plough down & NT';
      case 11: return 'Sled U&H&Locked';
      case 12: return 'Slp. Laying Start';
      case 13: return 'Last Slp. Dropped';
      case 14: return 'Work close';
      default: return '';
    }
  }

  String formatTime(String time) {
    if (time.isEmpty) return '00:00:00';
    try {
      final dateTime = DateTime.parse(time);
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
    } catch (e) {
      return time;
    }
  }

  void _recordTimeForButton(int index) {
    setState(() {
      _buttonTimes[index] = DateTime.now().toString();
    });

    // Scroll to bottom after a short delay
    Future.delayed(Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  void _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('buttonTimes', jsonEncode(_buttonTimes));
  }

  void _resetButton(int index) {
    setState(() {
      _buttonTimes[index] = '';
    });
    _saveData();
  }

  void _submitData() {
    // Filter out empty times
    final validTimes = _buttonTimes.where((time) => time.isNotEmpty).toList();

    widget.onSubmit(validTimes);
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
        child: Row(
          children: [
            // Left side - Recorded Times
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  Expanded(
                    child: Card(
                      margin: EdgeInsets.all(8),
                      elevation: 2,
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: _buttonTimes.where((time) => time.isNotEmpty).length,
                        itemBuilder: (context, index) {
                          final validTimes = _buttonTimes.where((time) => time.isNotEmpty).toList();
                          final time = validTimes[index];
                          final buttonIndex = _buttonTimes.indexOf(time);

                          return Card(
                            elevation: 1,
                            margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      getButtonName(buttonIndex),
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    formatTime(time),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Monospace',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  // Submit button at bottom of left panel
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: _submitData,
                        icon: Icon(Icons.save),
                        label: Text(
                          'Submit',
                          style: TextStyle(fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Right side - Buttons
            Expanded(
              flex: 2,
              child: Card(
                margin: EdgeInsets.all(8),
                elevation: 2,
                child: GridView.builder(
                  padding: EdgeInsets.all(8),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    childAspectRatio: 3,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: 15,
                  itemBuilder: (context, index) {
                    final hasTime = _buttonTimes[index].isNotEmpty;
                    return ElevatedButton(
                      onPressed: () => _recordTimeForButton(index),
                      onLongPress: hasTime ? () => _resetButton(index) : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: hasTime ? Colors.green : Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        minimumSize: Size(double.infinity, 60),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          getButtonName(index),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    );
                  },
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
  final Function(List<CheckpointData>)? onDataChanged;

  PreviousDataScreen({required this.previousData, this.onDataChanged});

  @override
  _PreviousDataScreenState createState() => _PreviousDataScreenState();
}

class _PreviousDataScreenState extends State<PreviousDataScreen> {
  late List<CheckpointData> _displayData;
  Set<int> _selectedIndices = {};
  bool _isSelectionMode = false;

  @override
  void initState() {
    super.initState();
    // Create a mutable copy of the previous data
    _displayData = List.from(widget.previousData);
  }

  String formatDateTime(String timestamp) {
    final dateTime = DateTime.parse(timestamp);
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _toggleSelection(int index) {
    setState(() {
      if (_selectedIndices.contains(index)) {
        _selectedIndices.remove(index);
      } else {
        _selectedIndices.add(index);
      }
    });
  }

  void _selectAll() {
    setState(() {
      if (_selectedIndices.length == _displayData.length) {
        _selectedIndices.clear();
      } else {
        _selectedIndices = Set.from(
            List.generate(_displayData.length, (index) => index)
        );
      }
    });
  }

  void _deleteSelected() {
    if (_selectedIndices.isEmpty) return;

    // Store the number of selected items before clearing
    final deletedCount = _selectedIndices.length;

    // Create a new list without the selected indices
    final updatedData = List<CheckpointData>.from(_displayData)
      ..removeWhere((data) =>
          _selectedIndices.contains(_displayData.indexOf(data))
      );

    // Ensure onDataChanged is not null before calling
    if (widget.onDataChanged != null) {
      widget.onDataChanged!(updatedData);
    }

    setState(() {
      _displayData = updatedData;
      _selectedIndices.clear();
      _isSelectionMode = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$deletedCount ${deletedCount == 1 ? 'entry' : 'entries'} deleted')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isSelectionMode
            ? '${_selectedIndices.length} Selected'
            : 'Previous Data'
        ),
        elevation: 2,
        actions: _isSelectionMode
            ? [
          IconButton(
            icon: Icon(
                _selectedIndices.length == _displayData.length
                    ? Icons.deselect
                    : Icons.select_all
            ),
            onPressed: _selectAll,
            tooltip: 'Select All',
          ),
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: _deleteSelected,
            tooltip: 'Delete Selected',
          ),
        ]
            : [],
      ),
      body: Container(
        color: Colors.grey[50],
        child: _displayData.isEmpty
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
          itemCount: _displayData.length,
          itemBuilder: (context, index) {
            final entry = _displayData[_displayData.length - 1 - index];
            final displayIndex = _displayData.length - 1 - index;
            final isSelected = _selectedIndices.contains(displayIndex);

            return Card(
              margin: EdgeInsets.symmetric(vertical: 4),
              elevation: isSelected ? 3 : 1,
              color: isSelected
                  ? Colors.blue.withOpacity(0.2)
                  : Colors.white,
              child: InkWell(
                onLongPress: () {
                  setState(() {
                    _isSelectionMode = true;
                    _toggleSelection(displayIndex);
                  });
                },
                onTap: _isSelectionMode
                    ? () => _toggleSelection(displayIndex)
                    : () {
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
                      if (_isSelectionMode)
                        Checkbox(
                          value: isSelected,
                          onChanged: (bool? value) {
                            _toggleSelection(displayIndex);
                          },
                        ),
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
                      if (!_isSelectionMode)
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

  String getButtonName(int index) {
    switch (index) {
      case 0: return 'Block Permitted';
      case 1: return 'T/409';
      case 2: return 'Dep';
      case 3: return 'Arr/site';
      case 4: return 'New Panel Load';
      case 5: return 'm/c reach cut';
      case 6: return 'Rail last laid';
      case 7: return 'Rail fish plate';
      case 8: return 'Old Slp. removed';
      case 9: return 'm/c backward';
      case 10: return 'Plough down & NT';
      case 11: return 'Sled U&H&Locked';
      case 12: return 'Slp. Laying Start';
      case 13: return 'Last Slp. Dropped';
      case 14: return 'Work close';
      default: return '';
    }
  }

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
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Reduced vertical padding
              color: Colors.blue.withOpacity(0.1),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: Colors.blue[700],
                    size: 20, // Reduced from 24
                  ),
                  SizedBox(width: 12), // Reduced from 16
                  Text(
                    'Session: ${formatDateTime(timestamp)}',
                    style: TextStyle(
                      fontSize: 14, // Reduced from 16
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(12.0), // Reduced from 16
                itemCount: buttonTimes.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 1,
                    margin: EdgeInsets.symmetric(vertical: 3), // Reduced from 4
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // Reduced from 16
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(6), // Reduced from 8
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6), // Reduced from 8
                            ),
                            child: Icon(
                              Icons.timer,
                              color: Colors.blue[700],
                              size: 20, // Reduced from 24
                            ),
                          ),
                          SizedBox(width: 12), // Reduced from 16
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  getButtonName(index),
                                  style: TextStyle(
                                    fontSize: 14, // Reduced from 16
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black38,
                                  ),
                                ),
                                Text(
                                  formatTime(buttonTimes[index]),
                                  style: TextStyle(
                                    fontSize: 14, // Reduced from 16
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