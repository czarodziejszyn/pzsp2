import 'package:flutter/material.dart';

class InfoDialogElement extends StatelessWidget {
  const InfoDialogElement({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color.fromARGB(255, 235, 240, 255),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: const Text(
        'Informacje',
        style: TextStyle(
          color: Color.fromARGB(255, 58, 92, 153),
          fontWeight: FontWeight.bold,
        ),
      ),
      content: const SizedBox(
        width: 500,
        child: Text(
          'MoovIT to aplikacji wspierającej indywidualną naukę tańca, '
          'umożliwiającą użytkownikowi porównywanie swoich ruchów do profesjonalnych nagrań '
          'w czasie rzeczywistym. Aplikacja pozwala na dopasowanie treningu do zainteresowań '
          'użytkownika i pomaga przełamywać bariery w dostępie do nauki tańca.',
          style: TextStyle(
            fontSize: 16,
            height: 1.5,
            color: Colors.black87,
          ),
          softWrap: true,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: const Color.fromARGB(255, 58, 92, 153),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text('Zamknij'),
          ),
        ),
      ],
    );
  }
}

