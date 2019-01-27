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

  DAY_FORMAT = "%Y-%m-%d"

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
  end
end
