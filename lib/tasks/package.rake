namespace :edgarj do
  desc "build package under pkg/ with umask 002"
  task :build_gem do
    FileUtils.mkdir "/tmp/edgarj" if !File.directory?("/tmp/edgarj")
    sh <<-EOSH
      umask 002
      git archive --format=tar --prefix=edgarj/ HEAD | gzip >/tmp/edgarj.tgz
      cd /tmp/edgarj &&
      tar zxvf /tmp/edgarj.tgz &&
      cd edgarj &&
      gem build edgarj.gemspec
    EOSH
    
    FileUtils.mkdir "pkg" if !File.directory?("pkg")
    sh "mv /tmp/edgarj/edgarj/edgarj-*.gem pkg/"
   #sh "rm -r /tmp/edgarj"
  end
end
