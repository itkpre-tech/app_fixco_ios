import 'package:flutter/material.dart';

class PromoData {
  final String label;
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;
  final Color accent;

  const PromoData({
    required this.label,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.accent,
  });
}

const List<PromoData> kPromos = [
  PromoData(label: 'WELCOME OFFER',  title: 'Exclusive Discount\nOn Your First\nBooking',   subtitle: 'Book before the month ends',                   icon: Icons.local_offer_rounded,    gradient: [Color(0xFF5C0000), Color(0xFFB71C1C)], accent: Color(0xFFFF8A80)),
  PromoData(label: 'NEW SERVICE',    title: 'Professional\nPainting\nServices',              subtitle: 'Transform your space with expert painters',     icon: Icons.format_paint_rounded,   gradient: [Color(0xFF143314), Color(0xFF2E7D32)], accent: Color(0xFF69F0AE)),
  PromoData(label: 'NEW SERVICE',    title: 'Packers &\nMovers\nService',                    subtitle: 'Safe and hassle-free relocation',               icon: Icons.local_shipping_rounded, gradient: [Color(0xFF0D0D1E), Color(0xFF1A237E)], accent: Color(0xFF82B1FF)),
  PromoData(label: 'NEW SERVICE',    title: 'Expert\nHandyman\nServices',                    subtitle: 'Quick fixes for all your home needs',           icon: Icons.handyman_rounded,       gradient: [Color(0xFF3E1400), Color(0xFFBF360C)], accent: Color(0xFFFFAB91)),
  PromoData(label: 'NEW SERVICE',    title: 'Reliable\nPlumbing\nSolutions',                 subtitle: 'Fast and efficient plumbing services',          icon: Icons.plumbing_rounded,       gradient: [Color(0xFF001A5C), Color(0xFF1565C0)], accent: Color(0xFF82B1FF)),
  PromoData(label: 'NEW SERVICE',    title: 'Certified\nElectrical\nWorks',                  subtitle: 'Safe and professional electricians',            icon: Icons.bolt_rounded,           gradient: [Color(0xFF3E2400), Color(0xFFF57F17)], accent: Color(0xFFFFE57F)),
  PromoData(label: 'NEW SERVICE',    title: 'AC Service &\nRepair',                          subtitle: 'Stay cool with expert AC maintenance',          icon: Icons.ac_unit_rounded,        gradient: [Color(0xFF001520), Color(0xFF01579B)], accent: Color(0xFF80D8FF)),
  PromoData(label: 'PREMIUM CARE',   title: 'Annual\nMaintenance\nContracts',                subtitle: 'Hassle-free home maintenance all year',         icon: Icons.verified_rounded,       gradient: [Color(0xFF141F14), Color(0xFF2E7D32)], accent: Color(0xFFC8E6C9)),
];