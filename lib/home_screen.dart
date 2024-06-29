import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:weather_app/widgets/AdditionalInformation.dart';
import 'package:weather_app/widgets/HourlyForecast.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<Map<String, dynamic>> weather;
  Position? _currentPosition;
  String? _longitude;
  String? _latitude;
  String? _currentAddress;

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }

  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
        _longitude = _currentPosition?.longitude.toString();
        _latitude = _currentPosition?.latitude.toString();
        // print('latitude: $_currentPosition?.latitude');
        // print('longitude: $_currentPosition?.longitude');
      });
      _getAddressFromLatLng();
    }).catchError((e) {
      debugPrint(e);
    });
  }

  Future<void> _getAddressFromLatLng() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
          _currentPosition!.latitude, _currentPosition!.longitude);

      Placemark place = placemarks[0];

      setState(() {
        _currentAddress = "${place.locality},${place.isoCountryCode}";
      });
    } catch (e) {
      print('Error in getAddress');
    }
  }

  Future<Map<String, dynamic>> getCurrentWeather() async {
    try {
      String? APIKey = dotenv.env['weatherAPIKey'];
      //_getCurrentPosition();
      //String cityName = 'Dhaka,BD';
      final result = await http.get(
        Uri.parse(
            'http://api.openweathermap.org/data/2.5/forecast?lat=${_latitude}&lon=${_longitude}&APPID=$APIKey'),
      );

      final data = jsonDecode(result.body);
      if (data['cod'] != '200') {
        throw data['message'];
      }
      return data;
      //print(data['list'][0]['main']['temp']);
    } catch (e) {
      throw e.toString();
    }
  }

  void getlocation() async{
    await _getCurrentPosition();
    await _getAddressFromLatLng();
    await getCurrentWeather();
  }

  @override
  void initState() {
    super.initState();
    _getCurrentPosition();
    _getAddressFromLatLng();
    weather = getCurrentWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Weather App"),
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            _currentAddress.toString(),
            style: TextStyle(
              fontSize: 12,
            ),
          ),
        ),
        /*_latitude != null && _longitude != null
            ? Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Center(
            child: Text(
              'Lat: $_latitude\nLon: $_longitude',
              style: TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
        )
            : null,*/
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.0),
            child: IconButton(
                onPressed: () {
                  setState(() {
                    _getCurrentPosition();
                    _getAddressFromLatLng();
                    weather = getCurrentWeather();
                  });
                },
                icon: Icon(Icons.refresh)),
          ),
        ],
      ),
      body: FutureBuilder(
        future: getCurrentWeather(),
        builder: (context, snapshot) {
          //print(snapshot);
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator.adaptive(),
            );
          }
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }
          final data = snapshot.data!;
          final currentWeatherData = data['list'][0];
          //final temperature = currentWeatherData['main']['temp'];
          final temperatureInKelvin = currentWeatherData['main']['temp'];
          final temperatureInCelsius = temperatureInKelvin - 273.15;
          final temperature = temperatureInCelsius.toStringAsFixed(2);
          final currentSky = currentWeatherData['weather'][0]['main'];
          final currentHumidity = currentWeatherData['main']['humidity'];
          // print(data['list'][0]['wind']['speed']);
          final currentWindSpeed = currentWeatherData['wind']['speed'];
          final currentPressure = currentWeatherData['main']['pressure'];

          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    elevation: 6,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            children: [
                              Text(
                                "$temperature° C",
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              Icon(
                                currentSky == 'Clouds' || currentSky == 'Rain'
                                    ? Icons.cloud
                                    : Icons.sunny,
                                size: 60,
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              Text(
                                currentSky,
                                style: TextStyle(
                                  fontSize: 25,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Text(
                  "Hourly Forcast",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                /*SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for(int i=0; i<12; i++)
                          HourlyForeCastWidgets(
                            time: "03:00",
                            icon: data['list'][i+1]['weather'][0]['main'] == 'Clouds'
                            || data['list'][i+1]['weather'][0]['main'] == 'Rain' ? Icons.cloud : Icons.sunny,
                            temperature: data['list'][i+1]['main']['temp'].toString(),
                          ),
                    ],
                  ),
                ),*/
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                      itemCount: 5,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        final hourlyForecast = data['list'][index + 1];
                        final hourlySky =
                            data['list'][index + 1]['weather'][0]['main'];
                        final temperatureInKelvin =
                            hourlyForecast['main']['temp'];
                        final temperatureInCelsius =
                            temperatureInKelvin - 273.13;
                        final hourlyTemp =
                            temperatureInCelsius.toStringAsFixed(2);
                        //final hourlyTemp = hourlyForecast['main']['temp'].toString();
                        final time = DateTime.parse(hourlyForecast['dt_txt']);
                        return HourlyForeCastWidgets(
                            // time: hourlyForecast['dt_txt'].toString(),
                            time: DateFormat.j().format(time),
                            icon: hourlySky == 'Clouds' || hourlySky == 'Rain'
                                ? Icons.cloud
                                : Icons.sunny,
                            temperature: hourlyTemp);
                      }),
                ),
                const SizedBox(
                  height: 15,
                ),
                Text(
                  "Additional Information",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Additionalinformation(
                      icon: Icons.water_drop,
                      label: "Humidity",
                      value: currentHumidity.toString(),
                    ),
                    Additionalinformation(
                      icon: Icons.air,
                      label: "Wind Speed",
                      value: currentWindSpeed.toString(),
                    ),
                    Additionalinformation(
                      icon: Icons.beach_access,
                      label: "Pressure",
                      value: currentPressure.toString(),
                    ),
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
