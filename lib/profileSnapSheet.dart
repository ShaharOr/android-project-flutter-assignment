import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:snapping_sheet/snapping_sheet.dart';
import 'package:hello_me/main.dart';

class ProfileSnapSheet extends StatelessWidget {
  var _controller = SnappingSheetController();


  Widget build(BuildContext context) {
    return SnappingSheet(
      snappingSheetController: _controller,

      snapPositions: [
        SnapPosition(
            positionFactor: 0.0,
            snappingCurve: Curves.elasticInOut,
            snappingDuration: Duration(milliseconds: 650)),
        SnapPosition(
            positionFactor: 0.25,
            snappingCurve: Curves.elasticInOut,
            snappingDuration: Duration(milliseconds: 500)),
        // SnapPosition(
        //     positionFactor: 0.7,
        //     snappingCurve: Curves.elasticInOut,
        //     snappingDuration: Duration(milliseconds: 500)),
      ],
      sheetBelow: SnappingSheetContent(
          child: Container(
            padding: EdgeInsets.all(22),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Column(),
                Text('welcome back,user')],
            ),
          ),
          heightBehavior: SnappingSheetHeight.fit()),
      grabbing: Container(
        color: Colors.grey[300],
        child: Container(
          padding: EdgeInsets.fromLTRB(10, 2, 10, 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'welcome back,user',
                style: TextStyle(fontSize: 18),
              ),
              IconButton(
                icon: Icon(Icons.keyboard_arrow_up),
                onPressed: () {
                  if (_controller.snapPositions.last !=
                      _controller.currentSnapPosition) {
                    _controller.snapToPosition(_controller.snapPositions.last);
                  } else {
                    _controller.snapToPosition(_controller.snapPositions.first);
                  }
                },
              ),
            ],
          ),
        ),
      ),
      grabbingHeight: 34,
    );
  }
}
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('ListView example'),
//       ),
//       body: SnappingSheet(
//         sheetBelow: SnappingSheetContent(
//           child: Padding(
//             padding: EdgeInsets.only(top: 20.0),
//             child: Align(
//               alignment: Alignment(0.90, -1.0),
//               child: FloatingActionButton(
//                 onPressed: () {
//                   if(_controller.snapPositions.last != _controller.currentSnapPosition) {
//                     _controller.snapToPosition(_controller.snapPositions.last);
//                   }
//                   else {
//                     _controller.snapToPosition(_controller.snapPositions.first);
//                   }
//                 },
//                 child: RotationTransition(
//                   child: Icon(Icons.arrow_upward),
//                   turns: _arrowIconAnimation,
//                 ),
//               ),
//             ),
//           ),
//         ),
//         onSnapEnd: () {
//           if(_controller.snapPositions.last != _controller.currentSnapPosition) {
//             _arrowIconAnimationController.reverse();
//           }
//           else {
//             _arrowIconAnimationController.forward();
//           }
//         },
//         onMove: (moveAmount) {
//           setState(() {
//             _moveAmount = moveAmount;
//           });
//         },
//         snappingSheetController: _controller,
//         snapPositions: const [
//           SnapPosition(positionFactor: 0.0, snappingCurve: Curves.elasticOut, snappingDuration: Duration(milliseconds: 750)),
//           SnapPosition(positionFactor: 0.3),
//           SnapPosition(positionFactor: 0.7),
//         ],
//         initSnapPosition: SnapPosition(positionFactor: 0.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             Text(
//               'Moved ${_moveAmount.round()} pixels',
//               style: TextStyle(fontSize: 20.0),
//             ),
//           ],
//         ),
//         grabbingHeight: MediaQuery.of(context).padding.top + 50,
//         grabbing: GrabSection(),
//         sheetAbove: SnappingSheetContent(
//             child: SheetContent()
//         ),
//       ),
//     );
//   }
// }
//
//
// class SheetContent extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: Colors.white,
//       child: ListView.builder(
//         padding: EdgeInsets.all(20.0),
//         itemCount: 50,
//         itemBuilder: (context, index) {
//           return Container(
//             decoration: BoxDecoration(
//                 border: Border(bottom: BorderSide(color: Colors.grey[300], width: 1.0))
//             ),
//             child: ListTile(
//               leading: Icon(Icons.info),
//               title: Text('List item $index'),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
//
//
// class GrabSection extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         boxShadow: [BoxShadow(
//           blurRadius: 20.0,
//           color: Colors.black.withOpacity(0.2),
//         )],
//         borderRadius: BorderRadius.only(
//           bottomLeft: Radius.circular(10.0),
//           bottomRight: Radius.circular(10.0),
//         ),
//       ),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: <Widget>[
//           Container(
//             height: 2.0,
//             margin: EdgeInsets.only(left: 20, right: 20),
//             color: Colors.grey[300],
//           ),
//           Container(
//             width: 100.0,
//             height: 10.0,
//             margin: EdgeInsets.only(bottom: 15.0),
//             decoration: BoxDecoration(
//                 color: Colors.grey[300],
//                 borderRadius: BorderRadius.all(Radius.circular(5.0))
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
