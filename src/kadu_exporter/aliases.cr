alias MessageSet = Hash(String, Array(KaduExporter::Message))
alias MessageDay = Hash(Time, Array(KaduExporter::Message))

DAY_FORMAT       = "%Y-%m-%d"
GLOBAL_LOG_EVERY = 10_000
