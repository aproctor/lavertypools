require "chronic"

class MatchesController < ApplicationController
  before_action :set_match, only: [:show, :edit, :update, :destroy]

  # GET /matches
  # GET /matches.json
  def index
    if(params[:all] == "true")
      @matches = Match.all
    else
      @matches = Match.where("start_time > ?", Time.now - 1.months)
    end
  end

  # GET /matches/1
  # GET /matches/1.json
  def show
  end

  # GET /matches/new
  def new
    @match = Match.new
    @match.start_time = Chronic.parse("sunday at 3pm") #Time.zone.now()
    @match.end_time = @match.start_time + 3.hours
    @match.home_score = 0
    @match.away_score = 0
    @match.spread = 0.0
  end

  # GET /matches/1/edit
  def edit
  end

  # POST /matches
  # POST /matches.json
  def create
    @match = Match.new(match_params)

    respond_to do |format|
      if @match.save
        format.html { redirect_to matches_path, notice: 'Match was successfully created.' }
        format.json { render action: 'show', status: :created, location: @match }
      else
        format.html { render action: 'new' }
        format.json { render json: @match.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /matches/1
  # PATCH/PUT /matches/1.json
  def update
    respond_to do |format|
      if @match.update(match_params)
        format.html { redirect_to matches_path, notice: 'Match was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @match.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /matches/1
  # DELETE /matches/1.json
  def destroy
    @match.destroy
    respond_to do |format|
      format.html { redirect_to matches_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_match
      @match = Match.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def match_params
      p = params.require(:match).permit(:start_time, :end_time, :home_team_id, :away_team_id, :spread, :home_score, :away_score, :league_id)
      puts "PARAMS <#{p.inspect}>"
      if(params[:simple_format])
        p[:start_time] = Chronic.parse(params[:simple_date])
        p[:end_time] = p[:start_time] + 3.hours
      end

      p
    end
end
