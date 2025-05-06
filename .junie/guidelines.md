# ChatVI Project Guidelines

This document provides essential information for developers working on the ChatVI project.

## Project Overview

ChatVI is a Ruby on Rails application that provides a chat interface with AI models including Claude, GPT, and Gemini. The application uses:

- Ruby 3.4.2
- Rails 8.0.2
- SQLite database
- Hotwire (Turbo and Stimulus) for frontend interactivity
- Docker for deployment

## Build/Configuration Instructions

### Local Development Setup

1. **Ruby Version**: Ensure you have Ruby 3.4.2 installed. You can use a version manager like rbenv or RVM.

2. **Dependencies**: Install dependencies using Bundler 2.6.7 or higher:
   ```bash
   gem install bundler:2.6.7
   bundle install
   ```

3. **Database Setup**: Initialize the database:
   ```bash
   bin/rails db:create
   bin/rails db:migrate
   ```

4. **Start the Server**: Run the Rails server:
   ```bash
   bin/rails server
   ```

### Docker Deployment

The project includes Docker configuration for production deployment:

1. **Build the Docker Image**:
   ```bash
   docker build -t chat_vi .
   ```

2. **Run the Container**:
   ```bash
   docker run -d -p 80:80 -e RAILS_MASTER_KEY=<value from config/master.key> --name chat_vi chat_vi
   ```

3. **Kamal Deployment**: The project supports deployment with Kamal. Refer to the Kamal documentation for specific commands.

## Testing Information

### Running Tests

The project uses the standard Rails testing framework with Minitest. Tests are organized in the `test/` directory.

1. **Run All Tests**:
   ```bash
   bin/rails test
   ```

2. **Run Specific Test Files**:
   ```bash
   bin/rails test test/models/chat_test.rb
   ```

3. **Run System Tests**:
   ```bash
   bin/rails test:system
   ```

### Test Structure

- **Unit Tests**: Located in `test/models/`, `test/controllers/`, `test/helpers/`, and `test/mailers/`
- **Integration Tests**: Located in `test/integration/`
- **System Tests**: Located in `test/system/`
- **Fixtures**: Located in `test/fixtures/`

### Adding New Tests

1. **Model Tests**: Create or modify files in `test/models/` directory. Example:
   ```ruby
   require "test_helper"

   class ChatTest < ActiveSupport::TestCase
     test "should not save chat without model_id" do
       chat = Chat.new
       assert_not chat.save, "Saved the chat without a model_id"
     end

     test "should save chat with valid model_id" do
       chat = Chat.new(model_id: Chat::ALLOWED_MODELS.first[1])
       assert chat.save, "Could not save the chat with a valid model_id"
     end
   end
   ```

2. **Controller Tests**: Create or modify files in `test/controllers/` directory. Use `assert_response`, `assert_redirected_to`, and `assert_difference` for assertions.

3. **System Tests**: Create or modify files in `test/system/` directory. Use Capybara methods like `visit`, `click_on`, and assertions like `assert_selector` and `assert_text`.

## Additional Development Information

### Code Style

- The project uses Rubocop with the Rails Omakase configuration for code style enforcement.
- Run Rubocop to check code style:
  ```bash
  bundle exec rubocop
  ```

### Security Analysis

- The project uses Brakeman for security vulnerability analysis:
  ```bash
  bundle exec brakeman
  ```

### Key Components

- **Chat Model**: Represents a conversation with an AI model. Validates the presence of `model_id` and supports multiple AI models.
- **Message Model**: Represents individual messages in a chat.
- **ToolCall Model**: Represents tool calls made by AI models.

### Real-time Updates

- The application uses ActionCable for real-time updates, with the `broadcasts_to` method in models.

### Performance Optimization

- The application uses Bootsnap for faster boot times.
- In production, Thruster is used for HTTP asset caching/compression and X-Sendfile acceleration.
- Jemalloc is enabled in the Docker container for reduced memory usage and latency.
