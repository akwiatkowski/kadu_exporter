struct KaduExplorer::Message
  getter :string

  def initialize(
    @sender : String,
    @send_time : Time | Nil,
    @receive_time : Time | Nil,
    @content : String,
    @attributes : String,
    @chat : String = "",
  )
  end
end
