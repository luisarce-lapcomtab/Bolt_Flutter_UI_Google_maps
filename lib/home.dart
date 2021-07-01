import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

const double _minHeight = 200;
const double _maxHeight = 635;

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldkey = GlobalKey<ScaffoldState>();
  LatLng startingLocation = LatLng(-2.142869, -79.923845);
  final currentLocation = TextEditingController();
  GoogleMapController _mapController;
  AnimationController _animationController;
  double _currentHeight = _minHeight;

  @override
  void initState() {
    getUserLocation();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 675),
    );
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void onCreated(GoogleMapController mapController) {
    _mapController = mapController;
  }

  void getUserLocation() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemark = await Geolocator()
        .placemarkFromCoordinates(position.latitude, position.longitude);
    startingLocation = LatLng(position.latitude, position.longitude);
    currentLocation.text = placemark[0].name;
    _mapController.animateCamera(CameraUpdate.newLatLng(startingLocation));
  }

  void _openDrawer() {
    _scaffoldkey.currentState.openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldkey,
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: _minHeight),
            child: GoogleMap(
              initialCameraPosition:
                  CameraPosition(target: startingLocation, zoom: 15),
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              onMapCreated: onCreated,
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height / 3.4,
            right: 15,
            child: FloatingActionButton(
              mini: true,
              onPressed: () {},
              backgroundColor: Colors.white,
              child: Icon(
                Icons.gps_fixed,
                color: Colors.black,
              ),
            ),
          ),
          Positioned(
            top: 60,
            left: 20,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              maxRadius: 22,
              child: IconButton(
                onPressed: _openDrawer,
                icon: Icon(
                  Icons.menu,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          GestureDetector(
            onVerticalDragUpdate: (details) {
              setState(() {
                final newHeight = _currentHeight - details.delta.dy;
                _animationController.value = _currentHeight / _maxHeight;
                _currentHeight = newHeight.clamp(0.0, _maxHeight);
              });
            },
            onVerticalDragEnd: (details) {
              if (_currentHeight < _maxHeight / 1.4) {
                setState(() {
                  _animationController.reset();
                  _currentHeight = _minHeight;
                });
              } else {
                setState(() {
                  _animationController.forward(
                      from: _currentHeight / _maxHeight);
                  _currentHeight = _maxHeight;
                });
              }
            },
            child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, snapshot) {
                  final value = _animationController.value;
                  return Stack(
                    children: [
                      Positioned(
                        height: lerpDouble(_minHeight, _maxHeight, value),
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: _draggable(),
                      )
                    ],
                  );
                }),
          ),
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, snapshot) => Positioned(
              left: 0,
              right: 0,
              top: -182 * (1 - _animationController.value),
              child: Container(height: 180, child: _appBar()),
            ),
          ),
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, snapshot) => Positioned(
              left: 0,
              right: 0,
              bottom: -52 * (1 - _animationController.value),
              child: PickPlaceMap(),
            ),
          ),
        ],
      ),
      drawer: MyDrawer(),
      drawerEnableOpenDragGesture: false,
    );
  }

  Widget _appBar() {
    return AppBar(
      iconTheme: IconThemeData(color: Colors.black),
      title: Text(
        ' Enter destination ',
        style: TextStyle(
          fontSize: 18.0,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: Icon(Icons.close),
        onPressed: () {
          setState(() {
            _animationController.reverse();
            _currentHeight = 0.0;
          });
        },
      ),
      bottom: PreferredSize(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 21.5),
          child: Column(
            children: [
              _Input(
                controller: currentLocation,
                iconData: Icons.gps_fixed,
                color: Colors.green,
                hintText: ' My location',
              ),
              SizedBox(
                height: 9,
              ),
              Row(
                children: [
                  _Input(
                    iconData: Icons.place_sharp,
                    color: Colors.indigo,
                    hintText: ' Enter destination ',
                  ),
                  Icon(
                    Icons.add,
                    size: 25,
                  ),
                ],
              ),
              SizedBox(
                height: 10.0,
              ),
            ],
          ),
        ),
        preferredSize: Size.fromHeight(80.0),
      ),
    );
  }

  Widget _draggable() {
    return Container(
        //height: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black54,
              offset: Offset(0, -1),
              blurRadius: 3,
            ),
          ],
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15.0),
            topRight: Radius.circular(15.0),
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.all(10.0),
              width: 35,
              color: Colors.grey[300],
              height: 3.5,
            ),
            _searchButton(),
            LocationListTile('Enter home location', Icons.home),
            LocationListTile('Enter work location', Icons.work),
          ],
        ));
  }

  Widget _searchButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _animationController.forward(from: _currentHeight / _maxHeight);
          _currentHeight = _maxHeight;
        });
      },
      child: Container(
        height: 50,
        width: MediaQuery.of(context).size.width / 1.1,
        alignment: Alignment.center,
        padding: EdgeInsets.only(left: 10.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6.0),
          color: Colors.grey[200],
        ),
        child: Text(
          ' Where to? ',
          style: TextStyle(fontSize: 17.5, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class LocationListTile extends StatelessWidget {
  final String head;
  final IconData icon;

  LocationListTile(this.head, this.icon);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 37.0, top: 26.0),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.grey,
            size: 25,
          ),
          SizedBox(width: 22),
          Text(
            head,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          )
        ],
      ),
    );
  }
}

class _Input extends StatelessWidget {
  final IconData iconData;
  final void Function(String) onChanged;
  final String hintText;
  final Function onTap;
  final bool enabled;
  final Color color;
  final TextEditingController controller;

  const _Input({
    Key key,
    this.iconData,
    this.onChanged,
    this.hintText,
    this.onTap,
    this.enabled = false,
    this.color,
    this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(this.iconData, size: 19, color: color),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Container(
            height: 40,
            width: MediaQuery.of(context).size.width / 1.4,
            alignment: Alignment.center,
            padding: const EdgeInsets.only(left: 10.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6.0),
              color: Colors.grey[200],
            ),
            child: TextField(
              controller: controller,
              onTap: onTap,
              enabled: enabled,
              onChanged: onChanged,
              decoration: InputDecoration.collapsed(
                  hintText: hintText,
                  hintStyle: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        )
      ],
    );
  }
}

class MyDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width / 1.2,
      color: Colors.white,
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(
              'Luis Arce',
              style: TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.bold,
              ),
            ),
            accountEmail: Text('lapcomtab@gmail.com'),
            currentAccountPicture: ClipRRect(
              borderRadius: BorderRadius.circular(80),
              child: Image(
                image: NetworkImage(
                    'https://yt3.ggpht.com/ytc/AAUvwni7ZSUh5z0QnkoBgdnRRFNb2AlXsTy8CWXmkME6qw=s88-c-k-c0x00ffffff-no-rj'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          ListTile(
            title: Text('My account'),
            leading: Icon(Icons.person),
          ),
          ListTile(
            title: Text('Settings'),
            leading: Icon(Icons.settings),
          ),
          ListTile(
            title: Text('Help'),
            leading: Icon(Icons.help),
          ),
          ListTile(
            title: Text('Support'),
            leading: Icon(Icons.forum),
          ),
        ],
      ),
    );
  }
}

class PickPlaceMap extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black54, offset: Offset(-1, 0), blurRadius: 2.0)
        ],
      ),
      padding: const EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.place_sharp,
            color: Colors.grey,
          ),
          SizedBox(
            width: 10.0,
          ),
          Text(
            ' Choose on map',
            style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w500),
          )
        ],
      ),
    );
  }
}
