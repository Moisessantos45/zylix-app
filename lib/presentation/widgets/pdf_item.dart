import 'package:flutter/material.dart';

class PdfItem extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  const PdfItem({super.key, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 5),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(Icons.picture_as_pdf,color: Colors.red,size: 32,),
          Expanded(
            child: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          IconButton(onPressed: onTap, icon: Icon(Icons.delete_forever)),
        ],
      ),
    );
  }
}
