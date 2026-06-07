from django.db.models import Q
from rest_framework.exceptions import PermissionDenied, NotFound
from .models import Member
from gyms.models import Gym

class MemberService:
    @staticmethod
    def get_members_for_owner(user, query_params=None):
        """
        Return members for the gym(s) owned by the user.
        Supports filtering and searching.
        """
        # Get active gyms owned by user
        gyms = Gym.objects.filter(owner=user, is_deleted=False)
        queryset = Member.objects.filter(gym__in=gyms, is_deleted=False)

        if query_params:
            search = query_params.get('search')
            if search:
                queryset = queryset.filter(
                    Q(full_name__icontains=search) |
                    Q(email__icontains=search) |
                    Q(phone_number__icontains=search)
                )

            status = query_params.get('status')
            if status:
                queryset = queryset.filter(status=status)

            gym_id = query_params.get('gym')
            if gym_id:
                queryset = queryset.filter(gym_id=gym_id)

            # Sorting
            ordering = query_params.get('ordering', '-created_at')
            allowed_ordering = ['full_name', '-full_name', 'join_date', '-join_date', 'created_at', '-created_at']
            if ordering in allowed_ordering:
                queryset = queryset.order_by(ordering)
            else:
                queryset = queryset.order_by('-created_at')

        return queryset

    @staticmethod
    def create_member(user, validated_data):
        """
        Create a member, linking to the user's first gym by default if not specified,
        or linking to a specific gym if the user owns it.
        """
        # For this version, assume owner adds member to their first active gym.
        # Scalability: In multi-gym UI, `gym_id` should be passed.
        gym = Gym.objects.filter(owner=user, is_deleted=False).first()
        if not gym:
            raise PermissionDenied("You must create a gym first before adding members.")
        
        return Member.objects.create(gym=gym, **validated_data)

    @staticmethod
    def update_member(member, validated_data):
        for attr, value in validated_data.items():
            setattr(member, attr, value)
        member.save()
        return member

    @staticmethod
    def delete_member(member):
        member.soft_delete()
