import json
from channels.generic.websocket import AsyncWebsocketConsumer
from channels.db import database_sync_to_async
from django.contrib.auth import get_user_model

User = get_user_model()

class ChatConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        self.room_id = self.scope['url_route']['kwargs']['room_id']
        self.room_group_name = f'chat_{self.room_id}'
        self.user = self.scope['user']

        # Verify authentication and room participation
        if await self.verify_participation():
            # Join room group
            await self.channel_layer.group_add(
                self.room_group_name,
                self.channel_name
            )
            await self.accept()
            # Mark existing messages as read
            await self.mark_messages_read()
        else:
            await self.close()

    async def disconnect(self, close_code):
        # Leave room group
        await self.channel_layer.group_discard(
            self.room_group_name,
            self.channel_name
        )

    # Receive message from WebSocket client
    async def receive(self, text_data):
        try:
            data = json.loads(text_data)
        except Exception:
            return

        content = data.get('content', '').strip()
        msg_type = data.get('message_type', 'TEXT')

        if not content:
            return

        # Persist message to database
        message_data = await self.save_message(content, msg_type)

        # Broadcast message to room group
        await self.channel_layer.group_send(
            self.room_group_name,
            {
                'type': 'chat_message',
                'message': message_data
            }
        )

    # Receive message from room group
    async def chat_message(self, event):
        message = event['message']

        # Send message to WebSocket client
        await self.send(text_data=json.dumps({
            'success': True,
            'data': message
        }))

    # Helper sync wrappers to run DB operations asynchronously

    @database_sync_to_async
    def verify_participation(self):
        if not self.user or not self.user.is_authenticated:
            return False
        from communication.models import ChatParticipant
        return ChatParticipant.objects.filter(room_id=self.room_id, user=self.user).exists()

    @database_sync_to_async
    def save_message(self, content, msg_type):
        from communication.services import ChatService
        from communication.models import ChatRoom
        from communication.serializers import MessageSerializer

        room = ChatRoom.objects.get(id=self.room_id)
        msg = ChatService.send_message(room, self.user, content, msg_type)
        return MessageSerializer(msg).data

    @database_sync_to_async
    def mark_messages_read(self):
        from communication.services import ChatService
        ChatService.mark_messages_as_read(self.room_id, self.user)
