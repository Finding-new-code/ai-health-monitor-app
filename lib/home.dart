// Suggested code may be subject to a license. Learn more: ~LicenseLog:2919230285.
// Suggested code may be subject to a license. Learn more: ~LicenseLog:3380387948.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:health/health.dart';
import 'package:fl_chart/fl_chart.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

enum AppState {
  DATA_NOT_FETCHED,
  FETCHING_DATA,
  DATA_READY,
  NO_DATA,
  AUTHORIZED,
  AUTH_NOT_GRANTED,
  DATA_ADDED,
  DATA_DELETED,
  DATA_NOT_ADDED,
  DATA_NOT_DELETED,
  STEPS_READY,
  HEALTH_CONNECT_STATUS,
  PERMISSIONS_REVOKING,
  PERMISSIONS_REVOKED,
  PERMISSIONS_NOT_REVOKED,
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  AppState _state = AppState.DATA_NOT_FETCHED;
  @override
  void initState() {
    super.initState();
    checkPermission();
    Health().configure();
    getHealthConnectSdkStatus();
  }

  /// Gets the Health Connect status on Android.
  Future<void> getHealthConnectSdkStatus() async {
    assert(Platform.isAndroid, "This is only available on Android");

    final status = await Health().getHealthConnectSdkStatus();

    setState(() {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Health Connect Status: ${status?.name.toUpperCase()}'),
      ));
      _state = AppState.HEALTH_CONNECT_STATUS;
    });
    // get data within the last 24 hours
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(hours: 60));
    // get health data
    List<HealthDataPoint> healthData = await Health().getHealthDataFromTypes(
      types: [
        HealthDataType.STEPS,
        HealthDataType.HEART_RATE,
        HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
        HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
        HealthDataType.HEIGHT,
        HealthDataType.WEIGHT,
      ],
      startTime: yesterday,
      endTime: now,
      recordingMethodsToFilter: [],
    );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Total number of data points: ${healthData.length}. '
            '${healthData.length > 100 ? 'Only showing the first 100.' : ''}'),
        backgroundColor: const Color.fromARGB(255, 194, 17, 17),
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  Future<void> checkPermission() async {
    await Permission.activityRecognition.request();
    await Permission.location.request();
    bool hasPermissions = false;
    hasPermissions = (await Health().hasPermissions([
      HealthDataType.STEPS,
      HealthDataType.HEART_RATE,
      HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
      HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
      HealthDataType.HEIGHT,
      HealthDataType.WEIGHT,
    ], permissions: [
      HealthDataAccess.READ
    ]))!;

    if (!hasPermissions) {
      // requesting access to the data types before reading them
      try {
        await Health().requestAuthorization([
          HealthDataType.STEPS,
          HealthDataType.HEART_RATE,
          HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
          HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
          HealthDataType.HEIGHT,
          HealthDataType.WEIGHT,
        ], permissions: [
          HealthDataAccess.READ
        ]);
      } catch (error) {
        debugPrint("Exception in authorize: $error");
      }
    }
  }

  /// Install Google Health Connect on this phone.
  Future<void> installHealthConnect() async =>
      await Health().installHealthConnect();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prototype Artery'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  style: TextStyle(fontSize: 20, color: Colors.black),
                  children: <TextSpan>[
                    TextSpan(
                        text: 'Prototype Artery\n',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                            color: Color.fromARGB(221, 46, 28, 216))),
                    TextSpan(
                        text:
                            'A demo showcasing heart rate data from smartwatches, '),
                    TextSpan(
                        text: 'fed into an AI',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 68, 65, 255))),
                    TextSpan(text: ' for insightful analysis.'),
                  ],
                ),
              ),
            ),
            Offstage(
              offstage: Platform.isAndroid &&
                  Health().healthConnectSdkStatus !=
                      HealthConnectSdkStatus.sdkAvailable,
              child: TextButton(
                  onPressed: installHealthConnect,
                  style: const ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(
                          Color.fromARGB(255, 33, 82, 243))),
                  child: const Text("Open Health Connect",
                      style: TextStyle(color: Colors.white))),
            ),
          
            SizedBox(
              height: 300,
              width: 300,
              // color: Colors.black,
              child: LineChart(
                 LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 1,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return const FlLine(
            color: Color(0xff37434d) ,
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return const FlLine(
            color:  Color(0xff37434d),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            // getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            // getTitlesWidget: leftTitleWidgets,
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 0,
      maxX: 11,
      minY: 0,
      maxY: 6,
      lineBarsData: [
        LineChartBarData(
          spots: const [
            FlSpot(0, 3),
            FlSpot(2.6, 2),
            FlSpot(4.9, 5),
            FlSpot(6.8, 3.1),
            FlSpot(8, 4),
            FlSpot(9.5, 3),
            FlSpot(11, 4),
          ],
          isCurved: true,
          gradient: LinearGradient(
            colors: [
              Colors.redAccent,
              Colors.orange,
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
                 colors: [
              Colors.redAccent,
              Colors.orange,
            ] .map((color) => color.withValues(alpha: 0.3))
                  .toList(),
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
                 
            ),
          ),
        ),
      ],
    ),
              )
              // LineChart(
                
              //   LineChartData(
              //     lineBarsData: [
              //       LineChartBarData(
              //         spots: const [
              //           FlSpot(0, 60),
              //           FlSpot(1, 80),
              //           FlSpot(2, 70),
              //           FlSpot(3, 90),
              //           FlSpot(4, 60),
              //           FlSpot(5, 70),
              //           FlSpot(6, 50),
              //           FlSpot(7, 80),
              //         ],
              //       ),
              //     ],
              //   ),
              // ),
            ),
            const SizedBox(
              height: 100,
            ),
            Center(
              child: Text(
                '❤ Made by NineTails(satya) 👨‍💻',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                  color: const Color.fromARGB(255, 15, 102, 202),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: getHealthConnectSdkStatus,
        tooltip: 'Refresh Data Points',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
