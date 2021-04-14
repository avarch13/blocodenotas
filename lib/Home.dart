import 'package:flutter/material.dart';
import 'package:meu_primeiro_app/helper/AnotacaoHelper.dart';
import 'model/Anotacao.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var _db = AnotacaoHelper();
  List<Anotacao> _anotacoes = List<Anotacao>();
  TextEditingController _tituloController = TextEditingController();
  TextEditingController _descricaoController = TextEditingController();

  _recuperarAnotacoes() async{
    List anotacoesRecuperadas = await _db.recuperarAnotacoes();
    //print("Lista Anotacoes: "+anotacoesRecuperadas.toString());

    List<Anotacao> anotacoesTemporarias = List<Anotacao>();
    for (var item in anotacoesRecuperadas){
      Anotacao anotacao = Anotacao.fromMap(item);
      anotacoesTemporarias.add(anotacao);
    }
    setState(() {
      _anotacoes = anotacoesTemporarias;
    });
    anotacoesTemporarias = null;
  }

  _exibirTelaCadastro({Anotacao anotacao}){

    String textoSalvarAtualizar = "";
    if(anotacao == null){
      _tituloController.text = "";
      _descricaoController.text = "";
      textoSalvarAtualizar = "Salvar";
    }else{
      _tituloController.text = anotacao.titulo;
      _descricaoController.text = anotacao.descricao;
      textoSalvarAtualizar = "Atualizar";
    }

    showDialog(context: context,
        builder: (context){
          return AlertDialog(
            title: Text("$textoSalvarAtualizar anotacao"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _tituloController,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: "Título",
                    hintText: "Digite um título..."
                  ),
                ),
                TextField(
                  controller: _descricaoController,
                  autofocus: true,
                  decoration: InputDecoration(
                      labelText: "Descricao",
                      hintText: "Digite o conteúdo..."
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancelar")
              ),
              TextButton(
                onPressed: (){
                  //salvar
                  _salvarAtualizarAnotacao(anotacaoSelecionada: anotacao);
                  Navigator.pop(context);
                },
                child: Text("$textoSalvarAtualizar"),
              )
            ],
          );
        }
    );
  }

  _salvarAtualizarAnotacao({Anotacao anotacaoSelecionada}) async {

    String titulo = _tituloController.text;
    String descricao = _descricaoController.text;

    if(anotacaoSelecionada == null){
      Anotacao anotacao = Anotacao(titulo, descricao, DateTime.now().toString());
      int resultado = await _db.salvarAnotacao(anotacao);
    }else{
      anotacaoSelecionada.titulo = titulo;
      anotacaoSelecionada.descricao = descricao;
      anotacaoSelecionada.data = DateTime.now().toString();
      int resultado = await _db.atualizarAnotacoes(anotacaoSelecionada);
    }




    _tituloController.text = "";
    _descricaoController.text = "";
    _recuperarAnotacoes();
  }

  _formatarData(String data){
    initializeDateFormatting("pt_BT");

    var formatador = DateFormat("d/MM/y - HH:mm:ss");

    DateTime dataConvertida = DateTime.parse(data);
    String dataFormatada = formatador.format(dataConvertida);

    return dataFormatada;
  }

  _removerAnotacao(int id) async {
    _db.removerAnotacoes(id);
    _recuperarAnotacoes();
  }

  @override
  void initState() {
    super.initState();
    _recuperarAnotacoes();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Minhas Anotacoes"),
        backgroundColor: Colors.amberAccent
      ),
      body: Column(
        children: [
          Expanded(
              child: ListView.builder(
                itemCount: _anotacoes.length,
                itemBuilder: (context, index){
                  final item = _anotacoes[index];
                  return Card(
                    child: ListTile(
                      title: Text(item.titulo),
                      subtitle: Text("${_formatarData(item.data)} - ${item.descricao}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: (){
                              _exibirTelaCadastro(anotacao: item);
                            },
                            child: Padding(
                              padding: EdgeInsets.only(right: 16),
                              child: Icon(
                                Icons.edit,
                                color: Colors.amberAccent,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: (){
                              _removerAnotacao(item.id);
                            },
                            child: Padding(
                              padding: EdgeInsets.only(right: 0),
                              child: Icon(
                                Icons.delete,
                                color: Colors.redAccent,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              )
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.amberAccent,
          foregroundColor: Colors.white,
          child: Icon(Icons.add),
          onPressed: (){
            _exibirTelaCadastro();
          }
      ),
    );
  }
}
