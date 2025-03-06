# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...

# Ivy Ruby API

## Messaging Feature - Frontend Integration

### Required Dependencies

For real-time messaging, install the ActionCable client:

```bash
npm install @rails/actioncable
```

### Connecting to ActionCable

```javascript
// utils/cable.js
import { createConsumer } from '@rails/actioncable';

let consumer;

export const getConsumer = (token) => {
  if (!consumer) {
    consumer = createConsumer(`wss://your-api-url/cable?token=${token}`);
  }
  return consumer;
};

export const subscribeToConversation = (conversationId, token, onReceived) => {
  const consumer = getConsumer(token);
  
  return consumer.subscriptions.create(
    {
      channel: 'ConversationChannel',
      conversation_id: conversationId
    },
    {
      connected() {
        console.log('Connected to conversation channel');
      },
      disconnected() {
        console.log('Disconnected from conversation channel');
      },
      received(data) {
        onReceived(data);
      }
    }
  );
};
```

### API Endpoints for Messaging

#### Get All Conversations
```
GET /api/conversations
```

Response:
```json
[
  {
    "id": 1,
    "opposed_user": {
      "id": 2,
      "username": "jane_doe",
      "profile_photo_url": "https://example.com/photo.jpg"
    },
    "last_message": "Hello there!",
    "unread_count": 3,
    "updated_at": "2023-07-04T12:00:00Z"
  }
]
```

#### Get Single Conversation with Messages
```
GET /api/conversations/:id
```

Response:
```json
{
  "conversation": {
    "id": 1,
    "opposed_user": {
      "id": 2,
      "username": "jane_doe",
      "profile_photo_url": "https://example.com/photo.jpg"
    }
  },
  "messages": [
    {
      "id": 1,
      "body": "Hello there!",
      "user_id": 2,
      "created_at": "2023-07-04T12:00:00Z",
      "message_time": "07/04/23 at 12:00 PM",
      "is_mine": false
    },
    {
      "id": 2,
      "body": "Hi! How are you?",
      "user_id": 1,
      "created_at": "2023-07-04T12:01:00Z",
      "message_time": "07/04/23 at 12:01 PM",
      "is_mine": true
    }
  ]
}
```

#### Start a New Conversation
```
POST /api/conversations
```

Request:
```json
{
  "recipient_id": 2
}
```

Response:
```json
{
  "conversation_id": 1
}
```

#### Send a Message
```
POST /api/conversations/:conversation_id/messages
```

Request:
```json
{
  "message": {
    "body": "Hello, how are you?"
  }
}
```

Response:
```json
{
  "id": 3,
  "body": "Hello, how are you?",
  "user_id": 1,
  "created_at": "2023-07-04T12:05:00Z",
  "message_time": "07/04/23 at 12:05 PM",
  "is_mine": true
}
```

### Example React Components

#### ConversationsList.jsx
```jsx
import { useState, useEffect } from 'react';
import { useRouter } from 'next/router';
import api from '../utils/api';

export default function ConversationsList() {
  const [conversations, setConversations] = useState([]);
  const router = useRouter();

  useEffect(() => {
    const fetchConversations = async () => {
      try {
        const response = await api.get('/conversations');
        setConversations(response.data);
      } catch (error) {
        console.error('Error fetching conversations:', error);
      }
    };

    fetchConversations();
    // Set up a polling interval to check for new messages
    const interval = setInterval(fetchConversations, 30000);
    
    return () => clearInterval(interval);
  }, []);

  const handleConversationClick = (id) => {
    router.push(`/conversations/${id}`);
  };

  return (
    <div className="conversations-list">
      <h2>Messages</h2>
      {conversations.length === 0 ? (
        <p>No conversations yet</p>
      ) : (
        <ul>
          {conversations.map((conversation) => (
            <li 
              key={conversation.id} 
              onClick={() => handleConversationClick(conversation.id)}
              className={conversation.unread_count > 0 ? 'unread' : ''}
            >
              <div className="user-info">
                <img 
                  src={conversation.opposed_user.profile_photo_url || '/default-avatar.png'} 
                  alt={conversation.opposed_user.username} 
                />
                <span>{conversation.opposed_user.username}</span>
              </div>
              <div className="message-preview">
                <p>{conversation.last_message || 'No messages yet'}</p>
                {conversation.unread_count > 0 && (
                  <span className="unread-badge">{conversation.unread_count}</span>
                )}
              </div>
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}
```

#### ConversationDetail.jsx
```jsx
import { useState, useEffect, useRef } from 'react';
import { useRouter } from 'next/router';
import api from '../utils/api';
import { subscribeToConversation } from '../utils/cable';

export default function ConversationDetail() {
  const [conversation, setConversation] = useState(null);
  const [messages, setMessages] = useState([]);
  const [newMessage, setNewMessage] = useState('');
  const [loading, setLoading] = useState(true);
  const messagesEndRef = useRef(null);
  const router = useRouter();
  const { id } = router.query;
  
  useEffect(() => {
    if (!id) return;
    
    const fetchConversation = async () => {
      try {
        setLoading(true);
        const response = await api.get(`/conversations/${id}`);
        setConversation(response.data.conversation);
        setMessages(response.data.messages);
        setLoading(false);
      } catch (error) {
        console.error('Error fetching conversation:', error);
        setLoading(false);
      }
    };

    fetchConversation();
    
    // Subscribe to real-time updates
    const token = localStorage.getItem('token');
    const subscription = subscribeToConversation(id, token, (data) => {
      setMessages(prevMessages => [...prevMessages, data]);
    });
    
    return () => {
      if (subscription) {
        subscription.unsubscribe();
      }
    };
  }, [id]);
  
  useEffect(() => {
    // Scroll to bottom when messages change
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages]);
  
  const handleSendMessage = async (e) => {
    e.preventDefault();
    if (!newMessage.trim()) return;
    
    try {
      await api.post(`/conversations/${id}/messages`, {
        message: { body: newMessage }
      });
      setNewMessage('');
    } catch (error) {
      console.error('Error sending message:', error);
    }
  };
  
  if (loading) return <div>Loading...</div>;
  if (!conversation) return <div>Conversation not found</div>;
  
  return (
    <div className="conversation-detail">
      <div className="conversation-header">
        <img 
          src={conversation.opposed_user.profile_photo_url || '/default-avatar.png'} 
          alt={conversation.opposed_user.username} 
        />
        <h2>{conversation.opposed_user.username}</h2>
      </div>
      
      <div className="messages-container">
        {messages.length === 0 ? (
          <p className="no-messages">No messages yet. Start the conversation!</p>
        ) : (
          messages.map((message) => (
            <div 
              key={message.id} 
              className={`message ${message.is_mine ? 'mine' : 'theirs'}`}
            >
              <div className="message-content">
                <p>{message.body}</p>
                <span className="message-time">{message.message_time}</span>
              </div>
            </div>
          ))
        )}
        <div ref={messagesEndRef} />
      </div>
      
      <form onSubmit={handleSendMessage} className="message-form">
        <input
          type="text"
          value={newMessage}
          onChange={(e) => setNewMessage(e.target.value)}
          placeholder="Type a message..."
        />
        <button type="submit">Send</button>
      </form>
    </div>
  );
}
```

### Starting a New Conversation

To start a new conversation with another user, you can add a button on their profile page:

```jsx
const startConversation = async (userId) => {
  try {
    const response = await api.post('/conversations', {
      recipient_id: userId
    });
    router.push(`/conversations/${response.data.conversation_id}`);
  } catch (error) {
    console.error('Error starting conversation:', error);
  }
};
```
