import 'package:flutter/material.dart';
import 'package:poligon/main.dart';
import '../../model/team.dart';
import '../../service/team_service.dart';
import '../widget/max_width_container.dart';

/// Author: Łukasz Piętka (FUT 2025)
class EditTeamScreen extends StatefulWidget {
  final Team team;
  final bool canEditAll;

  const EditTeamScreen({super.key, required this.team, required this.canEditAll});

  @override
  State<EditTeamScreen> createState() => _EditTeamScreenState();
}

/// Author: Łukasz Piętka (FUT 2025)
class _EditTeamScreenState extends State<EditTeamScreen> {
  late TextEditingController nameController;
  late TextEditingController captainController;
  late TextEditingController pointsController;
  late TextEditingController imageUrlController;
  List<TextEditingController> memberControllers = [];

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.team.name);
    captainController = TextEditingController(text: widget.team.captainName);
    pointsController = TextEditingController(text: widget.team.points.toString());
    imageUrlController = TextEditingController(text: widget.team.imageUrl);

    widget.team.members?.forEach((member) {
      memberControllers.add(TextEditingController(text: member));
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    captainController.dispose();
    pointsController.dispose();
    imageUrlController.dispose();
    for (var c in memberControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void saveTeam() async {
    final updatedTeam = Team(
      id: widget.team.id,
      name: widget.canEditAll ? nameController.text : widget.team.name,
      captainName: widget.canEditAll ? captainController.text : widget.team.captainName,
      points: int.tryParse(pointsController.text) ?? widget.team.points,
      imageUrl: widget.canEditAll ? imageUrlController.text : widget.team.imageUrl,
      members: widget.canEditAll
          ? memberControllers.map((c) => c.text).where((text) => text.isNotEmpty).toList()
          : widget.team.members,
    );

    await TeamService().saveOrUpdate(updatedTeam);
    sendSnackBar(context);
    Navigator.pop(context);
    Navigator.pop(context);
  }

  void deleteTeam() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Potwierdzenie'),
        content: const Text('Na pewno chcesz usunąć tę drużynę?'),
        actions: [
          TextButton(
            child: const Text('Anuluj'),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: const Text('Usuń'),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final secondConfirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Uwaga!'),
          content: const Text(
              'To jest operacja nieodwracalna! Na pewno chcesz usunąć drużynę?'),
          actions: [
            TextButton(
              child: const Text('Anuluj'),
              onPressed: () => Navigator.pop(context, false),
            ),
            TextButton(
              child: const Text('Tak, usuń'),
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        ),
      );

      if (secondConfirm == true) {
        await TeamService().delete(widget.team.id.toInt());
        sendSnackBar(context);
        Navigator.pop(context);
        Navigator.pop(context);
      }
    }
  }

  void addMember() {
    setState(() {
      memberControllers.add(TextEditingController());
    });
  }

  void removeMember(int index) {
    setState(() {
      memberControllers[index].dispose();
      memberControllers.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaxWidthContainer(
      child: Scaffold(
        appBar: AppBar(title: const Text('Edytuj drużynę')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              if (widget.canEditAll)
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nazwa drużyny'),
                ),
              if (widget.canEditAll)
                TextField(
                  controller: captainController,
                  decoration: const InputDecoration(labelText: 'Kapitan'),
                ),
              TextField(
                controller: pointsController,
                decoration: const InputDecoration(labelText: 'Punkty'),
                keyboardType: TextInputType.number,
              ),
              if (widget.canEditAll)
                TextField(
                  controller: imageUrlController,
                  decoration: const InputDecoration(labelText: 'URL zdjęcia'),
                ),
              const SizedBox(height: 16),
              if (widget.canEditAll) ...[
                const Text('Członkowie:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: memberControllers.length,
                  itemBuilder: (_, index) {
                    return Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: memberControllers[index],
                            decoration: InputDecoration(
                              labelText: 'Członek #${index + 1}',
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.remove_circle, color: Colors.red),
                          onPressed: () => removeMember(index),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Dodaj członka'),
                  onPressed: addMember,
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Zapisz zmiany'),
                onPressed: saveTeam,
              ),
              if (widget.canEditAll) ...[
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.delete_forever),
                  label: const Text('Usuń drużynę'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  onPressed: deleteTeam,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
