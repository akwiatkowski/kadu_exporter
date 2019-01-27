require "./aliases"

class KaduExporter::Writer
  OUTPUT_DIR = "var"

  def initialize(
    @logger : Logger,
    @ms : MessageSet
  )
    Dir.mkdir(OUTPUT_DIR) unless File.exists?(OUTPUT_DIR)
  end

  def make_it_so
    @ms.keys.each do |chat|
      write_chat(chat)
    end
  end

  def write_chat(chat : String)
    messages = @ms[chat].sort{ |a,b| a.time <=> b.time }

    messaged_per_day = MessageDay.new
    messages.each do |message|
      messaged_per_day[message.day] ||= Array(KaduExporter::Message).new
      messaged_per_day[message.day] << message
    end

    messaged_per_day.keys.each do |day|
      write_to_day_file(
        day: day,
        messages: messaged_per_day[day]
      )
    end

  end

  def write_to_day_file(
    day : Time,
    messages = Array(KaduExporter::Message).new
  )
  end
end
