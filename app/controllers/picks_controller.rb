class PicksController < ApplicationController
  before_action :set_pick, only: [:show, :edit, :update, :destroy]

  # GET /picks/setup
  def setup
    #Find Pool
    @pool = nil
    if(params[:pool_id].present?)
      @pool = Pool.find(params[:pool_id])
    else
      raise "Must supply a pool"
    end

    #Find or Create Player
    @player = nil
    if(params[:player_id].present?)
      @player = Player.find(params[:player_id])
    elsif(params[:player_name].present?)
      @player = Player.first_or_initialize(:name => params[:player_name])
    else
      raise "Supply either player_id or player_name"
    end

    if(@pool.players.where(:id => @player.id).count() < 1)
      @pool.players << @player
      @pool.save
    end

    @picks = []
    @pool.matches.each do |m|
      pick = Pick.first_or_initialize(:player => @player, :pool => @pool, :match => m)
      pick.winner ||= 0
      pick.save!
      @picks << pick
    end
  end

  # PATCH/PUT /picks/1
  # PATCH/PUT /picks/1.json
  def update
    respond_to do |format|
      if @pick.update(pick_params)
        format.html { redirect_to pools_path(@pick.pool), notice: 'Pick was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @pick.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_pick
      @pick = Pick.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def pick_params
      params.require(:pick).permit(:player_id, :match_id, :pool_id, :winner)
    end
end
