import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moto_note/models/Accessory.dart';
import 'package:uuid/uuid.dart';

class NewAccessory extends StatefulWidget {
  final Function addAccessory, editAccessory;
  int status;
  Accessory accessory;

  NewAccessory(
      {this.addAccessory, this.editAccessory, this.status, this.accessory});

  @override
  _NewAccessoryState createState() => _NewAccessoryState();
}

class _NewAccessoryState extends State<NewAccessory> {

  TextEditingController _accessoryController;
  TextEditingController _noteController;
  TextEditingController _valueController;
  TextEditingController _destinationController;
  var uuid = Uuid();

  @override
  void initState() {
    super.initState();

    if (widget.accessory != null) {
      _accessoryController =
      new TextEditingController(text: widget.accessory.name);
      _noteController = new TextEditingController(text: widget.accessory.note);
      _valueController =
      new TextEditingController(text: widget.accessory.value.toString());
      _destinationController =
      new TextEditingController(text: widget.accessory.destination.toString());
    } else {
      _accessoryController = new TextEditingController();
      _noteController = new TextEditingController();
      _valueController = new TextEditingController();
      _destinationController = new TextEditingController();
    }
  }

  void _submitData(int _status, Accessory accessory) {
    if (_status == 1) {
      if (_valueController.text.isEmpty) {
        return;
      }
      final enteredAccessory = _accessoryController.text;
      final enteredNote = _noteController.text;
      final enteredValue = int.parse(_valueController.text);
      final enteredDestination = int.parse(_destinationController.text);

      if (enteredAccessory.isEmpty || enteredNote.isEmpty ||
          enteredValue <= 0 ||
          enteredDestination <= 0) {
        return;
      }
      widget.addAccessory(
        uuid.v4(),
        enteredAccessory,
        enteredNote,
        enteredValue,
        enteredDestination,
        1,
      );
      Navigator.of(context).pop();
    } else if (_status == 2) {
      if (_valueController.text.isEmpty) {
        return;
      }
      final enteredAccessory = _accessoryController.text;
      final enteredNote = _noteController.text;
      final enteredValue = int.parse(_valueController.text);
      final enteredDestination = int.parse(_destinationController.text);
      if (enteredAccessory.isEmpty || enteredNote.isEmpty ||
          enteredValue <= 0 ||
          enteredDestination <= 0) {
        return;
      }
      widget.editAccessory(
        accessory.id,
        enteredAccessory,
        enteredNote,
        enteredValue,
        enteredDestination,
        2,
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'Accessory'),
              controller: _accessoryController,
              onSubmitted: (_) => _submitData(widget.status, widget.accessory),
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Note'),
              controller: _noteController,
              onSubmitted: (_) => _submitData(widget.status, widget.accessory),
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Value'),
              controller: _valueController,
              keyboardType: TextInputType.number,
              onSubmitted: (_) => _submitData(widget.status, widget.accessory),
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Destination'),
              controller: _destinationController,
              keyboardType: TextInputType.number,
              onSubmitted: (_) => _submitData(widget.status, widget.accessory),
            ),
            Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery
                      .of(context)
                      .viewInsets
                      .bottom),
              child: widget.status == 1
                  ? RaisedButton(
                child: Text('Add'),
                color: Theme
                    .of(context)
                    .primaryColor,
                textColor: Theme
                    .of(context)
                    .textTheme
                    .button
                    .color,
                onPressed: () =>
                    _submitData(widget.status, widget.accessory),
              )
                  : RaisedButton(
                child: Text('Edit'),
                color: Theme
                    .of(context)
                    .primaryColor,
                textColor: Theme
                    .of(context)
                    .textTheme
                    .button
                    .color,
                onPressed: () =>
                    _submitData(widget.status, widget.accessory),
              ),
            )
          ],
        ),
      ),
    );
  }
}
