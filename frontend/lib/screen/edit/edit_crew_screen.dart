import 'package:flutter/material.dart';
import 'package:poligon/main.dart';
import 'package:poligon/provider/auth_provider.dart';
import 'package:poligon/service/crew_service.dart';
import 'package:provider/provider.dart';
import '../../model/crew.dart';
import '../widget/max_width_container.dart';

/// Author: Łukasz Piętka (FUT 2025)
class EditCrewScreen extends StatefulWidget {
  final Crew crew;

  const EditCrewScreen({super.key, required this.crew});

  @override
  State<EditCrewScreen> createState() => _EditCrewScreenState();
}

/// Author: Łukasz Piętka (FUT 2025)
class _EditCrewScreenState extends State<EditCrewScreen> {
  late TextEditingController _nameController;
  late TextEditingController _roomController;
  late TextEditingController _roleController;
  late TextEditingController _phoneController;
  late TextEditingController _descriptionController;
  late TextEditingController _crewQuestController;
  late TextEditingController _imageUrlController;

  late DateTime _sobrietyDay;
  late bool _isSuperAdmin;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.crew.name);
    _roomController = TextEditingController(text: widget.crew.room);
    _roleController = TextEditingController(text: widget.crew.role);
    _phoneController = TextEditingController(text: widget.crew.phoneNumber);
    _descriptionController = TextEditingController(text: widget.crew.description);
    _crewQuestController = TextEditingController(text: widget.crew.crewQuest);
    _imageUrlController = TextEditingController(text: widget.crew.imageUrl);

    _sobrietyDay = widget.crew.sobrietyDay;
    _isSuperAdmin = widget.crew.isSuperAdmin;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _roomController.dispose();
    _roleController.dispose();
    _phoneController.dispose();
    _descriptionController.dispose();
    _crewQuestController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _sobrietyDay,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _sobrietyDay = picked;
      });
    }
  }

  void _saveChanges() async {
    await CrewService().saveOrUpdate(
      Crew(
        id: widget.crew.id,
        name: _nameController.text,
        room: _roomController.text,
        role: _roleController.text,
        imageUrl: _imageUrlController.text,
        sobrietyDay: _sobrietyDay,
        description: _descriptionController.text,
        crewQuest: _crewQuestController.text,
        phoneNumber: _phoneController.text,
        email: widget.crew.email,
        imageAlignmentY: widget.crew.imageAlignmentY,
        isSuperAdmin: _isSuperAdmin,
      ),
    );
    sendSnackBar(context);

    Navigator.of(context).pop();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final me = Provider.of<AuthProvider>(context, listen: false).me;
    final bool canEditAdminFields = me?.isSuperAdmin ?? false;

    return MaxWidthContainer(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edytuj profil'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Imię i nazwisko'),
              ),
              TextField(
                controller: _roomController,
                decoration: const InputDecoration(labelText: 'Pokój'),
              ),
              TextField(
                controller: _roleController,
                decoration: const InputDecoration(labelText: 'Rola'),
              ),
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Telefon'),
              ),
              TextField(
                controller: _imageUrlController,
                decoration: const InputDecoration(labelText: 'URL zdjęcia'),
              ),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Opis'),
                maxLines: 3,
              ),
              TextField(
                controller: _crewQuestController,
                decoration: const InputDecoration(labelText: 'Rozkaz'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              if (canEditAdminFields) ...[
                ListTile(
                  title: Text('Dzień trzeźwości: ${_sobrietyDay.toLocal().toString().split(' ')[0]}'),
                  trailing: Icon(Icons.calendar_today),
                  onTap: _pickDate,
                ),
                SwitchListTile(
                  title: const Text('Super Admin'),
                  value: _isSuperAdmin,
                  onChanged: (value) {
                    setState(() {
                      _isSuperAdmin = value;
                    });
                  },
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Zapisz'),
                onPressed: () {
                  _saveChanges();
                  if(me != null && widget.crew.id == me.id) {
                    Provider.of<AuthProvider>(context, listen: false).reloadMe();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
