import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:portsecuritysystem/screens/add_face_screen.dart';
import 'package:portsecuritysystem/screens/add_vehicles_screen.dart';
import 'package:portsecuritysystem/screens/view_faces_screen.dart';
import 'package:portsecuritysystem/screens/view_vehicles_screen.dart';
import '../screens/home_screen.dart';
import '../screens/face_entry_log_screen.dart';
import '../screens/vehicle_entry_log_screen.dart';

class Routes {
  static final FluroRouter router = FluroRouter();

  static final routes = <String, WidgetBuilder>{
    '/': (context) => const HomeScreen(),
    '/add-face': (context) => const AddFaceScreen(),
    '/add-vehicle': (context) => const AddVehiclesScreen(),
    '/view-faces': (context) => const ViewFacesScreen(),
    '/view-vehicles': (context) => const ViewVehiclesScreen(),
    '/face-entry-log': (context) => const FaceEntryLogScreen(),
    '/vehicle-entry-log': (context) => const VehicleEntryLogScreen(),
  };

  static void configureRoutes() {
    for (var entry in routes.entries) {
      router.define(
        entry.key,
        handler: Handler(
          handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
            return entry.value(context!);
          },
        ),
        transitionType: TransitionType.fadeIn,
      );
    }

    // Add default route handler
    router.notFoundHandler = Handler(
      handlerFunc: (context, params) => const Scaffold(
        body: Center(child: Text('Route not found')),
      ),
    );
  }
}
