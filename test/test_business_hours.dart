
import 'package:intl/intl.dart';

void main() {
  testCases();
}

void testCases() {
  final cases = [
    "Monday, Wednesday, Thursday, Friday, Saturday, Sunday, 10:00 AM - 7:00 PM",
    "Monday, Wednesday, Thursday, Friday, Saturday, Sunday, 11:00 - 20:00",
    "Mon-Fri 09:00 - 17:00",
    "Daily 10am - 10pm",
    "N/A",
    ""
  ];

  for (var c in cases) {
    print("Input: '$c'");
    var result = _parseBusinessHours(c);
    print("Output: $result\n");
  }
}

Map<String, String> _parseBusinessHours(String raw) {
  if (raw == 'N/A' || raw.isEmpty) {
    return {'hours': 'N/A', 'closed': ''};
  }

  // 1. Process Time: Convert 24h to 12h
  // Match HH:mm only if NOT followed by am or pm
  final timeRegex = RegExp(r'(\d{1,2}):(\d{2})(?!\s*[aApP][mM])');
  String processedHours = raw.replaceAllMapped(timeRegex, (match) {
    int h = int.parse(match.group(1)!);
    int m = int.parse(match.group(2)!);
    
    // Only convert if it looks like a valid time
    // If h > 12, definitely convert. 
    // If h <= 12, it's ambiguous without am/pm. 
    // But usually 11:00 without am/pm implies 24h or just 11:00.
    // User said "if you see the hours are in 24hrs format convert".
    // "11:00 - 20:00" -> 11 is 11am, 20 is 8pm.
    // So we treat all naked HH:mm as 24h candidates.
    
    final dt = DateTime(2022, 1, 1, h, m);
    return DateFormat('h:mm a').format(dt);
  });
  
  // 2. Calculate Days
  final daysMap = {
    'mon': 'Monday',
    'tue': 'Tuesday',
    'wed': 'Wednesday',
    'thu': 'Thursday',
    'fri': 'Friday',
    'sat': 'Saturday',
    'sun': 'Sunday'
  };
  final allDaysSeq = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
  Set<String> presentDays = {};
  String lowerRaw = raw.toLowerCase();

  // Check ranges "Mon-Fri"
  final rangeRegex = RegExp(r'(mon|tue|wed|thu|fri|sat|sun)[a-z]*\s*-\s*(mon|tue|wed|thu|fri|sat|sun)[a-z]*');
  final rangeMatch = rangeRegex.firstMatch(lowerRaw);
  if (rangeMatch != null) {
      int startIdx = allDaysSeq.indexOf(rangeMatch.group(1)!);
      int endIdx = allDaysSeq.indexOf(rangeMatch.group(2)!);
      if (startIdx != -1 && endIdx != -1) {
          if (startIdx <= endIdx) {
              for (int i = startIdx; i <= endIdx; i++) presentDays.add(allDaysSeq[i]);
          } else {
              for (int i = startIdx; i < 7; i++) presentDays.add(allDaysSeq[i]);
              for (int i = 0; i <= endIdx; i++) presentDays.add(allDaysSeq[i]);
          }
      }
  }

  // Check individual days
  daysMap.forEach((k, v) {
      if (lowerRaw.contains(k)) presentDays.add(k);
  });

  // Check specific "everyday" keywords
  if (lowerRaw.contains("daily") || lowerRaw.contains("everyday") || lowerRaw.contains("7 days")) {
      for(var d in allDaysSeq) presentDays.add(d);
  }

  // Calculate closed
  List<String> closedList = [];
  if (presentDays.isNotEmpty && presentDays.length < 7) {
      for (var d in allDaysSeq) {
          if (!presentDays.contains(d)) closedList.add(daysMap[d]!);
      }
  }

  String closedStr = '';
  if (closedList.isNotEmpty) {
     closedStr = closedList.join(', ') + ': Closed';
  }

  return {'hours': processedHours, 'closed': closedStr};
}
