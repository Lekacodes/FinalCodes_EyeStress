import 'package:flutter/material.dart';
import 'package:app_usage/app_usage.dart';


class AppUsageWidget extends StatefulWidget {
  @override
  _AppUsageWidgetState createState() => _AppUsageWidgetState();
}

class _AppUsageWidgetState extends State<AppUsageWidget> {
  List<AppUsageInfo> _usageInfo = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    getUsageStats();
  }

  void getUsageStats() async {
    try {
      DateTime endDate = DateTime.now();
      DateTime startDate = endDate.subtract(Duration(days: 7));
      List<AppUsageInfo> infoList = await AppUsage().getAppUsage(startDate, endDate);
      setState(() {
        _usageInfo = infoList;
        _isLoading = false;
      });
    } on AppUsageException catch (e) {
      print(e);
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'App Usage (Last 7 Days)',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                Flexible(
                  fit: FlexFit.loose,
                  child: ListView.builder(
                    itemCount: _usageInfo.length,
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: 4,
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          leading: Icon(Icons.apps, size: 40),
                          title: Text(
                            _usageInfo[index].appName,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Usage: ${_formatDuration(_usageInfo[index].usage)}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          trailing: CircularProgressIndicator(
                            value: _usageInfo[index].usage.inHours / 168, // 7 days = 168 hours
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}