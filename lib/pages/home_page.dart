import 'package:flutter/material.dart';
import 'package:flutter_consulta_cep/models/endereco_model.dart';
import 'package:flutter_consulta_cep/repositories/cep_repository.dart';
import 'package:flutter_consulta_cep/repositories/cep_repository_impl.dart';

class HomePage extends StatefulWidget {

  const HomePage({ super.key });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final CepRepository cepRepository = CepRepositoryImpl();
  EnderecoModel? enderecoModel;

  final formKey = GlobalKey<FormState>();
  final cepEC = TextEditingController();
  bool loading = false;

  @override
  void dispose() {
    cepEC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buscar CEP'),),
      body:  SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(
                controller: cepEC,
                validator: (value) {
                  if(value == null || value.isEmpty) {
                    return 'CEP Obrigatório';
                  }
                  return null;
                },
              ),
              ElevatedButton(
                onPressed: () async {
                  final valid = formKey.currentState?.validate() ?? false;
                  if (valid) {
                    try {
                      setState(() {
                        loading = true;
                        enderecoModel = null;
                      });
                      final endereco = await cepRepository.getCep(cepEC.text);
                      setState(() {
                        enderecoModel = endereco;
                        loading = false;
                      });
                    } catch (e) {
                      setState(() {
                        enderecoModel = null;
                        loading = false;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Erro ao buscar Endereço')),
                      );
                    }
                  }
                },
                child: const Text('Buscar'),
              ),
              Visibility(
                visible: loading,
                child: const CircularProgressIndicator(),
              ),
              Visibility(
                visible: enderecoModel != null,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('CEP ${enderecoModel?.cep}'),
                    Text('Logradouro ${enderecoModel?.logradouro}'),
                    Text('Complemento ${enderecoModel?.complemento}'),
                  ],
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}