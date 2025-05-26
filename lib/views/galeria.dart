import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';


// void main() => runApp(MaterialApp(home: GaleriaPersistente()));

class GaleriaPersistente extends StatefulWidget {
  @override
  State<GaleriaPersistente> createState() => _GaleriaPersistenteState();
}

class _GaleriaPersistenteState extends State<GaleriaPersistente>
    with TickerProviderStateMixin {
  final List<_ImagemComDescricao> _imagens = [];
  final ImagePicker _picker = ImagePicker();
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _carregarDadosSalvos();
  }

  Future<void> _carregarDadosSalvos() async {
    _prefs = await SharedPreferences.getInstance();
    final dadosJson = _prefs.getString('galeria') ?? '[]';
    final List dados = jsonDecode(dadosJson);

    for (var item in dados) {
      final file = File(item['path']);
      if (await file.exists()) {
        final controller = AnimationController(
          vsync: this,
          duration: Duration(milliseconds: 500),
        );
        _imagens.add(_ImagemComDescricao(file, item['descricao'], controller));
        controller.forward();
      }
    }
    setState(() {});
  }

  Future<void> _salvarDados() async {
    final dados = _imagens
        .map((e) => {'path': e.file.path, 'descricao': e.descricao})
        .toList();
    await _prefs.setString('galeria', jsonEncode(dados));
  }

  Future<String> _copiarImagemLocal(XFile imagem) async {
    final dir = await getApplicationDocumentsDirectory();
    final novoArquivo = File('${dir.path}/${DateTime.now().millisecondsSinceEpoch}.png');
    return await File(imagem.path).copy(novoArquivo.path).then((f) => f.path);
  }

  Future<String> _pedirDescricao([String descAtual = '']) async {
    String descricao = descAtual;
    final controller = TextEditingController(text: descAtual);
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Descrição'),
        content: TextField(
          controller: controller,
          maxLength: 300,
          decoration: InputDecoration(hintText: 'Digite até 300 caracteres'),
        ),
        actions: [
          TextButton(
              onPressed: () {
                descricao = controller.text;
                Navigator.pop(context);
              },
              child: Text('Salvar')),
        ],
      ),
    );
    return descricao;
  }

  Future<void> _adicionarImagem({int? substituir}) async {
    final XFile? imagemSelecionada = await showDialog(
      context: context,
      builder: (_) => SimpleDialog(
        title: Text('Escolher imagem'),
        children: [
          SimpleDialogOption(
            child: Text('Câmera'),
            onPressed: () async {
              final img = await _picker.pickImage(source: ImageSource.camera);
              Navigator.pop(context, img);
            },
          ),
          SimpleDialogOption(
            child: Text('Galeria'),
            onPressed: () async {
              final img = await _picker.pickImage(source: ImageSource.gallery);
              Navigator.pop(context, img);
            },
          ),
        ],
      ),
    );

    if (imagemSelecionada != null) {
      final localPath = await _copiarImagemLocal(imagemSelecionada);
      final descricao = await _pedirDescricao(
        substituir != null ? _imagens[substituir].descricao : '',
      );
      final file = File(localPath);

      final controller = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 500),
      );

      setState(() {
        if (substituir != null) {
          _imagens[substituir].file = file;
          _imagens[substituir].descricao = descricao;
          _imagens[substituir].controller.forward(from: 0);
        } else {
          final novaImg = _ImagemComDescricao(file, descricao, controller);
          _imagens.add(novaImg);
          controller.forward();
        }
      });

      _salvarDados();
    }
  }

  void _gerenciarImagem(int index) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.delete),
              title: Text('Excluir'),
              onTap: () async {
                setState(() {
                  _imagens[index].controller.dispose();
                  _imagens.removeAt(index);
                });
                Navigator.pop(context);
                await _salvarDados();
              },
            ),
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('Substituir'),
              onTap: () {
                Navigator.pop(context);
                _adicionarImagem(substituir: index);
              },
            ),
            ListTile(
              leading: Icon(Icons.close),
              title: Text('Cancelar'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (var img in _imagens) {
      img.controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cards = List<Widget>.generate(_imagens.length, (index) {
      final img = _imagens[index];
      return GestureDetector(
        onTap: () => _gerenciarImagem(index),
        child: FadeTransition(
          opacity: img.controller.drive(CurveTween(curve: Curves.easeIn)),
          child: Card(
            elevation: 4,
            child: Column(
              children: [
                Expanded(
                  child: Image.file(
                    img.file,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Text(
                    img.descricao,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });

    cards.add(
      GestureDetector(
        onTap: _adicionarImagem,
        child: Card(
          color: Colors.grey[300],
          child: Center(child: Icon(Icons.add, size: 50)),
        ),
      ),
    );

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: AppBar(
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red, Colors.black],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          centerTitle: true,
          title: Text('Galeria'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 0.75,
          children: cards,
        ),
      ),
    );
  }
}

class _ImagemComDescricao {
  File file;
  String descricao;
  AnimationController controller;

  _ImagemComDescricao(this.file, this.descricao, this.controller);
}