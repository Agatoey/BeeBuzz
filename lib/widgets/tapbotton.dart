import 'package:flutter/material.dart';

class TapBotton extends StatefulWidget {
  const TapBotton({super.key, required this.textbt, required this.statebt});

  final String textbt;
  final int statebt;

  @override
  State<TapBotton> createState() => _TapBottonState();
}

class _TapBottonState extends State<TapBotton> {

  late int stateBT = widget.statebt;

  @override
  Widget build(BuildContext context) {
    return stateBT == 1 
    ? Container(
      width: 167.5,
      height: 40,
      decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          shadows: const [
            BoxShadow(
              color: Color(0x26000000),
              blurRadius: 7,
              offset: Offset(0, 3),
              spreadRadius: 0.50,
            )
          ]),
      child: Text(
        widget.textbt,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 12,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
          height: 0.17,
        ),
      ),
    )
    : Container(
      width: 167.5,
      height: 40,
      color: const Color(0x00000000),
      child: Text(
        widget.textbt,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFF2E2E2E),
          fontSize: 12,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
          height: 0.17,
        ),
      ),
    ); 
  }
}
