import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'vault_screen.dart';

class PinScreen extends StatefulWidget {
  const PinScreen({super.key});

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  String enteredPin = "";
  final String correctPin = "1234";

  void _onNumPress(String num) {
    if (enteredPin.length < 4) {
      setState(() => enteredPin += num);
      if (enteredPin.length == 4) _checkPin();
    }
  }

  void _onDelete() {
    if (enteredPin.isNotEmpty) {
      setState(() => enteredPin = enteredPin.substring(0, enteredPin.length - 1));
    }
  }

  void _checkPin() {
    if (enteredPin == correctPin) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const VaultScreen()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('wrong_pin'.tr()), backgroundColor: Colors.red));
      setState(() => enteredPin = "");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock, size: 50, color: Colors.white),
            const SizedBox(height: 20),
            Text('enter_pin'.tr(), style: const TextStyle(fontSize: 20, color: Colors.white)),
            const SizedBox(height: 30),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  width: 15, height: 15,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index < enteredPin.length ? Colors.white : Colors.grey[800],
                  ),
                );
              }),
            ),
            const SizedBox(height: 50),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 1.2),
                itemCount: 12,
                itemBuilder: (context, index) {
                  if (index == 9) return const SizedBox();
                  if (index == 11) return IconButton(onPressed: _onDelete, icon: const Icon(Icons.backspace_outlined, color: Colors.white));
                  final number = index == 10 ? "0" : "${index + 1}";
                  return TextButton(
                    onPressed: () => _onNumPress(number),
                    child: Text(number, style: const TextStyle(fontSize: 24, color: Colors.white)),
                  );
                },
              ),
            ),
            
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('cancel'.tr(), style: const TextStyle(color: Colors.grey)),
            )
          ],
        ),
      ),
    );
  }
}