import 'package:flutter/material.dart';
import 'package:mynt_plus/sharedWidget/common_text_fields_web.dart';

class EntryPriceTableInput extends StatefulWidget {
  final double value;
  final ValueChanged<double> onChanged;

  const EntryPriceTableInput({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  State<EntryPriceTableInput> createState() => _EntryPriceTableInputState();
}

class _EntryPriceTableInputState extends State<EntryPriceTableInput> {
  late TextEditingController _controller;
  double _lastEmittedValue = 0;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value.toStringAsFixed(2));
    _lastEmittedValue = widget.value;
  }

  @override
  void didUpdateWidget(EntryPriceTableInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Only update text if the incoming value is different from what we last emitted.
    // This allows the user to type freely without the text resetting (re-formatting) on every keystroke
    // when the parent rebuilds.
    if ((widget.value - _lastEmittedValue).abs() > 0.001) {
       // Check if the current text content already represents the new value (e.g. "10." vs 10.0)
       final currentParsed = double.tryParse(_controller.text);
       if (currentParsed != widget.value) {
         _controller.text = widget.value.toStringAsFixed(2);
       }
       _lastEmittedValue = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MyntTextField(
      controller: _controller,
      placeholder: '0.00',
      textAlign: TextAlign.center,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      borderRadius: 4,
      borderColor: Colors.grey[300],
      height: 28,
      onChanged: (val) {
         final price = double.tryParse(val);
         if (price != null) {
           _lastEmittedValue = price;
           widget.onChanged(price);
         }
      },
    );
  }
}
