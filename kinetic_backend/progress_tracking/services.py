from datetime import date, timedelta
from django.db.models import Avg, Min, Max
from django.utils import timezone
from .models import ProgressMeasurement, ProgressPhoto, FitnessGoal, ProgressMilestone, GoalStatus, GoalType
from members.models import Member
from trainers.models import Trainer
from attendance.services import StreakService

class ProgressTrackingService:
    @staticmethod
    def create_measurement(member_id, trainer_id, validated_data):
        """
        Record a new physical measurement, trigger goal recalculations and milestone detection.
        """
        member = Member.objects.get(id=member_id)
        trainer = Trainer.objects.get(id=trainer_id) if trainer_id else None
        
        # Remove validated_data duplicates
        validated_data.pop('member', None)
        validated_data.pop('trainer', None)
        
        measurement = ProgressMeasurement.objects.create(
            member=member,
            trainer=trainer,
            **validated_data
        )
        
        # Trigger recalculations
        GoalTrackingService.update_goals_for_member(member)
        MilestoneDetectionService.detect_milestones(member)
        
        return measurement

    @staticmethod
    def update_measurement(measurement_id, validated_data):
        """
        Update an existing physical measurement and trigger recalculations.
        """
        measurement = ProgressMeasurement.objects.get(id=measurement_id)
        for attr, val in validated_data.items():
            setattr(measurement, attr, val)
        measurement.save()
        
        # Trigger recalculations
        GoalTrackingService.update_goals_for_member(measurement.member)
        MilestoneDetectionService.detect_milestones(measurement.member)
        
        return measurement


class GoalTrackingService:
    @staticmethod
    def create_goal(member_id, validated_data):
        """
        Create a new goal for a member. Baseline weight and body fat are automatically
        set based on the member's current weight/fat or latest measurement.
        """
        member = Member.objects.get(id=member_id)
        
        # Get starting baseline values from latest measurement
        latest_meas = ProgressMeasurement.objects.filter(member=member).first()
        starting_weight = latest_meas.weight_kg if latest_meas else member.weight_kg
        starting_body_fat = latest_meas.body_fat_percentage if latest_meas else 0.0
        
        # Remove validated_data duplicates
        validated_data.pop('member', None)
        
        goal = FitnessGoal.objects.create(
            member=member,
            starting_weight=starting_weight,
            starting_body_fat=starting_body_fat,
            **validated_data
        )
        
        # Compute starting progress
        GoalTrackingService.update_goal_progress(goal, starting_weight, starting_body_fat)
        return goal

    @staticmethod
    def update_goal_progress(goal, current_weight, current_body_fat):
        """
        Recalculate the progress percentage for a single goal and update its status.
        """
        if goal.status in [GoalStatus.ACHIEVED, GoalStatus.FAILED, GoalStatus.CANCELLED]:
            return
            
        progress_pct = 0.0
        is_achieved = False
        
        start_w = goal.starting_weight or 0.0
        target_w = goal.target_weight or 0.0
        start_f = goal.starting_body_fat or 0.0
        target_f = goal.target_body_fat or 0.0

        if goal.goal_type == GoalType.FAT_LOSS:
            # Fat Loss progress (weight decreases)
            if start_w > target_w and current_weight is not None:
                if current_weight <= target_w:
                    progress_pct = 100.0
                    is_achieved = True
                else:
                    weight_diff_target = start_w - target_w
                    weight_lost = start_w - current_weight
                    progress_pct = (weight_lost / weight_diff_target) * 100.0

            # Incorporate body fat if specified
            if start_f > target_f and current_body_fat is not None:
                if current_body_fat <= target_f:
                    fat_progress = 100.0
                    if current_weight is None or current_weight <= target_w:
                        is_achieved = True
                else:
                    fat_diff_target = start_f - target_f
                    fat_lost = start_f - current_body_fat
                    fat_progress = (fat_lost / fat_diff_target) * 100.0
                
                # Average if both target weight and fat are specified
                if start_w > target_w and current_weight is not None:
                    progress_pct = (progress_pct + fat_progress) / 2.0
                else:
                    progress_pct = fat_progress

        elif goal.goal_type in [GoalType.WEIGHT_GAIN, GoalType.MUSCLE_GAIN]:
            # Weight/Muscle Gain progress (weight increases)
            if target_w > start_w and current_weight is not None:
                if current_weight >= target_w:
                    progress_pct = 100.0
                    is_achieved = True
                else:
                    weight_diff_target = target_w - start_w
                    weight_gained = current_weight - start_w
                    progress_pct = (weight_gained / weight_diff_target) * 100.0

            # Incorporate body fat if specified
            if target_f > start_f and current_body_fat is not None:
                if current_body_fat >= target_f:
                    fat_progress = 100.0
                    if current_weight is None or current_weight >= target_w:
                        is_achieved = True
                else:
                    fat_diff_target = target_f - start_f
                    fat_gained = current_body_fat - start_f
                    fat_progress = (fat_gained / fat_diff_target) * 100.0
                
                if target_w > start_w and current_weight is not None:
                    progress_pct = (progress_pct + fat_progress) / 2.0
                else:
                    progress_pct = fat_progress

        elif goal.goal_type == GoalType.MAINTENANCE:
            # Maintenance: progress is 100% as long as weight is within 2kg bounds of starting weight
            if current_weight is not None:
                if abs(current_weight - start_w) <= 2.0:
                    progress_pct = 100.0
                else:
                    progress_pct = max(0.0, 100.0 - (abs(current_weight - start_w) - 2.0) * 10.0)

        # Update status and save
        goal.current_progress_percentage = round(max(0.0, min(100.0, progress_pct)), 1)
        if is_achieved:
            goal.status = GoalStatus.ACHIEVED
        goal.save()

    @staticmethod
    def update_goals_for_member(member):
        """
        Fetch latest measurement for a member and update progress of all active goals.
        """
        latest_meas = ProgressMeasurement.objects.filter(member=member).first()
        if not latest_meas:
            return
            
        active_goals = FitnessGoal.objects.filter(member=member, status=GoalStatus.ACTIVE)
        for goal in active_goals:
            GoalTrackingService.update_goal_progress(
                goal,
                latest_meas.weight_kg,
                latest_meas.body_fat_percentage
            )


class MilestoneDetectionService:
    @staticmethod
    def detect_milestones(member):
        """
        Analyze weight changes, body fat progress, and attendance to unlock achievements.
        """
        today = timezone.localdate()
        
        # 1. Base Weight Reference
        # Earliest recorded weight or fallback to Member join weight
        earliest_meas = ProgressMeasurement.objects.filter(member=member).order_by('recorded_date', 'created_at').first()
        latest_meas = ProgressMeasurement.objects.filter(member=member).order_by('-recorded_date', '-created_at').first()
        
        baseline_weight = earliest_meas.weight_kg if earliest_meas else member.weight_kg
        
        if latest_meas and baseline_weight:
            weight_lost = baseline_weight - latest_meas.weight_kg
            
            # Unlock 5kg lost
            if weight_lost >= 5.0:
                MilestoneDetectionService._unlock_milestone(
                    member, "First 5kg Lost", today, f"{round(weight_lost, 1)} kg lost"
                )
            # Unlock 10kg lost
            if weight_lost >= 10.0:
                MilestoneDetectionService._unlock_milestone(
                    member, "First 10kg Lost", today, f"{round(weight_lost, 1)} kg lost"
                )
            
            # Unlock body fat thresholds
            bf = latest_meas.body_fat_percentage
            if bf > 0:
                if bf < 20.0:
                    MilestoneDetectionService._unlock_milestone(
                        member, "Body Fat Below 20%", today, f"{round(bf, 1)}% body fat"
                    )
                if bf < 15.0:
                    MilestoneDetectionService._unlock_milestone(
                        member, "Body Fat Below 15%", today, f"{round(bf, 1)}% body fat"
                    )
        
        # 2. Attendance Streak check
        streak = StreakService.calculate_streak(member.id)
        longest_streak = streak.get('longest_streak', 0)
        
        if longest_streak >= 7:
            MilestoneDetectionService._unlock_milestone(
                member, "7-Day Attendance Streak", today, f"{longest_streak} consecutive check-ins"
            )
        if longest_streak >= 30:
            MilestoneDetectionService._unlock_milestone(
                member, "30-Day Attendance Streak", today, f"{longest_streak} consecutive check-ins"
            )

    @staticmethod
    def _unlock_milestone(member, milestone_name, achieved_date, value_str):
        ProgressMilestone.objects.get_or_create(
            member=member,
            milestone_name=milestone_name,
            defaults={
                'achieved_date': achieved_date,
                'achievement_value': value_str
            }
        )


class AnalyticsEngine:
    @staticmethod
    def generate_analytics(member):
        """
        Generate weight, BMI, body fat lists and timelines for graphics components.
        """
        measurements = ProgressMeasurement.objects.filter(member=member).order_by('recorded_date', 'created_at')
        
        weight_trend = []
        body_fat_trend = []
        bmi_trend = []
        measurement_trends = {
            'chest': [],
            'waist': [],
            'hips': [],
            'biceps': []
        }
        
        for m in measurements:
            date_str = m.recorded_date.strftime("%Y-%m-%d")
            weight_trend.append({'date': date_str, 'weight_kg': m.weight_kg})
            body_fat_trend.append({'date': date_str, 'body_fat_percentage': m.body_fat_percentage})
            if m.bmi:
                bmi_trend.append({'date': date_str, 'bmi': m.bmi})
                
            if m.chest_cm:
                measurement_trends['chest'].append({'date': date_str, 'value': m.chest_cm})
            if m.waist_cm:
                measurement_trends['waist'].append({'date': date_str, 'value': m.waist_cm})
            if m.hips_cm:
                measurement_trends['hips'].append({'date': date_str, 'value': m.hips_cm})
            if m.biceps_cm:
                measurement_trends['biceps'].append({'date': date_str, 'value': m.biceps_cm})

        # Before vs After Summary
        summary = {}
        if measurements.exists():
            first = measurements[0]
            latest = measurements[len(measurements) - 1]
            summary = {
                'start_weight': first.weight_kg,
                'current_weight': latest.weight_kg,
                'weight_change': round(latest.weight_kg - first.weight_kg, 1),
                'start_body_fat': first.body_fat_percentage,
                'current_body_fat': latest.body_fat_percentage,
                'body_fat_change': round(latest.body_fat_percentage - first.body_fat_percentage, 1),
                'start_bmi': first.bmi,
                'current_bmi': latest.bmi,
                'bmi_change': round(latest.bmi - first.bmi, 1) if (latest.bmi and first.bmi) else 0.0
            }
        
        # Month over Month averages
        today = timezone.localdate()
        this_month_start = today.replace(day=1)
        prev_month_end = this_month_start - timedelta(days=1)
        prev_month_start = prev_month_end.replace(day=1)
        
        this_month_avg = ProgressMeasurement.objects.filter(
            member=member,
            recorded_date__gte=this_month_start,
            recorded_date__lte=today
        ).aggregate(Avg('weight_kg'), Avg('body_fat_percentage'))
        
        prev_month_avg = ProgressMeasurement.objects.filter(
            member=member,
            recorded_date__gte=prev_month_start,
            recorded_date__lte=prev_month_end
        ).aggregate(Avg('weight_kg'), Avg('body_fat_percentage'))

        mom = {
            'this_month_avg_weight': round(this_month_avg['weight_kg__avg'] or 0.0, 1),
            'prev_month_avg_weight': round(prev_month_avg['weight_kg__avg'] or 0.0, 1),
            'this_month_avg_fat': round(this_month_avg['body_fat_percentage__avg'] or 0.0, 1),
            'prev_month_avg_fat': round(prev_month_avg['body_fat_percentage__avg'] or 0.0, 1),
        }

        # Active Goals & Milestones
        goals = FitnessGoal.objects.filter(member=member)
        milestones = ProgressMilestone.objects.filter(member=member)

        # Transformation TimelineEvents
        timeline = []
        for m in measurements:
            timeline.append({
                'date': m.recorded_date.strftime("%Y-%m-%d"),
                'type': 'MEASUREMENT',
                'title': 'Logged Measurements',
                'description': f"Weight: {m.weight_kg}kg, BF: {m.body_fat_percentage}%"
            })
        for photo in ProgressPhoto.objects.filter(member=member):
            timeline.append({
                'date': photo.uploaded_at.date().strftime("%Y-%m-%d"),
                'type': 'PHOTO',
                'title': f"Uploaded {photo.photo_type} Photo",
                'description': photo.notes or "No notes added"
            })
        for ms in milestones:
            timeline.append({
                'date': ms.achieved_date.strftime("%Y-%m-%d"),
                'type': 'MILESTONE',
                'title': f"Unlocked Achievement: {ms.milestone_name}",
                'description': ms.achievement_value
            })

        timeline = sorted(timeline, key=lambda x: x['date'], reverse=True)

        return {
            'weight_trend': weight_trend,
            'body_fat_trend': body_fat_trend,
            'bmi_trend': bmi_trend,
            'measurement_trends': measurement_trends,
            'transformation_summary': summary,
            'month_over_month': mom,
            'timeline': timeline,
            'active_goals_count': goals.filter(status=GoalStatus.ACTIVE).count(),
            'achieved_goals_count': goals.filter(status=GoalStatus.ACHIEVED).count(),
        }


class ProgressComparisonService:
    @staticmethod
    def compare(member, start_date_str, end_date_str):
        """
        Compare body composition and tape measurements between two dates.
        """
        # Parse Dates
        try:
            start_date = date.fromisoformat(start_date_str) if start_date_str else None
            end_date = date.fromisoformat(end_date_str) if end_date_str else None
        except ValueError:
            start_date, end_date = None, None
            
        measurements = ProgressMeasurement.objects.filter(member=member).order_by('recorded_date')
        
        if not measurements.exists():
            return {'error': 'No physical measurements recorded.'}
            
        # Match before
        before = None
        if start_date:
            before = measurements.filter(recorded_date__gte=start_date).first()
        if not before:
            before = measurements.first() # baseline
            
        # Match after
        after = None
        if end_date:
            after = measurements.filter(recorded_date__lte=end_date).last()
        if not after or after == before:
            after = measurements.last() # current
            
        # Calculate differences
        diff = {
            'weight_diff': round(after.weight_kg - before.weight_kg, 1),
            'body_fat_diff': round(after.body_fat_percentage - before.body_fat_percentage, 1),
            'bmi_diff': round((after.bmi or 0.0) - (before.bmi or 0.0), 1),
            'chest_diff': round((after.chest_cm or 0.0) - (before.chest_cm or 0.0), 1) if (after.chest_cm and before.chest_cm) else 0.0,
            'waist_diff': round((after.waist_cm or 0.0) - (before.waist_cm or 0.0), 1) if (after.waist_cm and before.waist_cm) else 0.0,
            'hips_diff': round((after.hips_cm or 0.0) - (before.hips_cm or 0.0), 1) if (after.hips_cm and before.hips_cm) else 0.0,
            'shoulders_diff': round((after.shoulders_cm or 0.0) - (before.shoulders_cm or 0.0), 1) if (after.shoulders_cm and before.shoulders_cm) else 0.0,
            'biceps_diff': round((after.biceps_cm or 0.0) - (before.biceps_cm or 0.0), 1) if (after.biceps_cm and before.biceps_cm) else 0.0,
            'thighs_diff': round((after.thighs_cm or 0.0) - (before.thighs_cm or 0.0), 1) if (after.thighs_cm and before.thighs_cm) else 0.0,
            'calves_diff': round((after.calves_cm or 0.0) - (before.calves_cm or 0.0), 1) if (after.calves_cm and before.calves_cm) else 0.0,
        }
        
        return {
            'before_date': before.recorded_date.strftime("%Y-%m-%d"),
            'after_date': after.recorded_date.strftime("%Y-%m-%d"),
            'before_weight': before.weight_kg,
            'after_weight': after.weight_kg,
            'before_body_fat': before.body_fat_percentage,
            'after_body_fat': after.body_fat_percentage,
            'differences': diff
        }
