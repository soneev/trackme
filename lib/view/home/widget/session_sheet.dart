import 'package:flutter/material.dart';
import 'package:my_location_traker_app/view/home/widget/active_radius_card.dart';
import 'package:my_location_traker_app/view/home/widget/session_history.dart';
import 'package:my_location_traker_app/view_model/tracking_viewmodel.dart';
import 'package:provider/provider.dart';

class TrackingSessionSheet extends StatelessWidget {
  const TrackingSessionSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.40,
      minChildSize: 0.40,
      maxChildSize: 0.80,
      builder: (context, scrollController) {
        return Consumer<TrackingProvider>(builder: (context, tvm, _) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  spreadRadius: 2,
                  offset: Offset(0, -3),
                ),
              ],
            ),
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.only(bottom: 30),
              children: [
                // --- Drag Handle ---
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),

                // --- Top Tracking Card ---
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: RadiusCard(
                    isActive: tvm.isTracking,
                  ), // your attractive card widget
                ),

                // --- Header ---
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                  child: Text(
                    "Session History",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                SessionHistory(),

                // --- Session List ---

                // --- Start Button (inside sheet bottom) ---
                const SizedBox(height: 20),
              ],
            ),
          );
        });
      },
    );
  }
}
