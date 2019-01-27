require "../src/kadu_exporter"

path = "//home/olek/.kadu/history/history.db"
ke = KaduExplorer::Task.new(path)
ke.make_it_so
