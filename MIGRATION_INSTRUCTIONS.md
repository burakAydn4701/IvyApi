# Migration Instructions

We've renamed the models, controllers, and routes from "conversation" to "chat". To properly migrate your database, follow these steps:

## If you haven't run migrations yet:

1. Delete the old migration files:
```bash
rm db/migrate/20240704000001_create_conversations.rb
```

2. Make sure you have the new migration files:
- `db/migrate/20240704000001_create_chats.rb`
- `db/migrate/20240704000002_create_messages.rb`

3. Run the migrations:
```bash
rails db:migrate
```

## If you've already run migrations with the old names:

1. Create a new migration to rename the tables:
```bash
rails g migration RenameConversationsToChats
```

2. Edit the new migration file to include:
```ruby
class RenameConversationsToChats < ActiveRecord::Migration[7.0]
  def change
    rename_table :conversations, :chats
    
    # Update foreign key in messages table
    rename_column :messages, :conversation_id, :chat_id
  end
end
```

3. Run the migration:
```bash
rails db:migrate
```

## Verify the changes:

After running migrations, verify that your database schema has the correct tables:

```bash
rails db:schema:dump
cat db/schema.rb | grep -A 10 "create_table \"chats\""
cat db/schema.rb | grep -A 10 "create_table \"messages\""
```

You should see the `chats` table and the `messages` table with a `chat_id` foreign key.

## Clean up old files:

Make sure to remove any old files that are no longer needed:

```bash
rm app/models/conversation.rb
rm app/controllers/api/conversations_controller.rb
rm app/channels/conversation_channel.rb
```

And ensure you have the new files:
- `app/models/chat.rb`
- `app/controllers/api/chats_controller.rb`
- `app/channels/chat_channel.rb` 