import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ww_weather/appbar.dart';
import 'package:ww_weather/controller/WeatherController.dart';
import 'package:ww_weather/setting.dart';

class WeatherScreen extends StatelessWidget {
  final WeatherController weatherController = Get.put(WeatherController());

  WeatherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const CustomAppBaar(),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Get.to(() => SettingsScreen());
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: weatherController.textController,
              onChanged: (value) {
                weatherController.speechController.cityName.value = value;
              },
              decoration: InputDecoration(
                suffix: InkWell(
                  onTap: weatherController.listenToSpeech,
                  child: Icon(
                    weatherController.speechController.isListening
                        ? Icons.mic
                        : Icons.mic_none,
                    size: 30,
                  ),
                ),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(
                      color: Colors.red,
                      width: 2,
                    )),
                labelText: 'Enter city name',
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Obx(() {
                if (weatherController.weatherService.weather.value == null) {
                  return const Text('Enter a city to get weather information.');
                } else {
                  var weather = weatherController.weatherService.weather.value!;
                  return ListView(
                    children: [
                      Center(
                        child: FutureBuilder<String>(
                          future: weatherController.weatherService
                              .getCurrentTime(
                                  weather.country!, weather.areaName!),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else if (snapshot.hasError ||
                                snapshot.data == null) {
                              return const Text('Error fetching time');
                            } else {
                              return ListTile(
                                leading: const Icon(CupertinoIcons.time,
                                    color: Colors.blueGrey),
                                title: Text(
                                  'City Time: ${snapshot.data}',
                                  style: const TextStyle(fontSize: 20),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                      ListTile(
                          leading: const Icon(CupertinoIcons.time,
                              color: Colors.blueGrey),
                          title: Text(
                            'India Time: ${formatTime(DateTime.now())}',
                          )),
                      const Divider(),
                      ListTile(
                        leading: const Icon(CupertinoIcons.globe,
                            color: Colors.blue),
                        title: Text(
                          'Country: ${weather.country ?? 'N/A'}',
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                      ListTile(
                        leading: const Icon(CupertinoIcons.location,
                            color: Colors.red),
                        title: Text('City: ${weather.areaName ?? 'N/A'}',
                            style: const TextStyle(fontSize: 20)),
                      ),
                      ListTile(
                        leading: Icon(CupertinoIcons.thermometer,
                            color: _getTemperatureColor(
                                weather.temperature?.celsius)),
                        title: Text(
                            'Temperature: ${weather.temperature?.celsius?.toStringAsFixed(1) ?? 'N/A'} °C',
                            style: const TextStyle(fontSize: 20)),
                      ),
                      ListTile(
                        leading: Icon(
                          _getWeatherIcon(weather.weatherDescription),
                          color: _getWeatherConditionColor(
                              weather.weatherDescription),
                        ),
                        title: Text(
                            'Weather: ${weather.weatherDescription ?? 'N/A'}',
                            style: const TextStyle(fontSize: 20)),
                      ),
                      ListTile(
                        leading: Icon(CupertinoIcons.drop,
                            color: _getHumidityColor(weather.humidity)),
                        title: Text(
                          'Humidity: ${weather.humidity ?? 'N/A'}%',
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                      ListTile(
                        leading: const Icon(CupertinoIcons.sunrise,
                            color: Colors.orange),
                        title: Text(
                          'Sunrise: ${weather.sunrise != null ? formatTime(weather.sunrise!.toLocal()) : 'N/A'}',
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                      ListTile(
                        leading: const Icon(CupertinoIcons.sunset,
                            color: Colors.red),
                        title: Text(
                          'Sunset: ${weather.sunset != null ? formatTime(weather.sunset!.toLocal()) : 'N/A'}',
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                      ListTile(
                        leading: const Icon(CupertinoIcons.calendar,
                            color: Colors.blue),
                        title: Text(
                          'Date: ${weather.sunset != null ? formatDate(weather.sunset!.toLocal()) : 'N/A'}',
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    ],
                  );
                }
              }),
            ),
          ],
        ),
      ),
    );
  }

  String formatTime(DateTime dateTime) {
    return DateFormat('hh:mm a').format(dateTime);
  }

  String formatDate(DateTime dateTime) {
    return DateFormat('dd-MM-yyyy').format(dateTime);
  }

  IconData _getWeatherIcon(String? condition) {
    if (condition == null) return CupertinoIcons.cloud;

    switch (condition.toLowerCase()) {
      case 'clear':
        return CupertinoIcons.sun_max;
      case 'rain':
        return CupertinoIcons.cloud_rain;
      case 'cloudy':
        return CupertinoIcons.cloud;
      case 'storm':
        return CupertinoIcons.cloud_bolt;
      default:
        return CupertinoIcons.cloud;
    }
  }

  Color _getTemperatureColor(double? temp) {
    if (temp == null) return Colors.grey;
    if (temp < 12) {
      return Colors.blue;
    } else if (temp >= 12 && temp <= 25) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  Color _getWeatherConditionColor(String? condition) {
    if (condition == null) return Colors.grey;
    switch (condition.toLowerCase()) {
      case 'clear sky':
        return Colors.yellow;
      case 'shower rain':
        return Colors.blue;
      case 'cloudy':
        return Colors.grey;
      case 'storm':
        return Colors.deepPurple;
      default:
        return Colors.grey;
    }
  }

  Color _getHumidityColor(double? humidity) {
    if (humidity == null) return Colors.grey;
    if (humidity < 30) {
      return Colors.red;
    } else if (humidity >= 30 && humidity < 60) {
      return Colors.orange;
    } else {
      return Colors.blue;
    }
  }
}
