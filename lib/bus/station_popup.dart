import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';

class StationPopup extends StatefulWidget {
  final Marker marker;
  final String stopName;
  final String imagePath; // Add this field for image
  final String description; // Description of the bus stop

  const StationPopup({
    required this.marker,
    required this.stopName,
    required this.imagePath,
    required this.description,
    super.key
  });

  @override
  _StationPopupState createState() => _StationPopupState();
}

class _StationPopupState extends State<StationPopup> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: 250, // Set the max width for the popup here
      ),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Station name
              Text(
                widget.stopName,
                style: GoogleFonts.lato(
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Image of the bus stop
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  widget.imagePath,
                  width: double.infinity,
                  height: 120,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 8),

              // Expandable section with arrow
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Description",
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    Icon(
                      _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: Theme.of(context).primaryColor,
                    ),
                  ],
                ),
              ),

              // Description section
              if (_isExpanded)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    widget.description,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}