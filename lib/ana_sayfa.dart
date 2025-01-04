import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:il_ilce/conttroler/il_ilce_conttroler.dart';
import 'package:il_ilce/widgets/il_ilce_dialog.dart';
import 'package:iller_ve_ilceler/il.dart';
import 'package:iller_ve_ilceler/ilce.dart';

class AnaSayfa extends StatefulWidget {
  const AnaSayfa({super.key});

  @override
  State<AnaSayfa> createState() => _AnaSayfaState();
}

class _AnaSayfaState extends State<AnaSayfa> {
  IlIlceController controller = IlIlceController();

  List<Il> iller = []; //iller Il nesnelerini tutan bir liste
  @override
  void initState() {
    //widget oluşturulduğunda bir kere çalıştırılır.
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((AnaSayfaState) {
      _jsonCozumle();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //Sayfanın temel iskeleti
      appBar: _buildAppbar(context),
      body: _buildBody(context),
    );
  }

  Widget _listeOgesiniOlustur(BuildContext context, int index) {
    return Card(
      child: ExpansionTile(
        title: Row(
          children: [
            Text(iller[index].isim),
          ],
        ),
        leading: Icon(Icons.location_city),
        trailing: Text(iller[index].plakaKodu),
        children: iller[index].ilceler.map((ilce) {
          return ListTile(
            title: Text(ilce.isim),
          );
        }).toList(),
      ),
    );
  }

  AppBar _buildAppbar(BuildContext) {
    return AppBar(
      title: _buildTextAppbar(context),
    );
  }

  Widget _buildTextAppbar(BuildContext) {
    return Row(children: [
      Text(
        "Türkiye'nin İlleri ve İlçeleri",
        style: TextStyle(
            fontSize: 30, fontWeight: FontWeight.bold, color: Colors.blue),
      ),
      SizedBox(width: 30),
      Icon(
        Icons.location_city,
        color: Colors.blue,
        size: 30,
      ),
    ]);
  }

  Widget _buildBody(BuildContext) {
    return Column(children: [
      Expanded(
        child: ListView.builder(
          itemCount: iller.length,
          itemBuilder: _listeOgesiniOlustur,
        ),
      ),
      ElevatedButton(
        onPressed: _denemeTiklandi,
        style: ButtonStyle(
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              // borderRadius: BorderRadius.(40), // Yuvarlak kenarlar

              side: BorderSide(
                color: Colors.green, // Kenarlık rengi
                width: 5, // Kenarlık kalınlığı
              ),
            ),
          ),
          backgroundColor: MaterialStateProperty.all(Colors.yellow),
        ),
        child: const Text(
          "Seçiniz",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.black,
          ),
        ),
      ),
    ]);
  }

  void _jsonCozumle() async {
    String jsonString =
        await rootBundle.loadString("assets/iller_ilceler.json");
    Map<String, dynamic> illerMap = json.decode(jsonString);
    List<String> plakaKodlari = illerMap.keys.toList();

    for (String plakaKodu in plakaKodlari) {
      Map<String, dynamic> ilMap = illerMap[plakaKodu];
      String ilIsmi = ilMap["name"];
      Map<String, dynamic> ilcelerMap = ilMap["districts"];

      List<Ilce> tumIlceler = [];

      for (String ilceKodu in ilcelerMap.keys) {
        Map<String, dynamic> ilceMap = ilcelerMap[ilceKodu];
        String ilceIsmi = ilceMap["name"];
        Ilce ilce = Ilce(ilceIsmi);
        tumIlceler.add(ilce);
      }
      Il il = Il(ilIsmi, plakaKodu, tumIlceler);
      iller.add(il);
    }
    // illeri plaka koduna göre sıralama
    iller.sort((a, b) => a.plakaKodu.compareTo(b.plakaKodu));
    setState(() {});
  }

  void _denemeTiklandi() async {
    String? arananIl = await IlIlceDialog.instance.selectIl(context);
    String? arananIlce;

    /// il arama dialogu

    if (arananIl != null) {
      arananIlce =
          await IlIlceDialog.instance.selectIlce(context, il: arananIl);
    }

    print("Seçilen İl:$arananIl, İlçe: $arananIlce");
    ElevatedButton(
        onPressed: () async {
          final value = await IlIlceDialog.instance.selectIl(context);
          setState(() {
            arananIl = value;
            print(value);
          });
        },
        child: Text(arananIl ?? "İl Ara"));

    /// il seçme dialogu
    ElevatedButton(
        onPressed: () {
          if (arananIl == null) {
            return;
          }
          IlIlceDialog.instance.selectIlce(context, il: arananIl).then((value) {
            setState(() {
              arananIlce = value;
            });
          });
        },
        child: Text(arananIlce ?? "İlçe Ara"));
  }
}
