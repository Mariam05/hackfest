require 'webvtt'
require 'uri'
require 'net/http'
require 'json'
require 'dotenv/load'
require "openai"
require 'open-uri'

module ML 
	class RecordingSummarizer

		attr_reader :transcript

		def initialize(recording, openai_key)
			@recording = recording
			@client = OpenAI::Client.new(access_token: openai_key)
			@podcast_url = recording[:playback][:format].find { |format| format[:type] == 'podcast' }[:url]
		end

		def summary(has_timestamps=false)
			@transcript = transcribe_recording(@podcast_url, has_timestamps)
			input_chunks = split_transcript(@transcript)
			output_chunks = []
	
			if input_chunks.length > 1
					input_chunks.each do |chunk|
							# perform the API call for each chunk.
							summary = get_summary(chunk, has_timestamps)
							output_chunks << summary
					end
					result = output_chunks.join(' ')
			else
					result = input_chunks.first
			end

			# final API call for joined chunks or single chunk.
			summary_call(result, has_timestamps)
		end
	
		# If include_ts, we get the transcript as vtt
		def transcribe_recording(playback_url, include_ts=false)

			Rails.cache.fetch("#{playback_url}/transcribe", expires_in: 1.hrs) do
				response_format = include_ts ? 'vtt' : 'json'
				
				response = nil
				error_message = nil
				
				begin
					response = @client.audio.transcribe(
							parameters: {
									model: "whisper-1",
									file: open(podcast_file(playback_url)),
									response_format: response_format
							})
				rescue => e 
					error_message = e.message.gsub("unexpected token at 'WEBVTT", "")
				end

				# Return only the error message if it exists and response_format is VTT
				if response_format == 'vtt'
					return error_message
				elsif response
					return response["text"]
				else
					return error_message
				end
			end
		end

		private 

		# "Download" the podcast file
		def podcast_file(playback_url)
			url = URI.parse(playback_url.strip)

			file_name = "podcast_files/#{@recording[:recordID]}.ogg"

			return file_name if File.file?(file_name)

			response = Net::HTTP.get_response(url)
			if response.is_a?(Net::HTTPSuccess)		
				File.open(file_name, "wb") do |file|
					file.write(response.body)
				end
				
				# Transcript without timestamps fed through AI to get summary.
				file_name
			else
				puts "Request failed with response code: #{response.code}"
				puts "Response message: #{response.message}"
			end
		end

		def split_transcript(transcript)
			# Split into chunks used as prompt input.
			max_chunk_size = 2048
			chunks = []
			current_chunk = ''
	
			transcript.split('.').each do |sentence|
					if (current_chunk.length + sentence.length) < max_chunk_size
							current_chunk += sentence + '.'
					else
							chunks << current_chunk.strip
							current_chunk = sentence + '.'
					end
			end
			chunks << current_chunk.strip unless current_chunk.empty?
			return chunks
		end

		def summary_call(transcript, timestamps=false)
			content = timestamps ? "Summarize keypoints and give their timestamps in format time-keypoint: " : "Summarize: "
			
			response = @client.chat(
					parameters: {
							model: "gpt-3.5-turbo",
							messages: [{ role: "user", content: content + transcript }],
							temperature: 0.5,
					})
			response.dig("choices", 0, "message", "content")
		end
	

	end
end