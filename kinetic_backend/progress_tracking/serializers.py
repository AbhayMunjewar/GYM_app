from rest_framework import serializers
from .models import ProgressMeasurement, ProgressPhoto, FitnessGoal, ProgressMilestone
from members.models import Member
from trainers.models import Trainer
from datetime import date

class ProgressMeasurementSerializer(serializers.ModelSerializer):
    member_name = serializers.CharField(source='member.full_name', read_only=True)
    trainer_name = serializers.CharField(source='trainer.user.full_name', read_only=True, allow_null=True)
    
    class Meta:
        model = ProgressMeasurement
        fields = [
            'id', 'member', 'member_name', 'trainer', 'trainer_name',
            'weight_kg', 'body_fat_percentage', 'bmi', 'height_cm',
            'chest_cm', 'waist_cm', 'hips_cm', 'shoulders_cm',
            'biceps_cm', 'forearms_cm', 'thighs_cm', 'calves_cm', 'neck_cm',
            'notes', 'recorded_date', 'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'bmi', 'created_at', 'updated_at']

    def validate(self, data):
        # Weight, Height and body fat boundaries validations
        if 'weight_kg' in data and data['weight_kg'] <= 0:
            raise serializers.ValidationError({"weight_kg": "Weight must be greater than 0."})
        if 'height_cm' in data and data['height_cm'] <= 0:
            raise serializers.ValidationError({"height_cm": "Height must be greater than 0."})
        if 'body_fat_percentage' in data:
            bf = data['body_fat_percentage']
            if bf < 0 or bf > 100:
                raise serializers.ValidationError({"body_fat_percentage": "Body fat percentage must be between 0 and 100."})
                
        # Optional circumference boundary checks
        for c_field in ['chest_cm', 'waist_cm', 'hips_cm', 'shoulders_cm', 'biceps_cm', 'forearms_cm', 'thighs_cm', 'calves_cm', 'neck_cm']:
            if c_field in data and data[c_field] is not None and data[c_field] <= 0:
                raise serializers.ValidationError({c_field: f"{c_field.replace('_', ' ').capitalize()} must be positive."})
                
        # Gym verification
        member = data.get('member')
        trainer = data.get('trainer')
        if member and trainer and member.gym != trainer.gym:
            raise serializers.ValidationError("Member and Trainer must belong to the same gym.")
            
        return data


class ProgressPhotoSerializer(serializers.ModelSerializer):
    member_name = serializers.CharField(source='member.full_name', read_only=True)
    
    class Meta:
        model = ProgressPhoto
        fields = [
            'id', 'member', 'member_name', 'uploaded_by', 'photo_type',
            'image', 'notes', 'uploaded_at'
        ]
        read_only_fields = ['id', 'uploaded_by', 'uploaded_at']

    def validate(self, data):
        # Validate that image size is not empty
        image = data.get('image')
        if image:
            # limit image upload to 5MB
            if image.size > 5 * 1024 * 1024:
                raise serializers.ValidationError({"image": "Image size cannot exceed 5MB."})
        return data


class FitnessGoalSerializer(serializers.ModelSerializer):
    member_name = serializers.CharField(source='member.full_name', read_only=True)
    
    class Meta:
        model = FitnessGoal
        fields = [
            'id', 'member', 'member_name', 'goal_type',
            'starting_weight', 'starting_body_fat',
            'target_weight', 'target_body_fat', 'target_date',
            'current_progress_percentage', 'status', 'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'starting_weight', 'starting_body_fat', 'current_progress_percentage', 'created_at', 'updated_at']

    def validate(self, data):
        # Validate target date is in future
        target_date = data.get('target_date')
        if target_date and target_date < date.today():
            raise serializers.ValidationError({"target_date": "Target date must be in the future."})
            
        # Target weight / target fat validates bounds
        if 'target_weight' in data and data['target_weight'] is not None and data['target_weight'] <= 0:
            raise serializers.ValidationError({"target_weight": "Target weight must be greater than 0."})
        if 'target_body_fat' in data and data['target_body_fat'] is not None:
            bf = data['target_body_fat']
            if bf < 0 or bf > 100:
                raise serializers.ValidationError({"target_body_fat": "Target body fat must be between 0 and 100."})
                
        return data


class ProgressMilestoneSerializer(serializers.ModelSerializer):
    member_name = serializers.CharField(source='member.full_name', read_only=True)

    class Meta:
        model = ProgressMilestone
        fields = ['id', 'member', 'member_name', 'milestone_name', 'achieved_date', 'achievement_value', 'created_at']
        read_only_fields = ['id', 'created_at']
