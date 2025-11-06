import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_location_traker_app/utils/utils_funtions.dart';
import 'package:my_location_traker_app/view_model/tracking_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class RadiusCard extends StatelessWidget {
  final bool? isActive;
  const RadiusCard({super.key, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return Consumer<TrackingProvider>(builder: (context, tvm, _) {
      return GestureDetector(
        onTap: () {
          if (isActive == false) {
            Provider.of<TrackingProvider>(context, listen: false)
                .loadSessionsWithLocations();
          } else {
            toast("Please Try acfter the active session ends", context,
                isError: true);
          }
        },
        child: Card(
          elevation: 6,
          shadowColor: isActive!
              ? Colors.teal.withOpacity(0.4)
              : Colors.amber.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Stack(
            children: [
              // 🟢 Background shimmer effect
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Shimmer.fromColors(
                  baseColor:
                      isActive! ? Colors.teal.shade600 : Colors.amber.shade600,
                  highlightColor:
                      isActive! ? Colors.teal.shade300 : Colors.amber.shade300,
                  period: const Duration(seconds: 3),
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isActive!
                            ? [
                                Colors.teal.shade400,
                                Colors.teal.shade700,
                              ]
                            : [
                                Colors.amber.shade400,
                                Colors.amber.shade800,
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),
              ),

              //  Foreground content (visible clearly)
              Container(
                height: 100,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    // Left Icon
                    Container(
                      height: 60,
                      width: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: tvm.isLoading
                          ? const CupertinoActivityIndicator(color: Colors.grey)
                          : const Icon(
                              Icons.directions_run,
                              color: Colors.white,
                              size: 30,
                            ),
                    ),
                    const SizedBox(width: 16),

                    // Text Section
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isActive!
                                ? "Tracking Active"
                                : "Tracking In-Atcive",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            isActive!
                                ? "Tracking..!"
                                : "Click here to Refresh your Session",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Status Ico
                    GestureDetector(
                      onTap: () {
                        if (isActive == false) {
                          Provider.of<TrackingProvider>(context, listen: false)
                              .loadSessionsWithLocations();
                        } else {
                          toast("Please Try acfter the active session ends",
                              context,
                              isError: true);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          shape: BoxShape.circle,
                        ),
                        child: isActive!
                            ? const Icon(
                                Icons.check_circle,
                                color: Colors.white,
                                size: 24,
                              )
                            : const Icon(
                                Icons.hourglass_top,
                                color: Colors.white,
                                size: 24,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
