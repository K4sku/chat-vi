class ChatsController < ApplicationController
  before_action :set_chat, only: %i[ show edit edit_title update destroy ]

  # GET /chats or /chats.json
  def index
    @chat = Chat.new
  end

  # GET /chats/1 or /chats/1.json
  def show
  end

  # GET /chats/new
  def new
    @chat = Chat.new
  end

  # GET /chats/1/edit
  def edit
  end

  def edit_title
  end

  # POST /chats or /chats.json
  def create
    @chat = Chat.new(chat_params) # model_id will be set here
    # Ensure @message is initialized even if message_params are missing or content is blank for error display
    @message = @chat.messages.build(content: message_params[:content], role: :user) # Assuming 'user' role

    Chat.transaction do
      if @chat.save
        # Before attempting to save the message, explicitly set its role if not already.
        # And ensure content is present, otherwise it might fail validation silently depending on model.
        @message.role ||= :user # Ensure role is set, :user is a good default for the first message
        
        # We need to explicitly check if message content is present because .build doesn't validate immediately
        if @message.content.blank?
          @chat.errors.add(:base, "First message content cannot be blank.")
          @message.errors.add(:content, "can't be blank") # Populate error on message object too
          raise ActiveRecord::Rollback # Rollback chat creation
        end

        if @message.save
          respond_to do |format|
            format.html { redirect_to @chat, notice: "Chat was successfully created." }
            format.json { render :show, status: :created, location: @chat }
          end
        else
          # Message save failed, associate errors with @chat for display
          @message.errors.full_messages.each { |msg| @chat.errors.add(:base, "First message: #{msg}") }
          raise ActiveRecord::Rollback # Ensure transaction is rolled back
        end
      else
        # Chat save failed. If message content was provided, validate message to show its errors too.
        if @message.content.present?
          @message.valid? # Run validations to populate errors on @message
          @message.errors.full_messages.each { |msg| @chat.errors.add(:base, "First message: #{msg}") }
        elsif !@message.errors.added?(:content, :blank) # if content was blank and not already added
           @chat.errors.add(:base, "First message content cannot be blank.") unless @chat.errors.messages.values.flatten.include?("First message content cannot be blank.")
           @message.errors.add(:content, "can't be blank")
        end
        # No need to raise Rollback here, as the transaction hasn't started succeeding.
        # Fall through to render :new
      end
    end
  rescue ActiveRecord::Rollback
    # Transaction was rolled back, re-render :new with errors
    # Errors on @chat (and potentially @message) should be set for the view.
    # The instance variables @chat and @message are already set.
    # We need to make sure they are available in the `new` template for error display.
    respond_to do |format|
      format.html { render :new, status: :unprocessable_entity }
      format.json { render json: { chat_errors: @chat.errors, message_errors: @message.errors }, status: :unprocessable_entity }
    end
  # This block handles the case where @chat.save failed outside the transaction,
  # or if Rollback was not caught and re-raised, though the rescue above should handle it.
  # It ensures that if we fall through from an unsuccessful @chat.save without a rollback,
  # we still render the new template correctly.
  if @chat.errors.any? || (@message && @message.errors.any?)
    respond_to do |format|
      format.html { render :new, status: :unprocessable_entity and return } # ensure we return after render
      format.json { render json: { chat_errors: @chat.errors, message_errors: @message.errors }, status: :unprocessable_entity and return }
    end
  end
  end

  # PATCH/PUT /chats/1 or /chats/1.json
  def update
    respond_to do |format|
      if @chat.update(chat_params)
        format.html { redirect_to @chat, notice: "Chat was successfully updated." }
        format.json { render :show, status: :ok, location: @chat }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @chat.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /chats/1 or /chats/1.json
  def destroy
    @chat.destroy!

    respond_to do |format|
      format.html { redirect_to chats_path, status: :see_other, notice: "Chat was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_chat
      @chat = Chat.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through for Chat.
    def chat_params
      params.require(:chat).permit(:model_id, :title) # title is optional for now
    end

    # Parameters for the first message.
    def message_params
      # Use fetch to provide a default empty hash if :message is not present,
      # then permit :content. This prevents NoMethodError on nil if :message key is missing.
      params.fetch(:message, {}).permit(:content)
    end
end
