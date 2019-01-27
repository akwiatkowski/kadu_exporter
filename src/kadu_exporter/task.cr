require "sqlite3"
require "logger"
require "./message"
require "./writer"

class KaduExporter::Task
  MAIN_QUERY = "select chat,sender,send_time,receive_time,content,attributes from kadu_messages"
  TIME_FORMAT = "%Y-%m-%dT%H:%M:%S"
  INITIAL_BLANK_TIME = Time.utc(1990, 1, 1)
  LOG_EVERY = 10

  def initialize(
    @path : String,
    @filter_query : String = "limit 10",
    @location : Time::Location = Time::Location.load("Europe/Warsaw")
  )
    @message_set = MessageSet.new
    @logger = Logger.new(STDOUT)
    @i = 0
  end

  # kadu_messages: chat|sender|send_time|receive_time|content|attributes

  def make_it_so
    @i = 0

    @logger.info("Opening #{@path}")
    DB.open "sqlite3://#{@path}" do |db|
      @logger.info("Opened #{@path}")

      query = "#{MAIN_QUERY} #{@filter_query}"
      db.query(query) do |rs|
        @logger.info("Quered #{query}")
        rs.each do
          process_rs(rs)
          @logger.info("Processed #{@i}") if @i % LOG_EVERY == 0
        end
      end
      @logger.info("Finished #{@i}")
    end

    writer = KaduExporter::Writer.new(
      logger: @logger,
      ms: @message_set
    )
    writer.make_it_so
  end

  private def process_rs(rs)
    chat = rs.read(String)
    sender = rs.read(String)
    send_time_object = rs.read(Object)
    receive_time_object = rs.read(Object)
    content = rs.read(String)
    attributes = rs.read(String)

    send_time = nil
    receive_time = nil

    time = INITIAL_BLANK_TIME

    if send_time_object
      begin
        send_time = Time.parse(
          time: send_time_object.to_s.strip,
          pattern: TIME_FORMAT,
          location: @location
        )
        time = send_time
      rescue Time::Format::Error
        @logger.error("Parse time error: #{send_time_object}")
      end
    end

    if receive_time_object
      begin
        receive_time = Time.parse(
          time: receive_time_object.to_s.strip,
          pattern: TIME_FORMAT,
          location: @location
        )
        time = receive_time
      rescue Time::Format::Error
        @logger.error("Parse time error: #{receive_time_object}")
      end
    end


    message = KaduExporter::Message.new(
      chat: chat,
      sender: sender,
      time: time,
      send_time: send_time,
      receive_time: receive_time,
      content: content,
      attributes: attributes
    )

    @message_set[chat] ||= Array(KaduExporter::Message).new
    @message_set[chat] << message
    @i += 1
  end
end
