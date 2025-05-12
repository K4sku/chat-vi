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
    @chat = Chat.new(model_id: "gemini-2.0-flash")
  end

  # GET /chats/1/edit
  def edit
  end

  def edit_title
  end

  # POST /chats or /chats.json
  def create
    @chat = Chat.new(chat_params)
    if message_params[:content].blank?
      @chat.errors.add(:base, "First message content cannot be blank.")
    else
      @chat.save!
      respond_to do |format|
        format.html { redirect_to @chat }
        format.json { render :show, status: :created, location: @chat }
      end
      ChatStreamJob.perform_later(@chat, message_params["content"])
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
