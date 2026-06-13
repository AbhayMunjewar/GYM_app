from rest_framework import status
from rest_framework.views import APIView
from rest_framework.permissions import IsAuthenticated
from django.shortcuts import get_object_or_404
from django.db.models import Q
from datetime import date

from core.permissions import IsGymOwner, IsTrainer, IsMember
from core.responses import success_response, failure_response
from gyms.models import Gym
from trainers.models import Trainer
from members.models import Member
from .models import WorkoutSession, SessionBooking
from .serializers import (
    WorkoutSessionSerializer, WorkoutSessionCreateSerializer,
    SessionBookingSerializer, SessionBookingCreateSerializer
)

class WorkoutSessionListCreateView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        # Role guard: Owner or Trainer
        if request.user.role not in ['OWNER', 'TRAINER']:
            return failure_response(
                "Access Denied. Only Gym Owners or Trainers can create sessions.",
                status_code=status.HTTP_403_FORBIDDEN
            )

        serializer = WorkoutSessionCreateSerializer(data=request.data)
        if serializer.is_valid():
            gym = serializer.validated_data['gym']
            trainer = serializer.validated_data['trainer']
            session_date = serializer.validated_data['session_date']
            start_time = serializer.validated_data['start_time']
            end_time = serializer.validated_data['end_time']

            # Cross-gym protection:
            # If Owner, they must own the gym
            if request.user.role == 'OWNER' and gym.owner != request.user:
                return failure_response(
                    "You do not have permission to create sessions for this gym.",
                    status_code=status.HTTP_403_FORBIDDEN
                )
            # If Trainer, they must belong to the selected gym, and can only schedule for themselves
            if request.user.role == 'TRAINER':
                trainer_profile = Trainer.objects.filter(user=request.user, is_deleted=False).first()
                if not trainer_profile or trainer_profile.gym != gym or trainer_profile != trainer:
                    return failure_response(
                        "You do not have permission to create sessions for this gym/trainer.",
                        status_code=status.HTTP_403_FORBIDDEN
                    )

            # Trainer time conflict check (same trainer, same date, overlapping time)
            overlapping_sessions = WorkoutSession.objects.filter(
                trainer=trainer,
                session_date=session_date,
                is_deleted=False,
                start_time__lt=end_time,
                end_time__gt=start_time
            )

            if overlapping_sessions.exists():
                return failure_response(
                    "Time Conflict. This trainer is already scheduled for an overlapping session.",
                    status_code=status.HTTP_409_CONFLICT
                )

            session = serializer.save()
            return success_response(
                "Session created successfully",
                data=WorkoutSessionSerializer(session).data,
                status_code=status.HTTP_201_CREATED
            )

        return failure_response("Validation Error", errors=serializer.errors, status_code=status.HTTP_400_BAD_REQUEST)


class GymSessionsView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, gym_id):
        # Role: Owner only
        if request.user.role != 'OWNER':
            return failure_response("Only Gym Owners can view gym sessions.", status_code=status.HTTP_403_FORBIDDEN)

        gym = get_object_or_404(Gym, id=gym_id, is_deleted=False)
        # Cross-gym protection
        if gym.owner != request.user:
            return failure_response("You do not have permission to view sessions for this gym.", status_code=status.HTTP_403_FORBIDDEN)

        sessions = WorkoutSession.objects.filter(gym=gym, is_deleted=False)

        # Optional filter by date
        date_str = request.query_params.get('date')
        if date_str:
            try:
                sessions = sessions.filter(session_date=date_str)
            except ValueError:
                pass

        serializer = WorkoutSessionSerializer(sessions, many=True)
        return success_response("Sessions retrieved successfully", data=serializer.data)


class TrainerSessionsView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, trainer_id):
        # Role: Trainer or Owner
        if request.user.role not in ['OWNER', 'TRAINER']:
            return failure_response("Access Denied.", status_code=status.HTTP_403_FORBIDDEN)

        trainer = get_object_or_404(Trainer, id=trainer_id, is_deleted=False)

        # Cross-gym isolation
        if request.user.role == 'OWNER':
            if trainer.gym.owner != request.user:
                return failure_response("Permission Denied.", status_code=status.HTTP_403_FORBIDDEN)
        elif request.user.role == 'TRAINER':
            if trainer.user != request.user:
                return failure_response("Permission Denied. You can only view your own sessions.", status_code=status.HTTP_403_FORBIDDEN)

        # Return upcoming sessions (session_date >= today)
        today = date.today()
        sessions = WorkoutSession.objects.filter(trainer=trainer, is_deleted=False, session_date__gte=today)

        serializer = WorkoutSessionSerializer(sessions, many=True)
        return success_response("Trainer sessions retrieved successfully", data=serializer.data)


class WorkoutSessionDetailView(APIView):
    permission_classes = [IsAuthenticated]

    def get_session(self, session_id, user):
        session = get_object_or_404(WorkoutSession, id=session_id, is_deleted=False)
        # Cross-gym check
        if user.role == 'OWNER':
            if session.gym.owner != user:
                return None
        elif user.role == 'TRAINER':
            trainer_profile = Trainer.objects.filter(user=user, is_deleted=False).first()
            if not trainer_profile or session.gym != trainer_profile.gym:
                return None
        elif user.role == 'MEMBER':
            member_profile = Member.objects.filter(email=user.email, is_deleted=False).first()
            if not member_profile or session.gym != member_profile.gym:
                return None
        return session

    def put(self, request, session_id):
        # Role: Owner or Trainer
        if request.user.role not in ['OWNER', 'TRAINER']:
            return failure_response("Access Denied.", status_code=status.HTTP_403_FORBIDDEN)

        session = self.get_session(session_id, request.user)
        if not session:
            return failure_response("Session not found or permission denied.", status_code=status.HTTP_404_NOT_FOUND)

        # Partial update support
        serializer = WorkoutSessionSerializer(session, data=request.data, partial=True)
        if serializer.is_valid():
            # Trainer change time conflict check
            new_date = serializer.validated_data.get('session_date', session.session_date)
            new_start = serializer.validated_data.get('start_time', session.start_time)
            new_end = serializer.validated_data.get('end_time', session.end_time)
            new_trainer = serializer.validated_data.get('trainer', session.trainer)

            # Check overlap if date/time/trainer changed
            if (new_date != session.session_date or new_start != session.start_time or 
                new_end != session.end_time or new_trainer != session.trainer):
                
                conflicts = WorkoutSession.objects.filter(
                    trainer=new_trainer,
                    session_date=new_date,
                    is_deleted=False,
                    start_time__lt=new_end,
                    end_time__gt=new_start
                ).exclude(id=session.id)

                if conflicts.exists():
                    return failure_response(
                        "Time Conflict. Overlapping session exists for the trainer.",
                        status_code=status.HTTP_409_CONFLICT
                    )

            updated_session = serializer.save()
            return success_response("Session updated successfully", data=WorkoutSessionSerializer(updated_session).data)
        
        return failure_response("Validation Error", errors=serializer.errors, status_code=status.HTTP_400_BAD_REQUEST)

    def delete(self, request, session_id):
        # Role: Owner only
        if request.user.role != 'OWNER':
            return failure_response("Only Gym Owners can delete sessions.", status_code=status.HTTP_403_FORBIDDEN)

        session = self.get_session(session_id, request.user)
        if not session:
            return failure_response("Session not found or permission denied.", status_code=status.HTTP_404_NOT_FOUND)

        # Soft delete: set is_deleted = True, keep bookings for history
        session.is_deleted = True
        session.save()

        return success_response("Session soft deleted successfully.")


class SessionBookingListCreateView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        session_id = request.query_params.get('session_id')
        if not session_id:
            return failure_response("session_id parameter is required.", status_code=status.HTTP_400_BAD_REQUEST)

        session = get_object_or_404(WorkoutSession, id=session_id, is_deleted=False)

        # Cross-gym checks:
        if request.user.role == 'OWNER':
            if session.gym.owner != request.user:
                return failure_response("Permission Denied.", status_code=status.HTTP_403_FORBIDDEN)
        elif request.user.role == 'TRAINER':
            trainer_profile = Trainer.objects.filter(user=request.user, is_deleted=False).first()
            if not trainer_profile or session.gym != trainer_profile.gym:
                return failure_response("Permission Denied.", status_code=status.HTTP_403_FORBIDDEN)
        elif request.user.role == 'MEMBER':
            member_profile = Member.objects.filter(email=request.user.email, is_deleted=False).first()
            if not member_profile or session.gym != member_profile.gym:
                return failure_response("Permission Denied.", status_code=status.HTTP_403_FORBIDDEN)

        bookings = SessionBooking.objects.filter(session=session, status='booked')
        serializer = SessionBookingSerializer(bookings, many=True)
        return success_response("Session bookings retrieved successfully", data=serializer.data)

    def post(self, request):
        # Role: Owner or Trainer
        if request.user.role not in ['OWNER', 'TRAINER']:
            return failure_response(
                "Access Denied. Only Owners or Trainers can book members.",
                status_code=status.HTTP_403_FORBIDDEN
            )

        serializer = SessionBookingCreateSerializer(data=request.data)
        if serializer.is_valid():
            session = serializer.validated_data['session']
            member = serializer.validated_data['member']

            # Cross-gym validation
            if request.user.role == 'OWNER':
                if session.gym.owner != request.user:
                    return failure_response("Permission Denied.", status_code=status.HTTP_403_FORBIDDEN)
            elif request.user.role == 'TRAINER':
                trainer_profile = Trainer.objects.filter(user=request.user, is_deleted=False).first()
                if not trainer_profile or session.gym != trainer_profile.gym:
                    return failure_response("Permission Denied.", status_code=status.HTTP_403_FORBIDDEN)

            # If there was a previous cancelled booking, reactivate it instead of creating duplicate unique constraint violation
            existing_booking = SessionBooking.objects.filter(session=session, member=member).first()
            if existing_booking:
                existing_booking.status = 'booked'
                existing_booking.save()
                return success_response(
                    "Member booked successfully",
                    data=SessionBookingSerializer(existing_booking).data,
                    status_code=status.HTTP_201_CREATED
                )

            booking = serializer.save()
            return success_response(
                "Member booked successfully",
                data=SessionBookingSerializer(booking).data,
                status_code=status.HTTP_201_CREATED
            )

        return failure_response("Validation Error", errors=serializer.errors, status_code=status.HTTP_400_BAD_REQUEST)


class MemberBookingsView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, member_id):
        member = get_object_or_404(Member, id=member_id, is_deleted=False)

        # Permissions checks
        if request.user.role == 'OWNER':
            if member.gym.owner != request.user:
                return failure_response("Permission Denied.", status_code=status.HTTP_403_FORBIDDEN)
        elif request.user.role == 'TRAINER':
            trainer_profile = Trainer.objects.filter(user=request.user, is_deleted=False).first()
            if not trainer_profile or member.gym != trainer_profile.gym:
                return failure_response("Permission Denied.", status_code=status.HTTP_403_FORBIDDEN)
        elif request.user.role == 'MEMBER':
            if member.email != request.user.email:
                return failure_response("Permission Denied. You can only view your own schedule.", status_code=status.HTTP_403_FORBIDDEN)

        # Return upcoming bookings (session_date >= today, status != 'cancelled')
        today = date.today()
        bookings = SessionBooking.objects.filter(
            member=member,
            session__session_date__gte=today,
            session__is_deleted=False
        ).exclude(status='cancelled').order_by('session__session_date', 'session__start_time')

        serializer = SessionBookingSerializer(bookings, many=True)
        return success_response("Member upcoming schedule retrieved", data=serializer.data)


class CancelBookingView(APIView):
    permission_classes = [IsAuthenticated]

    def put(self, request, booking_id):
        booking = get_object_or_404(SessionBooking, id=booking_id)

        # Permissions check
        if request.user.role == 'OWNER':
            if booking.session.gym.owner != request.user:
                return failure_response("Permission Denied.", status_code=status.HTTP_403_FORBIDDEN)
        elif request.user.role == 'TRAINER':
            trainer_profile = Trainer.objects.filter(user=request.user, is_deleted=False).first()
            if not trainer_profile or booking.session.gym != trainer_profile.gym:
                return failure_response("Permission Denied.", status_code=status.HTTP_403_FORBIDDEN)
        elif request.user.role == 'MEMBER':
            if booking.member.email != request.user.email:
                return failure_response("Permission Denied. You can only cancel your own bookings.", status_code=status.HTTP_403_FORBIDDEN)

        booking.status = 'cancelled'
        booking.save()

        return success_response("Booking cancelled successfully", data=SessionBookingSerializer(booking).data)
