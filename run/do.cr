require "../src/kadu_exporter"

path = "//home/olek/.kadu/history/history.db"
ke = KaduExporter::Task.new(
  path: path,
  filter_query: "limit 200"
)
ke.make_it_so
