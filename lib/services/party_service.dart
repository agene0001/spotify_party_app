import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/party.dart';
import 'package:spotify_party_app/services/auth_service.dart';
import 'package:spotify_party_app/services/user_service.dart';

class PartyService {
  // Use Firestore instance instead of REST API
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService authService = AuthService();
  final UserService userService;  // Add userService here
  PartyService({required this.userService});
  // Collection reference for parties
  CollectionReference get _partiesCollection => _firestore.collection('parties');

  // Get active parties
  Future<List<Party>> getActiveParties() async {
    try {
      // Query active parties from Firestore
      final QuerySnapshot snapshot = await _partiesCollection
          .where('isActive', isEqualTo: true)
          .get();

      return snapshot.docs
          .map((doc) => Party.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting active parties: $e');
      throw Exception('Failed to load parties: $e');
    }
  }

  // Create a new party
  Future<String> createParty(String name) async {
    try {
      final token = await authService.getAccessToken();
      if (token == null) {
        throw Exception('Authentication failed. No access token.');
      }

      // Get current user ID
      final userId = userService.getUserId(); // You'll need to implement this

      // Create new party document in Firestore
      final docRef = await _partiesCollection.add({
        'name': name,
        'createdBy': userId,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'currentTrack': null,
        'isPlaying': false,
        'participants': [userId]
      });

      return docRef.id; // Return the new party ID
    } catch (e) {
      print('Error creating party: $e');
      throw Exception('Failed to create party: $e');
    }
  }

  // Keep the original method name for backwards compatibility
  Future<List<Party>> fetchActiveParties() async {
    return getActiveParties();
  }

  // Skip the current song
  Future<void> skipSong(String partyId) async {
    try {
      final token = await authService.getAccessToken();
      if (token == null) {
        throw Exception('Authentication failed. No access token.');
      }

      // Update the party document with skip request
      await _partiesCollection.doc(partyId).update({
        'skipRequested': true,
        'lastUpdated': FieldValue.serverTimestamp()
      });

      print('Skip request sent successfully!');
    } catch (e) {
      print('Error skipping song: $e');
      throw Exception('Error skipping song');
    }
  }

  // Toggle play/pause
  Future<void> playPause(String partyId) async {
    try {
      final token = await authService.getAccessToken();
      if (token == null) {
        throw Exception('Authentication failed. No access token.');
      }

      // Get current party status
      DocumentSnapshot partyDoc = await _partiesCollection.doc(partyId).get();

      if (!partyDoc.exists) {
        throw Exception('Party not found');
      }

      Map<String, dynamic> partyData = partyDoc.data() as Map<String, dynamic>;
      bool isCurrentlyPlaying = partyData['isPlaying'] ?? false;

      // Toggle play state
      await _partiesCollection.doc(partyId).update({
        'isPlaying': !isCurrentlyPlaying,
        'lastUpdated': FieldValue.serverTimestamp()
      });

      print('Playback toggled successfully.');
    } catch (e) {
      print('Error toggling play/pause: $e');
      throw Exception('Error toggling play/pause');
    }
  }

  // Fetch party details
  Future<Party> fetchPartyDetails(String partyId) async {
    try {
      final token = await authService.getAccessToken();
      if (token == null) {
        throw Exception('Authentication failed. No access token.');
      }

      // Get party document from Firestore
      final DocumentSnapshot doc = await _partiesCollection.doc(partyId).get();

      if (!doc.exists) {
        throw Exception('Party not found');
      }

      return Party.fromFirestore(doc);
    } catch (e) {
      print('Error fetching party details: $e');
      throw Exception('Error fetching party details');
    }
  }

  // NEW METHOD: Listen to real-time updates for a party
  Stream<Party> listenToParty(String partyId) {
    return _partiesCollection
        .doc(partyId)
        .snapshots()
        .map((snapshot) => Party.fromFirestore(snapshot));
  }

  // NEW METHOD: Join a party
  Future<void> joinParty(String partyId) async {
    try {
      final userId = userService.getUserId();

      await _partiesCollection.doc(partyId).update({
        'participants': FieldValue.arrayUnion([userId])
      });
    } catch (e) {
      print('Error joining party: $e');
      throw Exception('Error joining party');
    }
  }

  // NEW METHOD: Leave a party
  Future<void> leaveParty(String partyId) async {
    try {
      final userId = userService.getUserId();

      await _partiesCollection.doc(partyId).update({
        'participants': FieldValue.arrayRemove([userId])
      });
    } catch (e) {
      print('Error leaving party: $e');
      throw Exception('Error leaving party');
    }
  }
}