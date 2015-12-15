class Pgrouting20 < Formula
  desc "PostgreSQL extension to provide spatial routing"
  homepage "http://www.pgrouting.org"
  url "https://github.com/pgRouting/pgrouting/archive/pgrouting-2.0.1.tar.gz"
  sha256 "dfb4acddae634e705e680783413317c7482c42c94cd2795dcc359a98356e0e1c"

  conflicts_with "pgrouting", :because => "Differing versions of the same formula"

  # work around function name conflict from Postgres
  # https://github.com/pgRouting/pgrouting/issues/274
  patch :DATA

  depends_on "cmake" => :build
  depends_on "boost"
  depends_on "cgal"
  depends_on "postgis"
  depends_on "postgresql"

  def install
    mkdir "stage"
    mkdir "build" do
      system "cmake", "-DWITH_DD=ON", "..", *std_cmake_args
      system "make"
      system "make", "install", "DESTDIR=#{buildpath}/stage"
    end

    lib.install Dir["stage/**/lib/*"]
    (share/"postgresql/extension").install Dir["stage/**/share/postgresql/extension/*"]
  end

  test do
    pg_bin = Formula["postgresql"].opt_bin
    pg_port = "55561"
    system "#{pg_bin}/initdb", testpath/"test"
    pid = fork { exec "#{pg_bin}/postgres", "-D", testpath/"test", "-p", pg_port }

    begin
      sleep 2
      system "#{pg_bin}/createdb", "-p", pg_port
      system "#{pg_bin}/psql", "-p", pg_port, "--command", "CREATE DATABASE test;"
      system "#{pg_bin}/psql", "-p", pg_port, "-d", "test", "--command", "CREATE EXTENSION postgis;"
      system "#{pg_bin}/psql", "-p", pg_port, "-d", "test", "--command", "CREATE EXTENSION pgrouting;"
    ensure
      Process.kill 9, pid
      Process.wait pid
    end
  end
end

__END__
diff --git a/src/astar/src/astar.h b/src/astar/src/astar.h
index d5872bb..34a0621 100644
--- a/src/astar/src/astar.h
+++ b/src/astar/src/astar.h
@@ -21,6 +21,7 @@

 #define _ASTAR_H

+#include <unistd.h>
 #include "postgres.h"
 #include "dijkstra.h"

diff --git a/src/dijkstra/src/dijkstra.h b/src/dijkstra/src/dijkstra.h
index ca5bea4..09ac6f1 100644
--- a/src/dijkstra/src/dijkstra.h
+++ b/src/dijkstra/src/dijkstra.h
@@ -22,6 +22,7 @@
 #ifndef _DIJKSTRA_H
 #define _DIJKSTRA_H

+#include <unistd.h>
 #include "postgres.h"

 typedef struct edge
diff --git a/src/driving_distance/src/drivedist.h b/src/driving_distance/src/drivedist.h
index e85bdd7..ce20b8b 100644
--- a/src/driving_distance/src/drivedist.h
+++ b/src/driving_distance/src/drivedist.h
@@ -22,6 +22,7 @@
 #ifndef _DRIVEDIST_H
 #define _DRIVEDIST_H

+#include <unistd.h>
 #include "postgres.h"
 #include "dijkstra.h"
