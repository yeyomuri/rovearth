// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_example/home_controller.dart';
import 'package:provider/provider.dart';

class ViewMap extends StatelessWidget {
  const ViewMap({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeController>(
      builder: (_, controller, __) => GoogleMap(
        initialCameraPosition: controller.initialCameraPosition,
        mapType: MapType.hybrid,
        rotateGesturesEnabled: false,
        zoomControlsEnabled: false,
        markers: controller.markers,
        onTap: controller.onTap,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        //polylines: controller.polylines,
        polygons: controller.polygons,
        mapToolbarEnabled: false,
      ),
    );
  }
}
