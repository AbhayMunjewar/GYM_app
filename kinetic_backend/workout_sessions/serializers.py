from rest_framework import serializers
from gyms.models import Gym
from trainers.models import Trainer
from members.models import Member
from .models import WorkoutSession, SessionBooking

class WorkoutSessionSerializer(serializers.ModelSerializer):
    trainer_name = serializers.CharField(source='trainer.user.full_name', read_only=True)
    booked_count = serializers.SerializerMethodField()

    class Meta:
        model = WorkoutSession
        fields = [
            'id', 'gym', 'trainer', 'trainer_name', 'title', 'description',
            'session_date', 'start_time', 'end_time', 'max_capacity',
            'booked_count', 'is_deleted', 'created_at', 'updated_at'
        ]

    def get_booked_count(self, obj):
        # We only count active bookings (status='booked')
        return obj.bookings.filter(status='booked').count()


class WorkoutSessionCreateSerializer(serializers.ModelSerializer):
    class Meta:
        model = WorkoutSession
        fields = [
            'gym', 'trainer', 'title', 'description',
            'session_date', 'start_time', 'end_time', 'max_capacity'
        ]

    def validate(self, data):
        start_time = data.get('start_time')
        end_time = data.get('end_time')
        trainer = data.get('trainer')
        gym = data.get('gym')

        # 1. Time range check (end_time must be after start_time)
        if start_time and end_time:
            if end_time <= start_time:
                raise serializers.ValidationError({"end_time": "End time must be after start time."})

        # 2. Trainer belongs to gym check
        if trainer and gym:
            if trainer.gym != gym:
                raise serializers.ValidationError({"trainer": "The selected trainer does not belong to the selected gym."})

        return data


class SessionBookingSerializer(serializers.ModelSerializer):
    session_title = serializers.CharField(source='session.title', read_only=True)
    session_date = serializers.DateField(source='session.session_date', read_only=True)
    session_start_time = serializers.CharField(source='session.start_time', read_only=True)
    session_end_time = serializers.CharField(source='session.end_time', read_only=True)
    trainer_name = serializers.CharField(source='session.trainer.user.full_name', read_only=True)
    member_name = serializers.CharField(source='member.full_name', read_only=True)

    class Meta:
        model = SessionBooking
        fields = [
            'id', 'session', 'session_title', 'session_date', 'session_start_time',
            'session_end_time', 'trainer_name', 'member', 'member_name',
            'status', 'booked_at', 'updated_at'
        ]


class SessionBookingCreateSerializer(serializers.ModelSerializer):
    class Meta:
        model = SessionBooking
        fields = ['session', 'member']

    def validate(self, data):
        session = data.get('session')
        member = data.get('member')

        # 1. Validate session exists and is not deleted
        if session.is_deleted:
            raise serializers.ValidationError({"session": "Cannot book a deleted session."})

        # 2. Validate member belongs to the same gym
        if session.gym != member.gym:
            raise serializers.ValidationError({"member": "Member must belong to the same gym as the session."})

        # 3. Check session is not at max capacity
        active_bookings_count = session.bookings.filter(status='booked').count()
        if active_bookings_count >= session.max_capacity:
            raise serializers.ValidationError({"session": "This session has reached its maximum capacity."})

        # 4. Check member is not already booked in this session
        if SessionBooking.objects.filter(session=session, member=member, status='booked').exists():
            raise serializers.ValidationError({"member": "Member is already booked in this session."})

        return data
