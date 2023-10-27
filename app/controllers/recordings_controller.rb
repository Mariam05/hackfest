require 'ML/recording_summarizer'

class RecordingsController < ApplicationController
  include BbbHelper

  def index
    begin
     @recordings = recordings
    rescue BigBlueButton::BigBlueButtonException => e
      logger.error(e.to_s)
      flash.now[:alert] = t('default.recording.server_down')
      @recordings = []
    end
  end

  # GET recordings/:record-id
  def show
    @recording = recording(params[:id])
    

    puts("\n\n**** @recording: #{@recording}")

    @summarizer = ML::RecordingSummarizer.new(@recording, Rails.configuration.openai_key)
    @recording[:summary] = @summarizer.summary
    @recording[:summaryTS] = @summarizer.summary(true)

    puts("\n\n**** @summarizer.summary(true): #{@summarizer.summary(true)}")

  end

  helper_method :recording_date, :recording_length
end
