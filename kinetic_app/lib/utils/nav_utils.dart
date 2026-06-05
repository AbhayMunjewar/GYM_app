import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';

void navigateByTitle(BuildContext context, String title) {
  final lowerTitle = title.toLowerCase();
  final role = authService.currentRole;
  
  if (lowerTitle.contains('dashboard') || lowerTitle == 'home') {
    if (role == UserRole.owner) context.go('/owner-dashboard');
    else if (role == UserRole.trainer) context.go('/trainer-dashboard');
    else context.go('/dashboard');
    return;
  }

  // Owner Routes
  if (role == UserRole.owner) {
    if (lowerTitle.contains('billing')) return context.go('/owner/billing');
    if (lowerTitle.contains('report') || lowerTitle.contains('analytics')) return context.go('/owner/analytics');
    if (lowerTitle.contains('attendance')) return context.go('/owner/attendance');
    if (lowerTitle.contains('trainer') || lowerTitle.contains('training')) return context.go('/owner/trainers');
    if (lowerTitle.contains('member')) return context.go('/owner/members');
    if (lowerTitle.contains('subscription')) return context.go('/owner/subscriptions');
    if (lowerTitle.contains('communication')) return context.go('/owner/communications');
    if (lowerTitle.contains('notification')) return context.go('/owner/notifications');
    if (lowerTitle.contains('setting')) return context.go('/owner/settings');
  }

  // Trainer Routes
  if (role == UserRole.trainer) {
    if (lowerTitle.contains('client') || lowerTitle.contains('member')) return context.go('/trainer/clients');
    if (lowerTitle.contains('schedule') || lowerTitle.contains('training')) return context.go('/trainer/schedule');
    if (lowerTitle.contains('workout') || lowerTitle.contains('assign')) return context.go('/trainer/assign');
    if (lowerTitle.contains('library')) return context.go('/trainer/library');
    if (lowerTitle.contains('diet')) return context.go('/trainer/diet-assign');
    if (lowerTitle.contains('profile') || lowerTitle.contains('setting')) return context.go('/trainer/profile');
  }

  // Member Routes
  if (role == UserRole.member) {
    if (lowerTitle.contains('workout') || lowerTitle.contains('training')) return context.go('/workout-center');
    if (lowerTitle.contains('diet') || lowerTitle.contains('nutrition')) return context.go('/diet-center');
    if (lowerTitle.contains('progress') || lowerTitle.contains('stat') || lowerTitle.contains('analytics')) return context.go('/progress');
    if (lowerTitle.contains('reward')) return context.go('/rewards');
    if (lowerTitle.contains('setting') || lowerTitle.contains('profile')) return context.go('/profile');
    if (lowerTitle.contains('chat') || lowerTitle.contains('buddy')) return context.go('/member/chat');
    if (lowerTitle.contains('form')) return context.go('/member/form-check');
    if (lowerTitle.contains('challenge') || lowerTitle.contains('member')) return context.go('/member/challenges');
    if (lowerTitle.contains('membership')) return context.go('/member/membership');
    if (lowerTitle.contains('notification')) return context.go('/member/notifications');
  }

  // Fallback
  context.go('/');
}
