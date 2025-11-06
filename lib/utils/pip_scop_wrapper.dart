import 'dart:math';
import 'package:floating/floating.dart';
import 'package:flutter/material.dart';

import 'package:my_location_traker_app/view/common/custom_button.dart';

import 'package:flutter/services.dart';

// adjust import

class GlobalPiPScope extends StatefulWidget {
  final Widget child;
  final Widget pipchild;
  final bool isTracking;

  const GlobalPiPScope({
    super.key,
    required this.child,
    required this.pipchild,
    required this.isTracking,
  });

  @override
  State<GlobalPiPScope> createState() => _GlobalPiPScopeState();
}

class _GlobalPiPScopeState extends State<GlobalPiPScope> {
  final floating = Floating();
  bool isPipAvailable = false;
  bool showOverlay = false;
  bool _isBottomSheetOpen = false;

  @override
  void initState() {
    super.initState();
    checkPipAvailability();
  }

  Future<void> checkPipAvailability() async {
    isPipAvailable = await floating.isPipAvailable;
    if (mounted) setState(() {});
  }

  /// Called when user presses back
  Future<void> _onPopInvoked(bool didPop) async {
    // 🔹 If tracking is ON → show overlay
    if (widget.isTracking) {
      setState(() => showOverlay = true);
      await Future.delayed(const Duration(seconds: 3));
      if (mounted) setState(() => showOverlay = false);
      return;
    }

    // 🔹 If tracking is OFF → show close confirmation bottom sheet
    if (!_isBottomSheetOpen) {
      _isBottomSheetOpen = true;
      if (mounted) buildCloseConfirmation(context);
    }
  }

  Future<void> _enablePip(BuildContext context) async {
    const rational = Rational.landscape();
    final screenSize =
        MediaQuery.of(context).size * MediaQuery.of(context).devicePixelRatio;
    final height = screenSize.width ~/ rational.aspectRatio;

    await floating.enable(
      ImmediatePiP(
        aspectRatio: rational,
        sourceRectHint: Rectangle<int>(
          0,
          (screenSize.height ~/ 2) - (height ~/ 2),
          screenSize.width.toInt(),
          height,
        ),
      ),
    );
  }

  void buildCloseConfirmation(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      backgroundColor: Colors.white,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Are you sure want to close this app..?",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CustomButton(
                      color: Colors.blue,
                      width: 150,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      text: "Cancel",
                    ),
                    CustomButton(
                      color: Colors.red,
                      width: 150,
                      onPressed: () {
                        SystemNavigator.pop();
                      },
                      text: "Close",
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    ).whenComplete(() {
      _isBottomSheetOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PiPSwitcher(
      childWhenDisabled: SafeArea(
        child: PopScope(
          canPop: false,
          onPopInvoked: _onPopInvoked,
          child: Stack(
            fit: StackFit.expand,
            children: [
              widget.child,

              /// 🔹 Overlay only when tracking is ON
              if (widget.isTracking && showOverlay)
                AnimatedOpacity(
                  opacity: showOverlay ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    color: Colors.black.withOpacity(0.85),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.cover,
                        ),
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              "🚗 Tracking in progress\nBack action disabled",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      childWhenEnabled: widget.pipchild,
    );
  }

  @override
  void dispose() {
    floating.cancelOnLeavePiP();
    super.dispose();
  }
}

// class GlobalPiPScope extends StatefulWidget {
//   final Widget child;
//   final Widget pipchild;
//   final bool isTracking;

//   const GlobalPiPScope({
//     super.key,
//     required this.child,
//     required this.pipchild,
//     required this.isTracking,
//   });

//   @override
//   State<GlobalPiPScope> createState() => _GlobalPiPScopeState();
// }

// class _GlobalPiPScopeState extends State<GlobalPiPScope> {
//   final floating = Floating();
//   bool isPipAvailable = false;
//   bool showOverlay = false; // 👈 overlay control flag

//   @override
//   void initState() {
//     super.initState();
//     checkPipAvailability();
//   }

//   Future<void> checkPipAvailability() async {
//     isPipAvailable = await floating.isPipAvailable;
//     if (mounted) setState(() {});
//   }

//   Future<void> _onPopInvoked(bool didPop) async {
//     if (widget.isTracking) {
//       setState(() => showOverlay = true);

//       await Future.delayed(const Duration(seconds: 3));
//       if (mounted) setState(() => showOverlay = false);
//       return;
//     }

//     if (isPipAvailable) {
//       await _enablePip(context);
//     } else {
//       Navigator.of(context).maybePop();
//     }
//   }

//   Future<void> _enablePip(BuildContext context) async {
//     const rational = Rational.landscape();
//     final screenSize =
//         MediaQuery.of(context).size * MediaQuery.of(context).devicePixelRatio;
//     final height = screenSize.width ~/ rational.aspectRatio;

//     await floating.enable(
//       ImmediatePiP(
//         aspectRatio: rational,
//         sourceRectHint: Rectangle<int>(
//           0,
//           (screenSize.height ~/ 2) - (height ~/ 2),
//           screenSize.width.toInt(),
//           height,
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return PiPSwitcher(
//       childWhenDisabled: SafeArea(
//         child: PopScope(
//           canPop: false,
//           onPopInvoked: _onPopInvoked,
//           child: Stack(
//             fit: StackFit.expand,
//             children: [
//               widget.child,
//               if (showOverlay)
//                 AnimatedOpacity(
//                   opacity: showOverlay ? 1.0 : 0.0,
//                   duration: const Duration(milliseconds: 300),
//                   child: Container(
//                     color: Colors.black.withOpacity(0.85),
//                     child: Stack(
//                       fit: StackFit.expand,
//                       children: [
//                         // background image
//                         Image.asset(
//                           'assets/images/logo.png',
//                           fit: BoxFit.cover,
//                         ),

//                         // overlay text
//                         Center(
//                           child: Container(
//                             color: Colors.grey.shade50,
//                             child: Text(
//                               "🚗 Tracking in progress\nBack action disabled",
//                               textAlign: TextAlign.center,
//                               style: const TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 22,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       ),
//       childWhenEnabled: widget.pipchild,
//     );
//   }

//   @override
//   void dispose() {
//     floating.cancelOnLeavePiP();
//     super.dispose();
//   }
// }
