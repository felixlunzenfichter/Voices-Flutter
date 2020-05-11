import 'package:flutter/foundation.dart';
import 'package:contacts_service/contacts_service.dart';

class ContactService {
  Future<List<Contact>> getAllContacts() async {
    List<Contact> contacts = (await ContactsService.getContacts()).toList();
    return contacts;
  }

  openNativeDialogToAddContact() async {
    // Throws a error if the Form could not be open or the Operation is canceled by the User
    await ContactsService.openContactForm();
  }

  deleteContact({@required Contact contact}) async {
    // The contact must have a valid identifier
    await ContactsService.deleteContact(contact);
  }

  openNativeDialogToUpdateContact({@required Contact contact}) async {
    // The contact must have a valid identifier
    // Throws a error if the Form could not be open or the Operation is canceled by the User
    await ContactsService.openExistingContact(contact);
  }
}
