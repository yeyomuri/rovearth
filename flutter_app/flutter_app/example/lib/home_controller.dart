// ignore_for_file: public_member_api_docs

import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_example/ChatPage.dart';
import 'package:google_maps_flutter_example/helpers/asset_to_byte.dart';
import 'dart:math';
import 'package:maps_toolkit/maps_toolkit.dart' as mp;

class HomeController extends ChangeNotifier {
  final Completer<BitmapDescriptor> _markerPoint = Completer();
  HomeController() {
    assetToBytes(path: 'assets/dot.png', width: 2).then(
      (value) {
        final bitmap = BitmapDescriptor.fromBytes(value);
        _markerPoint.complete(bitmap);
      },
    );
  }

  //Markers
  Map<MarkerId, Marker> _markers = {};
  Set<Marker> get markers => _markers.values.toSet();
  List<String> shareCoordinates = [];

  //Polygon
  String _polygonId = '';
  Map<PolygonId, Polygon> _polygons = {};
  Set<Polygon> get polygons => _polygons.values.toSet();

  final initialCameraPosition =
      CameraPosition(target: LatLng(2.472744, -76.585142), zoom: 15);

  void deletePolygon() {
    //_polygonId = DateTime.now().millisecondsSinceEpoch.toString();
    _polygons = {};
    _markers = {};
    shareCoordinates = [];
    notifyListeners();
  }

  String sendMessage() {
    return shareCoordinates.join(', ');
  }

  void matrizPoints({Polygon? polygon, required LatLng position}) async {
    _markers = {};

    assert(polygon!.points.isNotEmpty);

    List<LatLng> coordinates = polygon!.points;
    List<double> lats = coordinates.map((e) => e.latitude).toList();
    List<double> lngs = coordinates.map((e) => e.longitude).toList();

    // mpPolygon
    List<mp.LatLng> listMpCoordinates = [];
    for (int i = 0; i < lats.length; i++) {
      listMpCoordinates.add(mp.LatLng(lats[i], lngs[i]));
    }

    final area = mp.SphericalUtil.computeArea(listMpCoordinates);
    print('El area del Poligono es: $area metros cuadrados');
    print('El area del Poligono es: ${area / 10000} hectareas');

    //Coordinates maximas y minimas
    double latMin = lats.reduce(min);
    double latMax = lats.reduce(max);
    double lngMin = lngs.reduce(min);
    double lngMax = lngs.reduce(max);

    //Tiene el objetivo de estima un metro de longitud en funcion de las coordenadas elipsoidales del planeta
    double startLatitude = latMax;
    double startLongitude = lngMin;
    double endLatitude = latMax;
    double endLongitude = lngMax;

    LatLng startCoordinate = LatLng(latMax, lngMin);
    LatLng horizontalEndMesured = LatLng(latMax, lngMax);
    LatLng verticalEndMesured = LatLng(latMin, lngMin);

    final horizontaldDistance = Geolocator.distanceBetween(
        startLatitude, startLongitude, endLatitude, endLongitude);
    final verticalDistance = Geolocator.distanceBetween(
        startLatitude, startLongitude, latMin, lngMin);

    print(
        'la distancia horizontal con Geolocator es: ${horizontaldDistance} m');

    print('la distancia vertical con Geolocator es: ${verticalDistance} m');
    //Numero de muestras por fila

    double separation = 0; //metros
    int? verticalDivision;
    int? horizontalDivision;
    // Area menor a 10.000 metros o una hectarea
    if (area > 0 && area < 10000) {
      separation = 10;
    }
    // Area mayor a una hectarea y menor a 10 hectareas
    else if (area < 100000) {
      separation = 12;
    }
    //Area entre 10 y 50 hectareas
    else if (area < 500000) {
      separation = 15;
    } else {
      separation = 20;
    }

    try {
      horizontalDivision = horizontaldDistance ~/ separation; //metros
      verticalDivision = verticalDistance ~/ separation; //metros
    } on IntegerDivisionByZeroException {
      print('No puedes dividir por cero');
    }

    mp.LatLng newMpPositionFromOrigin = mp.SphericalUtil.computeOffset(
        mp.LatLng(startCoordinate.latitude, startCoordinate.longitude), 30, 90);

    LatLng newPositionFromOrigin = LatLng(
        newMpPositionFromOrigin.latitude, newMpPositionFromOrigin.longitude);

    mp.LatLng newMpJumpPositionFromOrigin;
    //Creacion de matriz de muestra en el recuadro

    List<LatLng> markerMatrix = [];
    shareCoordinates = [];

    print('Las divisiones verticales son: $verticalDivision');
    print('Las divisiones horizontales son: $horizontalDivision');

    for (int i = 0; i < verticalDivision! + 1; i++) {
      for (int j = 0; j < horizontalDivision! + 1; j++) {
        newMpPositionFromOrigin = mp.SphericalUtil.computeOffset(
            mp.LatLng(startCoordinate.latitude, startCoordinate.longitude),
            (j * separation),
            90);
        if (mp.PolygonUtil.containsLocation(
            newMpPositionFromOrigin, listMpCoordinates, true)) {
          markerMatrix.add(LatLng(newMpPositionFromOrigin.latitude,
              newMpPositionFromOrigin.longitude));
          shareCoordinates.add(
              '(${newMpPositionFromOrigin.latitude}, ${newMpPositionFromOrigin.longitude})');
        }
      }
      newMpJumpPositionFromOrigin = mp.SphericalUtil.computeOffset(
          mp.LatLng(startCoordinate.latitude, startCoordinate.longitude),
          (separation),
          180);

      startCoordinate = LatLng(newMpJumpPositionFromOrigin.latitude,
          newMpJumpPositionFromOrigin.longitude);
    }

    print('El listado de posiciones es: $markerMatrix');

    //LatLng coordinadeDow = LatLng(latMax, lngMin + oneMeter2LngGrades);
    //LatLng coordinadeRight = LatLng(latMax - 40 * oneMeter2LatGrades, lngMin);

    print('La latitud minima es: $latMin');
    print('La latitud maxima es $latMax');
    print('La longitud minima es: $lngMin');
    print('La longitud maxima es: $lngMax');

    //Markers

    String id = _markers.length.toString();
    MarkerId markerId = MarkerId(id);
    Marker marker = Marker(markerId: MarkerId(id));

    for (LatLng e in markerMatrix) {
      id = _markers.length.toString();
      markerId = MarkerId(id);
      marker = Marker(
        markerId: markerId,
        position: e,
        icon: await _markerPoint.future,
        consumeTapEvents: true,
        visible: false, // Cambiar para mostrar o esconder marcadores
      );
      _markers[markerId] = marker;
    }

    notifyListeners();
  }

  void onTap(LatLng position) async {
    ////@Param Uso de polygons

    final PolygonId polygonId = PolygonId(_polygonId);
    late Polygon polygon;

    if (_polygons.containsKey(polygonId)) {
      final tmp = _polygons[polygonId]!;
      polygon = tmp.copyWith(
        pointsParam: [...tmp.points, position],
      );
    } else {
      polygon = Polygon(
        polygonId: polygonId,
        points: [position],
        fillColor: Colors.yellow.withOpacity(0.2),
        strokeWidth: 4,
        strokeColor: Colors.blue,
      );
    }
    _polygons[polygonId] = polygon;

    notifyListeners();
    matrizPoints(polygon: polygon, position: position);
  }
}
