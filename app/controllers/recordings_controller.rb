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

  helper_method :recording_date, :recording_length
end
