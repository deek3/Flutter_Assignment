import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() {
  runApp(ReminderApp());
}

class ReminderApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ReminderHomePage(),
    );
  }
}

class ReminderHomePage extends StatefulWidget {
  @override
  _ReminderHomePageState createState() => _ReminderHomePageState();
}

class _ReminderHomePageState extends State<ReminderHomePage> {
  String? _selectedDay;
  TimeOfDay? _selectedTime;
  String? _selectedActivity;

  FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;

  final List<String> daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  final List<String> activities = [
    'Wake up',
    'Go to gym',
    'Breakfast',
    'Meetings',
    'Lunch',
    'Quick nap',
    'Go to library',
    'Dinner',
    'Go to sleep',
  ];

  @override
  void initState() {
    super.initState();
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    // Android and iOS initialization settings.
    var androidInitialize = const AndroidInitializationSettings('@mipmap/ic_launcher');
    var darwinInitialize = const DarwinInitializationSettings();

    var initializationSettings = InitializationSettings(
      android: androidInitialize,
      iOS: darwinInitialize,
    );

    flutterLocalNotificationsPlugin!.initialize(initializationSettings);
  }

  void _scheduleNotification() async {
    if (_selectedTime == null || _selectedActivity == null) {
      // Ensure both time and activity are selected
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select both time and activity.')),
      );
      return;
    }

    var androidDetails = const AndroidNotificationDetails(
      "channelId",                 // Channel ID
      "Reminder",                  // Channel Name
      channelDescription: "Scheduled Reminder", // Optional description
      importance: Importance.high,  // High importance
      priority: Priority.high, 
      sound: RawResourceAndroidNotificationSound('alarm'), // Specify the sound
  );     // High priority


    var notificationDetails = NotificationDetails(android: androidDetails);

    // Schedule notification based on the selected time
    DateTime now = DateTime.now();
    DateTime scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    flutterLocalNotificationsPlugin!.schedule(
      0,
      "Reminder",
      "$_selectedActivity time",
      scheduledTime,
      notificationDetails,
    );
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      title: Row(
          children: [
            Text('Daily Reminder App'), 
            Spacer(),
            Image.asset(
              'assets/bell.jpg', 
              width: 40,         
              height: 40,        
            ),
            SizedBox(width: 10), 
            
          ],
        ),
        backgroundColor: Colors.blueGrey,
      ),
      body: Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/bg.jpg'), // Your background image path
          fit: BoxFit.cover, // This will cover the whole container
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Dropdown menu with image on the right corner
            Row(
              children: [
                Container(
                  width:150,
                  child: DropdownButton<String>(
                    value: _selectedDay,
                    hint: Text('Select Day'),
                    isExpanded: true,
                    items: daysOfWeek.map((String day) {
                      return DropdownMenuItem<String>(
                        value: day,
                        child: Text(day),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedDay = newValue;
                      });
                    },
                  ),
                ),
                SizedBox(width: 10), // Add some spacing
                Image.asset(
                  'assets/cal-icon.png', // Path to your image
                  width: 30,
                  height: 30,
                ),
              ],
            ),
            SizedBox(height: 20),

            // Time picker for time selection
            Row(
              children: [
                Container(
                  width:150,
                  child: ElevatedButton(
                    onPressed: () async {
                      TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (picked != null) {
                        setState(() {
                          _selectedTime = picked;
                        });
                      }
                    },
                    child: Text(_selectedTime == null
                        ? 'Select Time'
                        : 'Time: ${_selectedTime!.format(context)}'),
                  ),
                ),
                SizedBox(width: 10), // Add some spacing
                Image.asset(
                  'assets/clock.png', // Path to your time-related image
                  width: 30,
                  height: 30,
                ),
              ],
            ),

            SizedBox(height: 20),
            // Drop-down for activity selection
            Row(
              children: [
                Container(
                  width: 150,
              child: DropdownButton<String>(
              value: _selectedActivity,
              hint: Text('Select Activity'),
              isExpanded: true,
              items: activities.map((String activity) {
                return DropdownMenuItem<String>(
                  value: activity,
                  child: Text(activity),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedActivity = newValue;
                });
              },
            ),
            ),

            SizedBox(height: 30),
            Image.asset(
              'assets/activity.png',
              width:30,
              height:30,
              ),
          ],
      ),
      SizedBox(height: 30,),

            Row(
            mainAxisAlignment: MainAxisAlignment.start, // Aligns items to the start of the row
            children: [
              ElevatedButton(
                onPressed: _scheduleNotification,
                child: Text('Set Reminder'),
              ),
              SizedBox(width: 10), // Add spacing between the button and the image
              Image.asset(
                'assets/remainder.png', // Path to your reminder icon image
                width: 30,
                height: 30,
              ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
}