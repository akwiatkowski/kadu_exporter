struct KaduExporter::Message
  getter :string
  getter :time
  getter :send_time
  getter :receive_time
  getter :content
  getter :attributes
  getter :chat
  getter :day
  getter :day_string
  getter :outgoing


  OUTGOING_FLAG = "outgoing=1"

  def initialize(
    @sender : String,
    @time : Time,
    @send_time : Time | Nil,
    @receive_time : Time | Nil,
    @content : String,
    @attributes : String,
    @chat : String = ""
  )
    @day = @time.date.as(Time)
    @day_string = @day.to_s(DAY_FORMAT).as(String)

    if @attributes.to_s.strip == OUTGOING_FLAG
      @outgoing = true
    else
      @outgoing = false
    end

    # sanitize msg
    @content = @content.
      gsub(/style='/, "style_removed='").
      gsub(/style=\"/, "style_removed=\"")
  end
end
