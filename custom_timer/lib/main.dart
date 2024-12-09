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
  final List<ButtonRecord> records;

  CheckpointData({
    required this.timestamp,
    required this.records,
  });

  Map<String, dynamic> toJson() => {
    'timestamp': timestamp,
    'records': records.map((record) => record.toJson()).toList(),
  };

  factory CheckpointData.fromJson(Map<String, dynamic> json) {
    // Handle potential null or invalid records array
    var recordsList = json['records'];
    List<ButtonRecord> parsedRecords = [];

    if (recordsList != null && recordsList is List) {
      parsedRecords = recordsList
          .map((record) => ButtonRecord.fromJson(record as Map<String, dynamic>))
          .toList();
    }

    return CheckpointData(
      timestamp: json['timestamp'] as String? ?? DateTime.now().toIso8601String(),
      records: parsedRecords,
    );
  }
}

class ButtonRecord {
  final String buttonName;
  final String time;

  ButtonRecord({
    required this.buttonName,
    required this.time,
  });

  Map<String, dynamic> toJson() => {
    'buttonName': buttonName,
    'time': time,
  };

  factory ButtonRecord.fromJson(Map<String, dynamic> json) {
    return ButtonRecord(
      buttonName: json['buttonName'] as String? ?? '',
      time: json['time'] as String? ?? DateTime.now().toIso8601String(),
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

  void _addNewData(List<ButtonRecord> buttonRecords) {
    if (buttonRecords.isEmpty) {
      return;
    }

    final newData = CheckpointData(
      timestamp: DateTime.now().toIso8601String(),
      records: buttonRecords,
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
  final Function(List<ButtonRecord>) onSubmit;

  NewDataScreen({required this.onSubmit});

  @override
  _NewDataScreenState createState() => _NewDataScreenState();
}

class _NewDataScreenState extends State<NewDataScreen> {
  List<String> _buttonTimes = [];
  List<String> _buttonNames = [
    'Block Permitted', 'T/409', 'Dep Station', 'Arr/Site', 'Dep Site', 'Arr/Station', 'New Panel Load',
    'M/C Reach Cut', 'Rail last laid', 'Rail Fish Plate', 'Old Slp.Removed',
    'M/C backward', 'Plough down & NT', 'Sled U&H&Locked', 'Slp.Laying Start',
    'Last Slp.Dropped', 'Work Close',
    'Rail Cut Start', 'Rail Cut Stop',
    'Time Loss Start', 'Time Loss Stop'
  ];

  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _buttonTimes = List<String>.generate(_buttonNames.length, (_) => '');
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
    // Only record time if the button is not already active (green)
    if (_buttonTimes[index].isEmpty) {
      setState(() {
        if (_buttonNames[index].contains('Rail Cut Stop')) {
          _handlePairedButtons(
              startIndex: index - 1,
              stopIndex: index,
              pairType: 'Rail Cut'
          );
        } else if (_buttonNames[index].contains('Time Loss Stop')) {
          _handlePairedButtons(
              startIndex: index - 1,
              stopIndex: index,
              pairType: 'Time Loss'
          );
        }

        // Record the time for the current button
        _buttonTimes[index] = DateTime.now().toString();
      });

      // Scroll to bottom after recording
      _scrollToBottom();
    }
  }

  void _handleRailCutPair(int stopIndex) {
    _handlePairedButtons(
        startIndex: stopIndex - 1,
        stopIndex: stopIndex,
        pairType: 'Rail Cut'
    );
  }

  void _handleTimeLossPair(int stopIndex) {
    _handlePairedButtons(
        startIndex: stopIndex - 1,
        stopIndex: stopIndex,
        pairType: 'Time Loss'
    );
  }

  void _handlePairedButtons({
    required int startIndex,
    required int stopIndex,
    required String pairType
  }) {
    // Only create new pair if this is the last stop button for this type
    bool isLastStopButton = !_buttonNames
        .skip(stopIndex + 1)
        .any((name) => name.contains('$pairType Stop'));

    if (isLastStopButton) {
      // Count existing pairs
      int pairCount = _buttonNames
          .where((name) => name.contains('$pairType Start') || name.contains('$pairType Stop'))
          .length ~/ 2;

      // Create new pair names
      String newStartName = '$pairType Start ${pairCount + 1}';
      String newStopName = '$pairType Stop ${pairCount + 1}';

      setState(() {
        // Add new button names
        _buttonNames.addAll([newStartName, newStopName]);
        // Add corresponding empty times
        _buttonTimes.addAll(['', '']);
      });

      // Scroll to show new buttons
      _scrollToBottom();
    }
  }

  void _addNewPairOfButtons(String pairType) {
    // Count existing pairs
    int pairCount = _buttonNames.where((name) =>
    name.contains('$pairType Start') || name.contains('$pairType Stop')
    ).length ~/ 2;

    // Create new pair names
    String newStartName = '$pairType Start ${pairCount + 1}';
    String newStopName = '$pairType Stop ${pairCount + 1}';

    setState(() {
      // Add new button names
      _buttonNames.addAll([newStartName, newStopName]);
      // Add corresponding empty times
      _buttonTimes.addAll(['', '']);
    });
  }

  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  void _resetButton(int index) {
    setState(() {
      _buttonTimes[index] = '';
    });
  }

  void _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('buttonTimes', jsonEncode(_buttonTimes));
  }

  void _submitData() {
    // Create list of ButtonRecord objects for non-empty times
    final records = <ButtonRecord>[];
    for (int i = 0; i < _buttonTimes.length; i++) {
      if (_buttonTimes[i].isNotEmpty) {
        records.add(ButtonRecord(
          buttonName: _buttonNames[i],
          time: _buttonTimes[i],
        ));
      }
    }

    widget.onSubmit(records);
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

  List<MapEntry<int, String>> _getSortedTimeEntries() {
    return _buttonTimes.asMap().entries
        .where((entry) => entry.value.isNotEmpty)
        .toList()
      ..sort((a, b) => DateTime.parse(a.value).compareTo(DateTime.parse(b.value)));
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
                          final sortedEntries = _getSortedTimeEntries();
                          final entry = sortedEntries[index];
                          final buttonIndex = entry.key;
                          final time = entry.value;

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
                                      _buttonNames[buttonIndex],
                                      style: TextStyle(
                                        fontSize: 13, // Reduced from 15
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    formatTime(time),
                                    style: TextStyle(
                                      fontSize: 13, // Reduced from 15
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
                  itemCount: _buttonNames.length,
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
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4), // Reduced padding
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          _buttonNames[index],
                          style: TextStyle(
                            fontSize: 15, // Increased from 13
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

      // If no items are selected, exit selection mode
      if (_selectedIndices.isEmpty) {
        _isSelectionMode = false;
      }
    });
  }

  void _selectAll() {
    setState(() {
      if (_selectedIndices.length == _displayData.length) {
        _selectedIndices.clear();
        _isSelectionMode = false;
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
      ..removeWhere((data) => _selectedIndices.contains(_displayData.indexOf(data)));

    // Ensure onDataChanged is not null before calling
    widget.onDataChanged?.call(updatedData);

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
        leading: _isSelectionMode
            ? IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            setState(() {
              _selectedIndices.clear();
              _isSelectionMode = false;
            });
          },
        )
            : null,
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
                        records: entry.records,
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
                              '${entry.records.length} checkpoints',
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

// Updated DetailsScreen with sorting options:
class DetailsScreen extends StatefulWidget {
  final String timestamp;
  final List<ButtonRecord> records;

  DetailsScreen({
    required this.timestamp,
    required this.records,
  });

  @override
  _DetailsScreenState createState() => _DetailsScreenState();
}

enum SortOption {
  time,
  name,
  original
}

class _DetailsScreenState extends State<DetailsScreen> {
  late List<ButtonRecord> _sortedRecords;
  SortOption _currentSort = SortOption.time;

  @override
  void initState() {
    super.initState();
    _sortedRecords = List.from(widget.records);
    _sortRecords();
  }

  void _sortRecords() {
    setState(() {
      switch (_currentSort) {
        case SortOption.time:
          _sortedRecords.sort((a, b) =>
              DateTime.parse(a.time).compareTo(DateTime.parse(b.time))
          );
          break;
        case SortOption.name:
          _sortedRecords.sort((a, b) => a.buttonName.compareTo(b.buttonName));
          break;
        case SortOption.original:
          _sortedRecords = List.from(widget.records);
          break;
      }
    });
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

  String calculateDuration(String startTime, String endTime) {
    try {
      final start = DateTime.parse(startTime);
      final end = DateTime.parse(endTime);
      final difference = end.difference(start);

      final hours = difference.inHours;
      final minutes = difference.inMinutes.remainder(60);
      final seconds = difference.inSeconds.remainder(60);

      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'N/A';
    }
  }

  Widget _buildTimeCard(ButtonRecord record, {String? duration}) {
    return Card(
      elevation: 1,
      margin: EdgeInsets.symmetric(vertical: 3),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.timer,
                    color: Colors.blue[700],
                    size: 20,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          record.buttonName,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Text(
                        formatTime(record.time),
                        style: TextStyle(
                          fontSize: 14,
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
              SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Duration: ',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                  Text(
                    duration,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                      fontFamily: 'Monospace',
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Checkpoint Details'),
        elevation: 2,
        actions: [
          PopupMenuButton<SortOption>(
            icon: Icon(Icons.sort),
            onSelected: (SortOption option) {
              setState(() {
                _currentSort = option;
                _sortRecords();
              });
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: SortOption.time,
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: _currentSort == SortOption.time ? Colors.blue : null,
                    ),
                    SizedBox(width: 8),
                    Text('Sort by Time'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: SortOption.name,
                child: Row(
                  children: [
                    Icon(
                      Icons.sort_by_alpha,
                      color: _currentSort == SortOption.name ? Colors.blue : null,
                    ),
                    SizedBox(width: 8),
                    Text('Sort by Name'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: SortOption.original,
                child: Row(
                  children: [
                    Icon(
                      Icons.format_list_numbered,
                      color: _currentSort == SortOption.original ? Colors.blue : null,
                    ),
                    SizedBox(width: 8),
                    Text('Original Order'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Container(
        color: Colors.grey[50],
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Colors.blue.withOpacity(0.1),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: Colors.blue[700],
                    size: 20,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Session: ${formatDateTime(widget.timestamp)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(12.0),
                itemCount: _sortedRecords.length,
                itemBuilder: (context, index) {
                  final record = _sortedRecords[index];
                  String? duration;

                  // Calculate duration for Stop buttons
                  if (record.buttonName.contains('Stop')) {
                    // Find the matching Start button
                    final startButtonName = record.buttonName.replaceAll('Stop', 'Start');
                    final startRecord = _sortedRecords.firstWhere(
                          (r) => r.buttonName == startButtonName,
                      orElse: () => ButtonRecord(buttonName: '', time: ''),
                    );

                    if (startRecord.buttonName.isNotEmpty) {
                      duration = calculateDuration(startRecord.time, record.time);
                    }
                  }

                  return _buildTimeCard(record, duration: duration);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}