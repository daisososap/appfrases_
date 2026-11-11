import 'package:flutter/material.dart';
import 'package:frases/data/frases_db.dart';
import 'package:frases/models/frase.dart';

class FormularioScreen extends StatefulWidget {
  final Frase? frase;

  const FormularioScreen({super.key, this.frase});

  @override
  State<FormularioScreen> createState() => _FormularioScreenState();
}

class _FormularioScreenState extends State<FormularioScreen> {
  final _formKey = GlobalKey<FormState>();
  final _db = FrasesDb.instancia;

  late String _textoFrase;
  late String _autor;

  @override
  void initState() {
    super.initState();
    _textoFrase = widget.frase?.frase ?? '';
    _autor = widget.frase?.autor ?? '';
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    if (widget.frase == null) {
      final nuevaFrase = Frase(frase: _textoFrase, autor: _autor);
      await _db.insert(nuevaFrase);
    } else {
      final fraseEditada = Frase(
        id: widget.frase!.id,
        frase: _textoFrase,
        autor: _autor,
      );
      await _db.actualizar(fraseEditada);
    }

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final esEdicion = widget.frase != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(esEdicion ? 'Editar Frase' : 'Nueva Frase'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _textoFrase,
                decoration: const InputDecoration(
                  labelText: 'Frase',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor ingresa la frase';
                  }
                  return null;
                },
                onSaved: (value) => _textoFrase = value!.trim(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _autor,
                decoration: const InputDecoration(
                  labelText: 'Autor',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor ingresa el autor';
                  }
                  return null;
                },
                onSaved: (value) => _autor = value!.trim(),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _guardar,
                  icon: const Icon(Icons.save),
                  label: Text(esEdicion ? 'Actualizar Frase' : 'Guardar Frase'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
