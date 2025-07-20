// import 'package:cloud_firestore/cloud_firestore.dart'; // Temporarily disabled
// import 'package:firebase_auth/firebase_auth.dart' as firebase_auth; // Temporarily disabled
import 'package:uuid/uuid.dart';
import '../models/address.dart';
import 'base_view_model.dart';

class AddressViewModel extends BaseViewModel {
  // Temporarily disabled Firebase dependencies
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // final firebase_auth.FirebaseAuth _firebaseAuth = firebase_auth.FirebaseAuth.instance;
  static const Uuid _uuid = Uuid();
  
  List<Address> _addresses = [];
  Address? _selectedAddress;
  
  List<Address> get addresses => _addresses;
  Address? get selectedAddress => _selectedAddress;
  Address? get defaultAddress => _addresses.where((addr) => addr.isDefault).firstOrNull;
  
  AddressViewModel() {
    // Temporarily disabled Firebase address loading
    // loadAddresses();
  }
  
  Future<void> loadAddresses() async {
    // Temporarily disabled Firebase address loading
    /*
    final user = _firebaseAuth.currentUser;
    if (user == null) return;
    
    await handleAsyncOperation(() async {
      final querySnapshot = await _firestore
          .collection('addresses')
          .where('userId', isEqualTo: user.uid)
          .orderBy('isDefault', descending: true)
          .get();
      
      _addresses = querySnapshot.docs.map((doc) {
        return Address.fromFirestore(doc.data(), doc.id);
      }).toList();
      
      // Set selected address to default if available
      if (_selectedAddress == null && _addresses.isNotEmpty) {
        _selectedAddress = defaultAddress ?? _addresses.first;
      }
      
      notifyListeners();
    });
    */
  }
  
  Future<bool> addAddress(Address address) async {
    // Temporarily disabled Firebase address creation
    /*
    final user = _firebaseAuth.currentUser;
    if (user == null) return false;
    
    return await handleAsyncOperation(() async {
      final addressId = _uuid.v4();
      final addressWithId = Address(
        id: addressId,
        name: address.name,
        street: address.street,
        city: address.city,
        state: address.state,
        zipCode: address.zipCode,
        isDefault: address.isDefault || _addresses.isEmpty, // First address is default
      );
      
      // If this is set as default, unset other defaults
      if (addressWithId.isDefault) {
        await _updateDefaultAddresses(addressId);
      }
      
      final addressData = addressWithId.toFirestore();
      addressData['userId'] = user.uid;
      
      await _firestore.collection('addresses').doc(addressId).set(addressData);
      
      _addresses.add(addressWithId);
      if (addressWithId.isDefault || _selectedAddress == null) {
        _selectedAddress = addressWithId;
      }
      
      notifyListeners();
      return true;
    }) ?? false;
    */
    
    // Placeholder implementation without Firebase
    setError('Address management is temporarily disabled.');
    return false;
  }
  
  Future<bool> updateAddress(Address address) async {
    // Temporarily disabled Firebase address updates
    /*
    return await handleAsyncOperation(() async {
      // If this is set as default, unset other defaults
      if (address.isDefault) {
        await _updateDefaultAddresses(address.id);
      }
      
      await _firestore.collection('addresses').doc(address.id).update(address.toFirestore());
      
      final index = _addresses.indexWhere((addr) => addr.id == address.id);
      if (index != -1) {
        _addresses[index] = address;
        if (_selectedAddress?.id == address.id) {
          _selectedAddress = address;
        }
        notifyListeners();
      }
      
      return true;
    }) ?? false;
    */
    
    // Placeholder implementation without Firebase
    setError('Address management is temporarily disabled.');
    return false;
  }
  
  Future<bool> deleteAddress(String addressId) async {
    // Temporarily disabled Firebase address deletion
    /*
    return await handleAsyncOperation(() async {
      await _firestore.collection('addresses').doc(addressId).delete();
      
      _addresses.removeWhere((addr) => addr.id == addressId);
      
      if (_selectedAddress?.id == addressId) {
        _selectedAddress = defaultAddress ?? (_addresses.isNotEmpty ? _addresses.first : null);
      }
      
      notifyListeners();
      return true;
    }) ?? false;
    */
    
    // Placeholder implementation without Firebase
    setError('Address management is temporarily disabled.');
    return false;
  }
  
  Future<bool> setDefaultAddress(String addressId) async {
    // Temporarily disabled Firebase default address setting
    /*
    return await handleAsyncOperation(() async {
      await _updateDefaultAddresses(addressId);
      
      await _firestore.collection('addresses').doc(addressId).update({'isDefault': true});
      
      for (int i = 0; i < _addresses.length; i++) {
        _addresses[i] = _addresses[i].copyWith(isDefault: _addresses[i].id == addressId);
      }
      
      _selectedAddress = _addresses.firstWhere((addr) => addr.id == addressId);
      notifyListeners();
      
      return true;
    }) ?? false;
    */
    
    // Placeholder implementation without Firebase
    setError('Address management is temporarily disabled.');
    return false;
  }
  
  /*
  Future<void> _updateDefaultAddresses(String newDefaultId) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return;
    
    // Set all other addresses to non-default
    final batch = _firestore.batch();
    final querySnapshot = await _firestore
        .collection('addresses')
        .where('userId', isEqualTo: user.uid)
        .where('isDefault', isEqualTo: true)
        .get();
    
    for (var doc in querySnapshot.docs) {
      if (doc.id != newDefaultId) {
        batch.update(doc.reference, {'isDefault': false});
      }
    }
    
    await batch.commit();
  }
  */
  
  void selectAddress(Address address) {
    _selectedAddress = address;
    notifyListeners();
  }
  
  Address? findAddressById(String id) {
    try {
      return _addresses.firstWhere((addr) => addr.id == id);
    } catch (e) {
      return null;
    }
  }
}