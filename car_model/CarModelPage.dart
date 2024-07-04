import 'package:flutter/material.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';
import '/flutter_flow/flutter_flow_theme.dart';

class CarModelPage extends StatefulWidget {
  const CarModelPage({Key? key}) : super(key: key);

  @override
  State<CarModelPage> createState() => _CarModelPageState();
}

class _CarModelPageState extends State<CarModelPage> {
  late Flutter3DController controller;
  String? chosenTexture = 'assets/logo.png';
  // List of available models. Assuming these are the paths to your models.
  List<String> availableModels = [
    'assets/Mehran.glb',
    'assets/car_m.glb',
    'assets/Mehran3.glb',
  ];
  String chosenModel = 'assets/Mehran3.glb'; // Default model

  @override
  void initState() {
    super.initState();
    controller = Flutter3DController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFF54E4E),
        title: Text(
          'Car Model',
          style: FlutterFlowTheme.of(context).headlineMedium.override(
                fontFamily: 'Montserrat',
                color: Colors.white,
                fontSize: 22.0,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
      body: Container(
        color: Colors.white,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Flutter3DViewer(
          controller: controller,
          src: chosenModel, // Use chosenModel for the source
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.small(
            onPressed: () async {
              List<String> availableTextures =
                  await controller.getAvailableTextures();
              chosenTexture = await showPickerDialog(
                  context, availableTextures, chosenTexture);
              if (chosenTexture != null) {
                controller.setTexture(textureName: chosenTexture!);
              }
            },
            child: const Icon(Icons.texture),
            heroTag: 'texture',
          ),
          SizedBox(height: 10),
          FloatingActionButton.small(
            onPressed: () {
              // Directly using availableModels for the dialog
              showModelPickerDialog(context, availableModels);
            },
            child: const Icon(Icons.directions_car),
            heroTag: 'model',
          ),
        ],
      ),
    );
  }

  Future<void> showModelPickerDialog(
      BuildContext context, List<String> models) async {
    String? model = await showPickerDialog(context, models, chosenModel);
    if (model != null) {
      setState(() {
        chosenModel = model;
        // Directly setting the model path to the viewer's source
      });
    }
  }

  Future<String?> showPickerDialog(BuildContext context, List<String> inputList,
      [String? chosenItem]) async {
    return await showModalBottomSheet<String>(
        context: context,
        builder: (ctx) {
          return SizedBox(
            height: 250,
            child: ListView.separated(
              itemCount: inputList.length,
              padding: const EdgeInsets.only(top: 16),
              itemBuilder: (ctx, index) {
                return InkWell(
                  onTap: () {
                    Navigator.pop(context, inputList[index]);
                  },
                  child: Container(
                    height: 50,
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${index + 1}'),
                        Text(inputList[index]),
                        Icon(chosenItem == inputList[index]
                            ? Icons.check_box
                            : Icons.check_box_outline_blank),
                      ],
                    ),
                  ),
                );
              },
              separatorBuilder: (ctx, index) {
                return const Divider(
                  color: Colors.white,
                  thickness: 0.6,
                  indent: 10,
                  endIndent: 10,
                );
              },
            ),
          );
        });
  }
}
