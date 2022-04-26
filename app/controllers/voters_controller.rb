class VotersController < ApplicationController
  before_action :set_voter, only: %i[show edit update destroy]
  before_action :set_ballot, only: [:create, :index, :new]
  skip_before_action :authenticate_user!

  # GET /voters or /voters.json
  def index
    @voters = Voter.all
    # @ballot = Ballot.find(params[:ballot_id])
    # @voter = Voter.new({ ballot_id: @ballot.id })
  end

  # GET /voters/1 or /voters/1.json
  def show; end

  # GET /voters/new
  def new
    # @voter = Voter.new
    @ballot = session[:ballot_id]
    @ballot_user_id = session[:ballot_user_id]
    Rails.logger.debug { "ballot_id: #{@ballot_id} user_id: #{@ballot_user_id}" }
    @voter = Voter.new
  end

  # GET /voters/1/edit
  def edit; end

  # POST /voters or /voters.json
  def create
    @ballot = session[:ballot_id]
    @ballot_user_id = session[:ballot_user_id]
    @voter = Voter.new(voter_params)

    respond_to do |format|
      if @voter.save
        session[:ballot_id] = @ballot
        session[:voter] = @voter
        format.html { redirect_to user_ballot_waiting_room_path(@ballot_user_id, @voter.ballot_id), notice: "Voter was successfully created." }
        format.json { render :show, status: :created, location: @voter }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @voter.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /voters/1 or /voters/1.json
  def update
    respond_to do |format|
      if @voter.update(voter_params)
        format.html { redirect_to user_ballot_voters_url(current_user, @ballot), notice: "Voter was successfully updated." }
        format.json { render :show, status: :ok, location: @voter }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @voter.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /voters/1 or /voters/1.json
  def destroy
    session[:return_to] ||= request.referer
    @voter.destroy

    respond_to do |format|
      format.html { redirect_to session.delete(:return_to), notice: "Voter was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  # Only allow a list of trusted parameters through.
  # Use callbacks to share common setup or constraints between actions.
  def set_voter
    @voter = Voter.find(params[:id])
  end

  def voter_params
    params.require(:voter).permit(:ballot_id, :username)
  end

  def set_ballot
    @ballot_user_id = session[:ballot_user_id]
    @ballot_id = session[:ballot_id]
  end
end
