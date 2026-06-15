import logging
from django.db import transaction
from django.contrib.auth import get_user_model
from django.db.models import Count, Q
from django.utils import timezone

from notifications.services import NotificationService
from notifications.models import NotificationType, NotificationPriority
from members.models import Member
from trainers.models import Trainer
from gyms.models import Gym
from community.models import CommunityPost, PostComment
from .models import (
    Question, Answer, QuestionStatus,
    Group, GroupMember, GroupPost, GroupType, GroupMemberRole,
    Announcement, AnnouncementPriority,
    ChatRoom, ChatParticipant, Message, MessageType,
    ForumCategory, ForumTopic, ForumReply,
    Event, EventRegistration, EventStatus,
    Report, ReportContentType, ReportStatus
)

logger = logging.getLogger(__name__)
User = get_user_model()

class QAService:
    @staticmethod
    @transaction.atomic
    def create_question(member, trainer, gym, title, question_text):
        question = Question.objects.create(
            member=member,
            trainer=trainer,
            gym=gym,
            title=title,
            question=question_text,
            status=QuestionStatus.OPEN
        )

        # Notify trainer if assigned
        if trainer:
            NotificationService.create_notification(
                recipient=trainer,
                title="New Q&A Question",
                message=f"Member {member.full_name} asked you a question: {title}",
                notification_type=NotificationType.SYSTEM,
                priority=NotificationPriority.MEDIUM,
                action_url=f"/member/community"
            )
        return question

    @staticmethod
    @transaction.atomic
    def create_answer(question, trainer, answer_text):
        answer = Answer.objects.create(
            question=question,
            trainer=trainer,
            answer=answer_text
        )
        
        # Update question status to ANSWERED
        question.status = QuestionStatus.ANSWERED
        question.save(update_fields=['status', 'updated_at'])

        # Automatically publish a community post sharing this Q&A discussion
        # to boost community knowledge, if it's general visibility
        CommunityPost.objects.create(
            author=trainer,
            gym=question.gym,
            post_type='GENERAL',
            title=f"Q&A: {question.title}",
            content=f"❓ Question: {question.question}\n\n💡 Answered by Coach {trainer.full_name}:\n{answer_text}",
            visibility='PUBLIC_GYM',
            status='ACTIVE'
        )

        # Notify the asking member
        NotificationService.create_notification(
            recipient=question.member,
            title="Question Answered!",
            message=f"Trainer {trainer.full_name} answered your question: '{question.title}'",
            notification_type=NotificationType.SYSTEM,
            priority=NotificationPriority.HIGH,
            action_url=f"/member/community"
        )
        return answer


class GroupService:
    @staticmethod
    @transaction.atomic
    def create_group(gym, group_name, description, group_type, created_by):
        group = Group.objects.create(
            gym=gym,
            group_name=group_name,
            description=description,
            group_type=group_type,
            created_by=created_by
        )
        # Add creator as Admin member
        GroupMember.objects.create(
            group=group,
            user=created_by,
            role=GroupMemberRole.ADMIN
        )
        return group

    @staticmethod
    def join_group(group, user):
        member, created = GroupMember.objects.get_or_create(
            group=group,
            user=user,
            defaults={'role': GroupMemberRole.MEMBER}
        )
        return member

    @staticmethod
    def leave_group(group, user):
        deleted_count, _ = GroupMember.objects.filter(group=group, user=user).delete()
        return deleted_count > 0

    @staticmethod
    def create_group_post(group, author, content, image=None):
        # Verify user is a group member
        if not GroupMember.objects.filter(group=group, user=author).exists():
            raise ValueError("You must be a member of the group to post.")
            
        post = GroupPost.objects.create(
            group=group,
            author=author,
            content=content,
            image=image
        )
        return post


class AnnouncementService:
    @staticmethod
    @transaction.atomic
    def create_announcement(gym, created_by, title, description, priority=AnnouncementPriority.MEDIUM):
        # Only owners/trainers should invoke this service
        if created_by.role not in ['OWNER', 'TRAINER']:
            raise ValueError("Unauthorized to create announcements.")

        announcement = Announcement.objects.create(
            gym=gym,
            created_by=created_by,
            title=title,
            description=description,
            priority=priority
        )

        # Automatically share to community feed
        CommunityPost.objects.create(
            author=created_by,
            gym=gym,
            post_type='ANNOUNCEMENT',
            title=f"📢 Announcement: {title}",
            content=description,
            visibility='PUBLIC_GYM',
            status='ACTIVE'
        )

        # Notify all active members in this gym
        members = Member.objects.filter(gym=gym, is_deleted=False)
        for m in members:
            member_user = User.objects.filter(email=m.email).first()
            if member_user and member_user != created_by:
                notif_priority = NotificationPriority.MEDIUM
                if priority in [AnnouncementPriority.HIGH, AnnouncementPriority.CRITICAL]:
                    notif_priority = NotificationPriority.HIGH

                NotificationService.create_notification(
                    recipient=member_user,
                    title=f"Announcement: {title}",
                    message=description[:100] + ("..." if len(description) > 100 else ""),
                    notification_type=NotificationType.SYSTEM,
                    priority=notif_priority,
                    action_url=f"/member/community"
                )

        return announcement


class ChatService:
    @staticmethod
    @transaction.atomic
    def get_or_create_room(user1, user2):
        # Find if a room already exists with exactly these two users
        rooms = ChatRoom.objects.annotate(part_count=Count('participants')).filter(part_count=2)
        room = None
        for r in rooms:
            u_ids = set(r.participants.values_list('user_id', flat=True))
            if u_ids == {user1.id, user2.id}:
                room = r
                break
        
        if not room:
            room = ChatRoom.objects.create()
            ChatParticipant.objects.create(room=room, user=user1)
            ChatParticipant.objects.create(room=room, user=user2)
            
        return room

    @staticmethod
    @transaction.atomic
    def send_message(room, sender, content, message_type=MessageType.TEXT):
        message = Message.objects.create(
            room=room,
            sender=sender,
            content=content,
            message_type=message_type
        )

        # Notify other participants in the room
        participants = ChatParticipant.objects.filter(room=room).exclude(user=sender)
        for p in participants:
            NotificationService.create_notification(
                recipient=p.user,
                title="New Message",
                message=f"{sender.full_name}: {content[:50]}",
                notification_type=NotificationType.SYSTEM,
                priority=NotificationPriority.LOW,
                action_url=f"/member/chat/{room.id}"
            )
        return message

    @staticmethod
    def mark_messages_as_read(room, user):
        return Message.objects.filter(room=room, is_read=False).exclude(sender=user).update(is_read=True)

    @staticmethod
    def get_unread_message_count(user):
        # Sum of all unread messages in rooms where the user is a participant
        rooms = ChatParticipant.objects.filter(user=user).values_list('room_id', flat=True)
        return Message.objects.filter(room_id__in=rooms, is_read=False).exclude(sender=user).count()


class ForumService:
    @staticmethod
    def create_category(gym, name, description):
        return ForumCategory.objects.create(gym=gym, name=name, description=description)

    @staticmethod
    def create_topic(category, creator, title, content):
        return ForumTopic.objects.create(category=category, creator=creator, title=title, content=content)

    @staticmethod
    def create_reply(topic, author, content):
        if topic.is_locked:
            raise ValueError("Cannot reply to a locked topic.")
        return ForumReply.objects.create(topic=topic, author=author, content=content)


class EventService:
    @staticmethod
    def create_event(gym, title, description, start_date, end_date, capacity, created_by):
        return Event.objects.create(
            gym=gym,
            title=title,
            description=description,
            start_date=start_date,
            end_date=end_date,
            capacity=capacity,
            created_by=created_by,
            status=EventStatus.UPCOMING
        )

    @staticmethod
    @transaction.atomic
    def register_for_event(event, user):
        # Validate capacity
        current_registrations = event.registrations.count()
        if current_registrations >= event.capacity:
            raise ValueError("This event is fully booked.")
            
        registration, created = EventRegistration.objects.get_or_create(
            event=event,
            user=user
        )

        if created:
            NotificationService.create_notification(
                recipient=user,
                title="Event Registered 🎟️",
                message=f"You successfully registered for '{event.title}'.",
                notification_type=NotificationType.SYSTEM,
                priority=NotificationPriority.MEDIUM
            )
        return registration

    @staticmethod
    def cancel_event_registration(event, user):
        deleted_count, _ = EventRegistration.objects.filter(event=event, user=user).delete()
        return deleted_count > 0

    @staticmethod
    def mark_event_attendance(registration, attended=True):
        registration.attended = attended
        registration.save(update_fields=['attended'])
        return registration


class ModerationService:
    @staticmethod
    def create_report(reporter, content_type, content_id, reason):
        return Report.objects.create(
            reporter=reporter,
            content_type=content_type,
            content_id=content_id,
            reason=reason,
            status=ReportStatus.PENDING
        )

    @staticmethod
    @transaction.atomic
    def resolve_report(report, resolver, action_taken):
        # Ensure resolver is OWNER or TRAINER
        if resolver.role not in ['OWNER', 'TRAINER']:
            raise ValueError("Only moderators can resolve content reports.")

        report.status = ReportStatus.RESOLVED
        report.save(update_fields=['status', 'updated_at'])

        if action_taken in ['HIDE', 'DELETE']:
            # Perform action on target content object
            if report.content_type == ReportContentType.POST:
                # GroupPost or CommunityPost
                GroupPost.objects.filter(id=report.content_id).update(is_deleted=True)
                CommunityPost.objects.filter(id=report.content_id).update(is_deleted=True, status='DELETED')
            elif report.content_type == ReportContentType.COMMENT:
                PostComment.objects.filter(id=report.content_id).delete()
            elif report.content_type == ReportContentType.MESSAGE:
                Message.objects.filter(id=report.content_id).update(is_deleted=True)
            elif report.content_type == ReportContentType.FORUM_TOPIC:
                ForumTopic.objects.filter(id=report.content_id).update(is_locked=True)

        # Notify reporter
        NotificationService.create_notification(
            recipient=report.reporter,
            title="Report Resolved",
            message=f"Your report has been resolved. Action taken: {action_taken}.",
            notification_type=NotificationType.SYSTEM,
            priority=NotificationPriority.LOW
        )
        return report
