require "./aliases"

class KaduExporter::Writer
  OUTPUT_DIR = "var"
  TIME_OUTPUT_FORMAT = "%Y-%m-%d %H:%M:%S"
  LOG_EVERY          = 10

  def initialize(
    @logger : Logger,
    @ms : MessageSet
  )
    Dir.mkdir(OUTPUT_DIR) unless File.exists?(OUTPUT_DIR)
    @i = 0
  end

  def make_it_so
    @logger.info("Prepare write")

    @ms.keys.each do |chat|
      write_chat(chat)
    end

    @logger.info("Write finished")
  end

  def write_chat(chat : String)
    messages = @ms[chat].sort { |a, b| a.time <=> b.time }

    messaged_per_day = MessageDay.new
    messages.each do |message|
      messaged_per_day[message.day] ||= Array(KaduExporter::Message).new
      messaged_per_day[message.day] << message
    end

    messaged_per_day.keys.each do |day|
      write_to_day_file(
        chat: chat,
        day: day,
        messages: messaged_per_day[day]
      )
    end
  end

  def write_to_day_file(
    chat : String,
    day : Time,
    messages = Array(KaduExporter::Message).new
  )
    dir_path = File.join([OUTPUT_DIR, chat.gsub(/\W/, "")])
    Dir.mkdir(dir_path) unless File.exists?(dir_path)

    path = File.join([dir_path, "#{day.to_s(DAY_FORMAT)}.html"])

    @logger.info("Writing #{path}")
    File.open(path, "w") do |file|
      messages.each do |message|
        file.puts "<div class=\"msg\">"

        file.puts "<span class=\"msg_time\">#{message.time.to_s(TIME_OUTPUT_FORMAT)}</span>"

        file.puts "<span class=\"msg_direction\">"
        if message.outgoing
          file.puts ">>"
        else
          file.puts "<<"
        end
        file.puts "</span>"

        file.puts "<span class=\"msg_content\">#{message.content}</span>"

        file.puts "</div>"

        @i += 1
        @logger.info("Wrote #{@i}") if @i % LOG_EVERY == 0
      end
    end
  end
end
