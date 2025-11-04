import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_location_traker_app/utils/utils_funtions.dart';
import 'package:my_location_traker_app/view/common/no_data_found.dart';

import 'package:my_location_traker_app/view/session_detail/session%20detail_screen.dart';
import 'package:my_location_traker_app/view_model/tracking_viewmodel.dart';
import 'package:provider/provider.dart';

class SessionHistory extends StatefulWidget {
  const SessionHistory({super.key});

  @override
  State<SessionHistory> createState() => _SessionHistoryState();
}

class _SessionHistoryState extends State<SessionHistory> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Provider.of<TrackingProvider>(context, listen: false)
          .loadSessionsWithLocations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TrackingProvider>(builder: (context, tvm, _) {
      if (tvm.isLoading) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CupertinoActivityIndicator(color: Colors.grey),
              const SizedBox(height: 10),
              Text("Loading..!")
            ],
          ),
        );
      } else if ((tvm.sessionsdata ?? []).isEmpty) {
        return NoDataFOund(
          onRefresh: () async {
            await Provider.of<TrackingProvider>(context, listen: false)
                .loadSessionsWithLocations();
          },
        );
      } else {
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: tvm.sessionsdata.length,
          itemBuilder: (context, index) {
            final session = tvm.sessionsdata[index];
            final startTime = session.startTime ?? "";
            final endTime = session.endTime ?? "";
            final synced = session.synced == true;
            final sessionId = session.sessionId ?? "";

            // Format the time (optional)
            String formatTime(String timeStr) {
              if (timeStr.isEmpty) return "-";
              try {
                final dt = DateTime.parse(timeStr);
                return "${dt.day}-${dt.month}-${dt.year} ${dt.hour}:${dt.minute}";
              } catch (_) {
                return timeStr;
              }
            }

            return InkWell(
              onTap: () {
                tvm.clearPlaces();
                tvm.fetchRouteInfo(
                    startLat: session.locations?.first.latitude ?? 0.0,
                    startLng: session.locations?.first.longitude ?? 0.0,
                    endLat: session.locations?.last.latitude ?? 0.0,
                    endLng: session.locations?.last.latitude ?? 0.0);
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => SessionDetailScreen(
                          session: session,
                        )));
                // _showStoredSessionMap(context, sessionId);
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ListTile(
                  isThreeLine: true, //  allows multi-line subtitle safely
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),

                  //  Leading (Synced/Pending)
                  leading: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cloud,
                          color: synced ? Colors.teal : Colors.grey, size: 22),
                      const SizedBox(height: 4),
                      Text(
                        synced ? "Synced" : "Pending",
                        style: TextStyle(
                          fontSize: 12,
                          color: synced ? Colors.green : Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  // Title (Session ID)
                  title: Text(
                    sessionId != null
                        ? "Session ID: ${(sessionId.length > 6 ? sessionId.substring(0, 6) : sessionId).toUpperCase()}"
                        : "",
                    overflow:
                        TextOverflow.ellipsis, // ✅ prevents right-side overflow
                    maxLines: 1,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: Colors.black),
                  ),

                  // ✅ Subtitle (Start & End Time)
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.access_time,
                              size: 15, color: Colors.teal),
                          const SizedBox(width: 5),
                          Expanded(
                            // ✅ prevent horizontal overflow
                            child: Text(
                              "Start: ${UtilFunctions.formatDateTimeString(startTime)}",
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.access_time,
                              size: 15, color: Colors.red),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              "End: ${UtilFunctions.formatDateTimeString(endTime)}",
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                      // if (session.locations != null)
                      //   Text("${session.locations?.first.longitude}")
                    ],
                  ),

                  // ✅ Trailing delete button
                  trailing: IconButton(
                    onPressed: () async {
                      UtilFunctions.loaderPopup(context);
                      await tvm.deleteSession(sessionId).then((value) {
                        if (value) {
                          // ignore: use_build_context_synchronously
                          Navigator.pop(context);
                          // ignore: use_build_context_synchronously
                          toast("Sucessfully Deleted the session", context,
                              isError: false);
                        } else {
                          // ignore: use_build_context_synchronously
                          Navigator.pop(context);
                          // ignore: use_build_context_synchronously
                          toast("falied to  Deleted the session", context,
                              isError: true);
                        }
                      });
                    },
                    icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: "Delete session",
                  ),
                ),
              ),
            );
          },
        );
      }
    });
  }
}
