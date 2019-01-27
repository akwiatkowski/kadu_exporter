class KaduExporter::Filter
  getter :filtered_messages

  LOG_EVERY = GLOBAL_LOG_EVERY

  def initialize(
    @logger : Logger,
    @phrases : Array(String) = Array(String).new,
    @path : String = "var/phrases.txt",
    @enabled : Bool = true
  )
    if File.exists?(@path)
      File.read(@path).each_line do |phrase|
        @phrases << phrase
      end
    end

    @phrases.uniq!

    @before_phrase = "<span class=\"msg_filtered\">"
    @after_phrase = "</span>"

    @filtered_messages = MessageSet.new
  end

  def filter_msg_content(message : KaduExporter::Message)
    return message.content unless @enabled

    content = message.content
    @phrases.each do |phrase|
      if content.index(phrase)
        @filtered_messages[message.chat] ||= Array(KaduExporter::Message).new
        @filtered_messages[message.chat] << message

        content = content.gsub(phrase, @before_phrase + phrase + @after_phrase)
      end
    end
    return content
  end
end
