import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TabScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5, // Jumlah tab sekarang menjadi 5
      child: Scaffold(
        appBar: AppBar(
          title: Text('Tab Menu'),
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.home), text: 'Welcome'),
              Tab(icon: Icon(Icons.place), text: 'List Pariwisata'),
              Tab(icon: Icon(Icons.local_hospital), text: 'Kesehatan'),
              Tab(icon: Icon(Icons.person), text: 'Profile'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            WelcomeTab(),
            PariwisataTab(),
            HospitalTab(),
            ProfileTab(),
          ],
        ),
      ),
    );
  }
}

class WelcomeTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Welcome to the App!'),
    );
  }
}

class PariwisataTab extends StatelessWidget {
  Future<List<Pariwisata>> fetchPariwisata() async {
    try {
      final response = await http.get(Uri.parse(
          'https://ws.jakarta.go.id/gateway/DataPortalSatuDataJakarta/1.0/satudata?kategori=dataset&tipe=detail&url=indeks-kepuasan-layanan-penunjang-urusan-pemerintahan-daerah-pada-dinas-pariwisata-dan-ekonomi-kreatif'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['data'];
        return data.map((place) => Pariwisata.fromJson(place)).toList();
      } else {
        throw Exception('Failed to load pariwisata');
      }
    } catch (e) {
      print('Error fetching data: $e');
      throw Exception('Failed to load pariwisata');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('List Pariwisata'),
      ),
      body: FutureBuilder<List<Pariwisata>>(
        future: fetchPariwisata(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print('Error: ${snapshot.error}');
            return Center(child: Text('Failed to load pariwisata'));
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            final pariwisata = snapshot.data!;
            return ListView.builder(
              itemCount: pariwisata.length,
              itemBuilder: (context, index) {
                final place = pariwisata[index];
                return ListTile(
                  title: Text(place.name),
                  subtitle: Text(place.type),
                );
              },
            );
          } else {
            return Center(child: Text('No pariwisata found'));
          }
        },
      ),
    );
  }
}

class HospitalTab extends StatelessWidget {
  Future<List<Hospital>> fetchHospitals() async {
    final response = await http.get(Uri.parse(
        'https://ws.jakarta.go.id/gateway/DataPortalSatuDataJakarta/1.0/satudata?kategori=dataset&tipe=detail&url=perempuan-dan-anak-korban-kekerasan-yang-mendapatkan-layanan-kesehatan-oleh-tenaga-kesehatan-terlatih-di-puskesmas-mampu-tatalaksana-kekerasan-terhadap-perempuananak-ktpa-dan-pusat-pelayanan-terpadupusat-krisis-terpadu-pptpkt-di-rumah-sakit'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      return data.map((hospital) => Hospital.fromJson(hospital)).toList();
    } else {
      throw Exception('Failed to load hospitals');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('List Kesehatan'),
      ),
      body: FutureBuilder<List<Hospital>>(
        future: fetchHospitals(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Failed to load Kesehatan'));
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            final hospitals = snapshot.data!;
            return ListView.builder(
              itemCount: hospitals.length,
              itemBuilder: (context, index) {
                final hospital = hospitals[index];
                return ListTile(
                  title: Text(hospital.name),
                  subtitle: Text(hospital.address),
                );
              },
            );
          } else {
            return Center(child: Text('No hospitals found'));
          }
        },
      ),
    );
  }
}

class ProfileTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Profile'),
    );
  }
}

class Pariwisata {
  final String name;
  final String type;
  Pariwisata({required this.name, required this.type});
  factory Pariwisata.fromJson(Map<String, dynamic> json) {
    return Pariwisata(
      name: json['periode_data'],
      type: json['jenis_layanan'],
    );
  }
}

class Hospital {
  final String name;
  final String address;
  Hospital({required this.name, required this.address});
  factory Hospital.fromJson(Map<String, dynamic> json) {
    return Hospital(
      name: json['periode_data'],
      address: json['lokasi'],
    );
  }
}

class UserProfile {
  final String name;
  final String email;
  final String phone;
  UserProfile({required this.name, required this.email, required this.phone});
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'], // Ganti dengan key yang sesuai
      email: json['email'], // Ganti dengan key yang sesuai
      phone: json['phone'], // Ganti dengan key yang sesuai
    );
  }
}

void main() => runApp(MaterialApp(home: TabScreen()));
