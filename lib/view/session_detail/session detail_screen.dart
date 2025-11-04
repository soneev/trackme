import 'package:flutter/material.dart';
import 'package:my_location_traker_app/model/local_response.dart';
import 'package:my_location_traker_app/utils/utils_funtions.dart';
import 'package:my_location_traker_app/view/common/custom_app_bar.dart';
import 'package:my_location_traker_app/view/home/stored_session_map/stored_session_map.dart';
import 'package:my_location_traker_app/view_model/tracking_viewmodel.dart';
import 'package:provider/provider.dart';

class SessionDetailScreen extends StatelessWidget {
  final SessionModel? session;

  const SessionDetailScreen({super.key, this.session});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Session Detail"),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ✅ Fixed AspectRatio instead of hard height
                    ClipRRect(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.4,
                          child: StoredSessionMapScreen(
                              sessionId: session?.sessionId ?? ""),
                        )
                        // AspectRatio(
                        //   aspectRatio: 16 / 9, // keeps map nicely proportioned
                        //   child: StoredSessionMapScreen(
                        //       sessionId: session?.sessionId ?? ""),
                        // ),
                        ),
                    const SizedBox(height: 20),

                    // ✅ Session Summary Card
                    Consumer<TrackingProvider>(
                      builder: (context, routeInfo, _) {
                        return Card(
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.directions_walk,
                                            color: Colors.indigo, size: 30),
                                        const SizedBox(width: 10),
                                        Text(
                                          "Session Summary",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.indigo.shade800,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: session?.synced ?? false
                                            ? Colors.green.shade100
                                            : Colors.orange.shade100,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            session?.synced ?? false
                                                ? Icons.cloud_done
                                                : Icons.cloud_upload_outlined,
                                            color: session?.synced ?? false
                                                ? Colors.green
                                                : Colors.orange,
                                            size: 14,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            session?.synced ?? false
                                                ? "Synced"
                                                : "Pending",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: session?.synced ?? false
                                                  ? Colors.green.shade700
                                                  : Colors.orange.shade700,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 20),
                                const Divider(),

                                // Session Info
                                _buildRow(Icons.insert_drive_file, "Session ID",
                                    session?.sessionId ?? "N/A"),
                                const SizedBox(height: 12),

                                _buildRow(
                                  Icons.play_circle_fill,
                                  "Start Time",
                                  UtilFunctions.formatDateTimeString(
                                      session?.startTime ?? ""),
                                ),
                                const SizedBox(height: 12),

                                _buildRow(
                                  Icons.stop_circle_rounded,
                                  "End Time",
                                  UtilFunctions.formatDateTimeString(
                                      session?.endTime ?? ""),
                                ),
                                const SizedBox(height: 12),

                                // 🔹 Route Info from Provider
                                _buildRow(
                                    Icons.location_on_outlined,
                                    "Start Address",
                                    routeInfo.startAddress ?? "Fetching..."),
                                const SizedBox(height: 12),

                                _buildRow(Icons.flag, "End Address",
                                    routeInfo.endAddress ?? "Fetching..."),
                                const SizedBox(height: 12),

                                _buildRow(
                                  Icons.social_distance_rounded,
                                  "Distance (API)",
                                  routeInfo.distanceKm != null
                                      ? "${routeInfo.distanceKm!.toStringAsFixed(2)} km"
                                      : "Calculating...",
                                ),
                                const SizedBox(height: 25),

                                Center(
                                  child: ElevatedButton.icon(
                                    icon: const Icon(Icons.map_rounded),
                                    label: const Text(
                                      "View Session Path",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.indigo,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 24, vertical: 12),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                    ),
                                    onPressed: () {},
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.indigo),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            "$title: $value",
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}

// class SessionDetailScreen extends StatelessWidget {
//   final SessionModel? session;

//   const SessionDetailScreen({super.key, this.session});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: CustomAppBar(title: "Session Detail"),
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               Container(
//                 decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.only(
//                         bottomLeft: Radius.circular(20),
//                         bottomRight: Radius.circular(20))),
//                 height: MediaQuery.of(context).size.height / 2,
//                 child:
//                     StoredSessionMapScreen(sessionId: session?.sessionId ?? ""),
//               ),
//               SizedBox(
//                 height: 20,
//               ),
//               Card(
//                 elevation: 6,
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(20)),
//                 child: Padding(
//                   padding: const EdgeInsets.all(20),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Header section
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Row(
//                             children: [
//                               const Icon(Icons.directions_walk,
//                                   color: Colors.indigo, size: 30),
//                               const SizedBox(width: 10),
//                               Text(
//                                 "Session Summary",
//                                 style: TextStyle(
//                                   fontSize: 20,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.indigo.shade800,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           Container(
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 12, vertical: 6),
//                             decoration: BoxDecoration(
//                               color: session?.synced ?? false
//                                   ? Colors.green.shade100
//                                   : Colors.orange.shade100,
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             child: Row(
//                               children: [
//                                 Icon(
//                                   session?.synced ?? false
//                                       ? Icons.cloud_done
//                                       : Icons.cloud_upload_outlined,
//                                   color: session?.synced ?? false
//                                       ? Colors.green
//                                       : Colors.orange,
//                                   size: 18,
//                                 ),
//                                 const SizedBox(width: 6),
//                                 Text(
//                                   session?.synced ?? false
//                                       ? "Synced"
//                                       : "Pending",
//                                   style: TextStyle(
//                                     fontWeight: FontWeight.w600,
//                                     color: session?.synced ?? false
//                                         ? Colors.green.shade700
//                                         : Colors.orange.shade700,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),

//                       const SizedBox(height: 20),
//                       const Divider(),

//                       // Session ID
//                       Row(
//                         children: [
//                           const Icon(Icons.insert_drive_file,
//                               color: Colors.grey),
//                           const SizedBox(width: 10),
//                           Expanded(
//                             child: Text(
//                               session?.sessionId ?? 'N/A',
//                               style: const TextStyle(
//                                 fontSize: 15,
//                                 fontWeight: FontWeight.w500,
//                                 color: Colors.black87,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 18),

//                       // Start time
//                       Row(
//                         children: [
//                           const Icon(Icons.play_circle_fill,
//                               color: Colors.blue),
//                           const SizedBox(width: 10),
//                           Expanded(
//                             child: Text(
//                               "Start Time: ${UtilFunctions.formatDateTimeString(session!.startTime ?? "")}",
//                               style: const TextStyle(fontSize: 15),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 12),

//                       // End time
//                       Row(
//                         children: [
//                           const Icon(Icons.stop_circle_rounded,
//                               color: Colors.redAccent),
//                           const SizedBox(width: 10),
//                           Expanded(
//                             child: Text(
//                               "End Time: ${UtilFunctions.formatDateTimeString(session!.endTime ?? "")}",
//                               style: const TextStyle(fontSize: 15),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 12),

//                       // Distance
//                       Row(
//                         children: [
//                           const Icon(Icons.social_distance_rounded,
//                               color: Colors.teal),
//                           const SizedBox(width: 10),
//                           Expanded(
//                             child: Text(
//                               "Distance: ${session?.distance?.toStringAsFixed(2) ?? 'N/A'} km",
//                               style: const TextStyle(fontSize: 15),
//                             ),
//                           ),
//                         ],
//                       ),

//                       const SizedBox(height: 25),
//                       Center(
//                         child: ElevatedButton.icon(
//                           icon: const Icon(Icons.map_rounded),
//                           label: const Text(
//                             "View Session Path",
//                             style: TextStyle(fontWeight: FontWeight.w600),
//                           ),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.indigo,
//                             foregroundColor: Colors.white,
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 24, vertical: 12),
//                             shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(12)),
//                           ),
//                           onPressed: () {
//                             // navigate to location path page
//                           },
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
