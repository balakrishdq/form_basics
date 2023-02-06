// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:local_storage_app/handler/log_handler.dart';
import 'package:logger/logger.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';

import '../model/books.dart';

class HomeScreen extends HookWidget {
  // ValueNotifier<List<Books>> selectedBooks;
  HomeScreen({Key? key}) : super(key: key);

  GlobalKey<FormState> _formKey = GlobalKey();
  GlobalKey<FormFieldState> _multiSelectKey = GlobalKey<FormFieldState>();

  @override
  Widget build(BuildContext context) {
    TextEditingController _nameController = useTextEditingController();
    TextEditingController _quantityController = useTextEditingController();
    TextEditingController _dateController = useTextEditingController();
    TextEditingController _timeController = useTextEditingController();
    ValueNotifier<Object?> _gender = useState(null);
    ValueNotifier<String?> _genre = useState(null);
    ValueNotifier<List<Books>> _books = useState([]);
    ValueNotifier<String?> _isSelected = useState(null);
    ValueNotifier<List<Map<String, dynamic>>> _items = useState([]);
    ValueNotifier<Box?> _booksBox = useState(null);

    List<Books> _bookNames = [
      Books(id: 1, name: 'Harry Potter'),
      Books(id: 2, name: 'Transformers'),
      Books(id: 3, name: 'The secret'),
      Books(id: 4, name: 'The Vampire Diaries'),
      Books(id: 5, name: 'The Originals'),
      Books(id: 6, name: 'Ponniyin Selvan'),
      Books(id: 7, name: 'Persuit of Happiness'),
      Books(id: 8, name: 'House of the Dragon'),
      Books(id: 9, name: 'Shashawnk Redemtion'),
      Books(id: 10, name: 'Dunkrik')
    ];

    List<String> names = [
      'English',
      'Hindi',
      'Tamil',
      'Malayalam',
    ];

    void _refreshItems() async {
      final data = _booksBox.value?.keys.map((e) {
        final value = _booksBox.value?.get(e);
        return {'key': e, 'name': value['name'], 'quantity': value['quantity']};
      }).toList();
      _items.value = List.from(data?.reversed.toList() ?? []);
    }

    void initData() async {
      _booksBox.value = await Hive.openBox('books_box');
      _refreshItems();
    }

    Future<void> _createItem(Map<String, dynamic> newItem) async {
      await _booksBox.value?.add(newItem);
      _refreshItems();

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('An Item Created')));
      Map<String, dynamic> _readItem(int key) {
        final item = _booksBox.value?.get(key);
        return item;
      }
    }

    Future<void> _updateItem(int itemKey, Map<String, dynamic> item) async {
      await _booksBox.value?.put(itemKey, item);
      _refreshItems();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('An item has been edited successfully')));
    }

    Future<void> _deleteItem(int itemKey) async {
      await _booksBox.value?.delete(itemKey);
      _refreshItems();

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An item has been deleted')));
    }

    void _showForm(BuildContext context, int? itemKey) {
      if (itemKey != null) {
        final existingItem =
            _items.value.firstWhere((element) => element['key'] == itemKey);
        _nameController.text = existingItem['name'];
        _quantityController.text = existingItem['quantity'];
      }

      showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        elevation: 5,
        builder: (ctx) => StatefulBuilder(builder: (context, updateState) {
          return Container(
            padding: EdgeInsets.only(
                top: 10.sp,
                left: 10.sp,
                right: 10.sp,
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      hintText: 'Name',
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.brown)),
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.brown)),
                    ),
                    validator: (text) {
                      if (_nameController.text == null ||
                          _nameController.text.isEmpty) {
                        return 'Please enter name of the book';
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 1.h,
                  ),
                  TextFormField(
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    validator: (text) {
                      if (_quantityController.text == null ||
                          _quantityController.text.isEmpty) {
                        return 'Please enter quantity of the book';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      hintText: 'Quantity',
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.brown)),
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.brown)),
                    ),
                  ),
                  SizedBox(
                    height: 3.h,
                  ),
                  Container(
                    width: 100.w,
                    height: 25.sp,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(7.sp),
                    ),
                    child: DropdownButton<String>(
                      iconEnabledColor: Colors.brown,
                      underline: Container(
                        height: 0.8.sp,
                        color: Colors.brown,
                      ),
                      isExpanded: true,
                      isDense: true,
                      onChanged: (val) {
                        _genre.value = val;
                      },
                      hint: RichText(
                        text: TextSpan(
                          text: 'Select Genre of the book',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 11.sp,
                          ),
                        ),
                      ),
                      value: _genre.value,
                      selectedItemBuilder: (context) {
                        return [
                          'Fictional',
                          'Horror',
                          'Thriller',
                          'Comedy',
                        ]
                            .map(
                              (e) => Text(
                                e,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 11.sp,
                                ),
                              ),
                            )
                            .toList();
                      },
                      items: [
                        'Fictional',
                        'Horror',
                        'Thriller',
                        'Comedy',
                      ]
                          .map(
                            (e) => DropdownMenuItem(
                              onTap: () {
                                updateState(
                                  () {
                                    _genre.value = e;
                                  },
                                );
                                // Navigator.pop(context);
                              },
                              child: Row(
                                children: [
                                  IgnorePointer(
                                    ignoring: true,
                                    child: Checkbox(
                                      side: BorderSide(color: Colors.black),
                                      hoverColor: Colors.brown,
                                      activeColor: Colors.grey,
                                      checkColor: Colors.white,
                                      fillColor:
                                          MaterialStateProperty.resolveWith(
                                        (states) => Colors.brown,
                                      ),
                                      value: _genre.value == e,
                                      onChanged: (val) {
                                        updateState(
                                          () {
                                            _genre.value = e;
                                          },
                                        );
                                        // Navigator.pop(context);
                                      },
                                    ),
                                  ),
                                  Text(
                                    e,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                ],
                              ),
                              value: e,
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  SizedBox(
                    height: 1.h,
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: MultiSelectDialogField(
                      onConfirm: (p0) {},
                      checkColor: Colors.white,
                      selectedColor: Colors.brown,
                      buttonIcon: Icon(
                        Icons.arrow_downward,
                        color: Colors.brown,
                      ),
                      buttonText: Text('Select books'),

                      searchable: true,
                      searchHint: 'search',
                      separateSelectedItems: true,
                      listType: MultiSelectListType.LIST,
                      //decoration: BoxDecoration(),

                      dialogHeight: 40.h,
                      dialogWidth: 35.w,
                      title: Text('Books'),
                      items: _bookNames
                          .map(
                              (book) => MultiSelectItem<Books>(book, book.name))
                          .toList(),
                      initialValue: _books.value,
                    ),
                  ),
                  SizedBox(
                    height: 1.h,
                  ),
                  TextFormField(
                    controller: _dateController,
                    decoration: InputDecoration(
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.brown)),
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.brown)),
                        suffixIcon: Icon(
                          Icons.calendar_month_outlined,
                          color: Colors.brown,
                        ),
                        labelText: 'Pick Date',
                        labelStyle: TextStyle(color: Colors.brown)),
                    readOnly: true,
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: ColorScheme.light(
                                primary: Colors.brown, // <-- SEE HERE
                                onPrimary: Colors.white, // <-- SEE HERE
                                onSurface: Colors.brown,
                              ),
                              textButtonTheme: TextButtonThemeData(
                                style: TextButton.styleFrom(
                                  foregroundColor:
                                      Colors.brown, // button text color
                                ),
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );

                      if (picked != null) {
                        logger.d(picked);
                        String formattedDate =
                            DateFormat('yyyy-MM-dd').format(picked);
                        logger.d(formattedDate);
                        _dateController.text = formattedDate;
                      }
                    },
                  ),
                  SizedBox(
                    height: 2.h,
                  ),
                  TextFormField(),
                  SizedBox(
                    height: 2.h,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Choose a language',
                        style: TextStyle(color: Colors.brown, fontSize: 12.sp),
                      ),
                      // for (int i = 0; i < names.length; i++)
                      Wrap(
                        children: List.generate(
                          names.length,
                          (index) => Padding(
                            padding: EdgeInsets.only(right: 10.sp, top: 5.sp),
                            child: ChoiceChip(
                              label: Text(names[index]),
                              labelStyle: TextStyle(color: Colors.brown),
                              selected: _isSelected.value == names[index],
                              selectedColor: Color(0xffFFBABA),
                              onSelected: (value) {
                                updateState(
                                  () {
                                    _isSelected.value =
                                        value ? names[index] : null;
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 1.h,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gender',
                        style: TextStyle(color: Colors.brown, fontSize: 12.sp),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 40.w,
                            child: RadioListTile(
                              title: Text('Male'),
                              value: 'male',
                              groupValue: _gender.value,
                              onChanged: (value) {
                                updateState(
                                  () {
                                    _gender.value = value;
                                  },
                                );
                              },
                            ),
                          ),
                          SizedBox(
                            width: 40.w,
                            child: RadioListTile(
                              title: Text('Female'),
                              value: 'female',
                              groupValue: _gender.value,
                              onChanged: (value) {
                                updateState(
                                  () {
                                    _gender.value = value;
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 2.h,
                  ),
                  SizedBox(
                    height: 1.h,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.brown),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            // Save new item
                            if (itemKey == null) {
                              _createItem({
                                "name": _nameController.text,
                                "quantity": _quantityController.text
                              });
                            }

                            // update an existing item
                            if (itemKey != null) {
                              _updateItem(itemKey, {
                                'name': _nameController.text.trim(),
                                'quantity': _quantityController.text.trim()
                              });
                            }
                          }

                          // Clear the text fields
                          _nameController.text = '';
                          _quantityController.text = '';

                          //Close the bootom sheet
                          Navigator.of(context).pop();
                        },
                        child: Text(itemKey == null ? 'Create New' : 'Update'),
                      ),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red),
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text('Cancel'))
                    ],
                  ),
                  SizedBox(
                    height: 2.h,
                  ),
                ],
              ),
            ),
          );
        }),
      );
    }

    useEffect(() {
      initData();
    }, []);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.brown.shade400,
          centerTitle: true,
          title: Text(
            'Books'.toUpperCase(),
            style: TextStyle(
              color: Colors.white,
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        body: _items.value.isEmpty
            ? Center(
                child: Text(
                  'No Data',
                  style: TextStyle(fontSize: 15.sp),
                ),
              )
            : ListView.builder(
                itemCount: _items.value.length,
                itemBuilder: (_, index) {
                  final currentItem = _items.value[index];
                  return Card(
                    color: Colors.brown,
                    margin: EdgeInsets.all(10.sp),
                    elevation: 3,
                    child: ListTile(
                      title: Text(
                        currentItem['name'],
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      subtitle: Text(
                        currentItem['quantity'],
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () =>
                                _showForm(context, currentItem['key']),
                            icon: const Icon(
                              Icons.edit,
                              color: Colors.amber,
                            ),
                          ),
                          IconButton(
                            onPressed: () => _deleteItem(currentItem['key']),
                            icon: const Icon(Icons.delete, color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.brown,
          onPressed: () => _showForm(context, null),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
