require "google/cloud/speech"
require 'open-uri'

class UsersController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  # GET /users
  # GET /users.json
  def index
    @users = User.all
  end

  # GET /users/1
  # GET /users/1.json
  def show
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def call
    account_sid = 'AC190b568b8c4d53715714747d849f4408'
    auth_token = 'f09b837d794afb5c637af9c6a0055354'
    # set up a client to talk to the Twilio REST API
    @client = Twilio::REST::Client.new account_sid, auth_token
    @client.api.account.calls.create(
      record: true,
      from: '+917087274948',
      to: '+917087274948',
      url: 'http://example.com'
    )

    redirect_to user_voice_path
  end  

  def voice
    account_sid = 'AC190b568b8c4d53715714747d849f4408'
    auth_token = 'f09b837d794afb5c637af9c6a0055354'

    # set up a client to talk to the Twilio REST API
    @client = Twilio::REST::Client.new account_sid, auth_token

    @recordings = @client.recordings.list
  end

  #### use command ffmpeg -i hi.mp3 -ac 1 hh.flac

  def speech_to_text
    project_id = "mastodon-206209"   #### get from google cloud account
    key_file   = "/home/ip-d/Downloads/mastodon-3c070d97c836.json"     #### in order to create key_file go to google cloud console, click on APIs & services, then credentials, then create credentials, then service account key, select service account, Key type as json, it will save somewhere on your system, give that path here

    download = open(params[:path])
    IO.copy_stream(download, params[:path].split('/').last)
    system "ffmpeg -i #{params[:path].split('/').last} -ac 1 #{params[:path].split('/').last.split('.').first+'.flac'}"
    speech = Google::Cloud::Speech.new project: project_id, keyfile: key_file
    audio = speech.audio params[:path].split('/').last.split('.').first+'.flac', encoding: :FLAC, language: "en-US", sample_rate: 8000
    results = audio.recognize
    result = results.first
    result.transcript #=> "how old is the Brooklyn Bridge"
    result.confidence #=> 0.9826789498329163
  end  

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:name)
    end
end