// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:provider/provider.dart';
// import 'package:talent_flow/app/core/extensions.dart';
// import '../app/core/app_strings.dart';
// import '../app/core/dimensions.dart';
// import '../components/shimmer/custom_shimmer.dart';
// import '../features/maps/models/location_model.dart';
//
// class MapWidget extends StatelessWidget {
//   const MapWidget({this.point, super.key, this.onTap});
//   final LocationModel? point;
//   final Function(LatLng)? onTap;
//
//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider(
//       create: (_) => MapProvider(),
//       child: Consumer<MapProvider>(builder: (context, vm, _) {
//         if (vm.isLoad) {
//           return const MapWidgetShimmer();
//         } else {
//           return Column(
//             children: [
//               SizedBox(
//                 width: context.width,
//                 height: 150.h,
//                 child: GoogleMap(
//                   initialCameraPosition: vm.mapCameraPosition,
//                   onMapCreated: (c) =>
//                       vm.onMapCreated(c, point ?? AppStrings.defaultDrop),
//                   onTap: onTap,
//                   padding: vm.googleMapPadding,
//                   scrollGesturesEnabled: false,
//                   myLocationButtonEnabled: false,
//                   myLocationEnabled: false,
//                   zoomControlsEnabled: false,
//                   markers: vm.gMapMarkers,
//                   mapToolbarEnabled: true,
//                   tiltGesturesEnabled: false,
//                   onCameraMove: (position) async {
//                     vm.target = position.target;
//                   },
//                   onCameraIdle: () async {
//                     vm.setLocation();
//                   },
//                 ),
//               ),
//             ],
//           );
//         }
//       }),
//     );
//   }
// }
//
// class MapWidgetShimmer extends StatelessWidget {
//   const MapWidgetShimmer(
//       {this.withStops = false, this.withClientName = false, Key? key})
//       : super(key: key);
//   final bool withStops;
//   final bool withClientName;
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         CustomShimmerContainer(
//           width: context.width,
//           height: 150.h,
//           radius: 0,
//         )
//       ],
//     );
//   }
// }
